`timescale 1 ns / 1 ps

/*
 * Version modificada de cores/axis_ram_reader.v (Pavel Demin,
 * red-pitaya-notes) para permitir varias rafagas AXI en vuelo al mismo
 * tiempo (pipelining), en vez de esperar el rlast de cada rafaga antes de
 * pedir la siguiente.
 *
 * El original limitaba a UNA rafaga en vuelo por vez (via int_rvalid_reg,
 * un solo bit). Con la latencia de ida-y-vuelta de ACP/HP en Zynq-7000,
 * eso no alcanzaba a sostener el caudal continuo que necesita un DAC a
 * 125 MS/s (3.906.250 rafagas/s = 500 MB/s): medido empiricamente, se
 * quedaba en 60-80% de ese caudal segun el puerto usado.
 *
 * Cambio: int_rvalid_reg (1 bit) -> int_outstanding_reg (contador), que
 * sube al aceptarse un AR y baja al llegar el RLAST de una rafaga. La
 * condicion para emitir una rafaga nueva ahora reserva en el chequeo de
 * ocupacion del FIFO el espacio de TODAS las rafagas ya pedidas pero
 * todavia no arribadas (int_outstanding_reg * 16 beats), no solo lo que
 * ya esta fisicamente en el FIFO - de lo contrario, con varias rafagas en
 * vuelo, podrian llegar casi juntas y desbordar el FIFO interno.
 *
 * m_axi_arid se mantiene fijo en 0 para todas las transacciones: al usar
 * un unico ID, el AXI garantiza que las respuestas (RDATA) vuelven en el
 * mismo orden en que se pidieron las rafagas (ARADDR), asi que el FIFO
 * puede seguir empujando datos en orden de llegada sin necesitar
 * correlacionar IDs por transaccion.
 */

module axis_ram_reader #
(
  parameter integer ADDR_WIDTH = 16,
  parameter integer AXI_ID_WIDTH = 6,
  parameter integer AXI_ADDR_WIDTH = 32,
  parameter integer AXI_DATA_WIDTH = 64,
  parameter integer AXIS_TDATA_WIDTH = 64,
  parameter integer FIFO_WRITE_DEPTH = 512,
  parameter integer MAX_OUTSTANDING = 8
)
(
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire [AXI_ADDR_WIDTH-1:0]   min_addr,
  input  wire [ADDR_WIDTH-1:0]       cfg_data,
  output wire [ADDR_WIDTH-1:0]       sts_data,

  output wire [AXI_ID_WIDTH-1:0]     m_axi_arid,
  output wire [3:0]                  m_axi_arlen,
  output wire [2:0]                  m_axi_arsize,
  output wire [1:0]                  m_axi_arburst,
  output wire [3:0]                  m_axi_arcache,
  output wire [AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
  output wire                        m_axi_arvalid,
  input  wire                        m_axi_arready,

  input  wire [AXI_ID_WIDTH-1:0]     m_axi_rid,
  input  wire                        m_axi_rlast,
  input  wire [AXI_DATA_WIDTH-1:0]   m_axi_rdata,
  input  wire                        m_axi_rvalid,
  output wire                        m_axi_rready,

  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input  wire                        m_axis_tready
);

  localparam integer ADDR_SIZE = $clog2(AXI_DATA_WIDTH / 8);
  localparam integer COUNT_WIDTH = $clog2(FIFO_WRITE_DEPTH) + 1;
  localparam integer OUT_WIDTH = $clog2(MAX_OUTSTANDING + 1) + 1;

  reg int_arvalid_reg;
  reg [ADDR_WIDTH-1:0] int_addr_reg;
  reg [OUT_WIDTH-1:0] int_outstanding_reg;

  wire int_empty_wire, int_valid_wire;
  wire int_arvalid_wire, int_arready_wire;
  wire [COUNT_WIDTH-1:0] int_count_wire;
  wire [COUNT_WIDTH:0] int_reserved_wire;

  /* Espacio ya comprometido: lo que ya esta en el FIFO (int_count_wire)
   * mas lo que van a ocupar las rafagas en vuelo todavia no arribadas
   * (int_outstanding_reg * 16 beats). Solo se pide una rafaga nueva si,
   * aun reservando ese espacio, sigue quedando lugar para una rafaga mas
   * completa, y no se supero el maximo de rafagas en vuelo permitido. */
  assign int_reserved_wire = int_count_wire + (int_outstanding_reg << 4);
  assign int_valid_wire = (int_reserved_wire < FIFO_WRITE_DEPTH - 15) &
                          (int_outstanding_reg < MAX_OUTSTANDING);
  assign int_arvalid_wire = int_valid_wire | int_arvalid_reg;

  xpm_fifo_sync #(
    .WRITE_DATA_WIDTH(AXI_DATA_WIDTH),
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH),
    .READ_DATA_WIDTH(AXIS_TDATA_WIDTH),
    .READ_MODE("fwft"),
    .FIFO_READ_LATENCY(0),
    .FIFO_MEMORY_TYPE("block"),
    .USE_ADV_FEATURES("0004"),
    .WR_DATA_COUNT_WIDTH(COUNT_WIDTH)
  ) fifo_0 (
    .empty(int_empty_wire),
    .wr_data_count(int_count_wire),
    .rst(~aresetn),
    .wr_clk(aclk),
    .wr_en(m_axi_rvalid),
    .din(m_axi_rdata),
    .rd_en(m_axis_tready),
    .dout(m_axis_tdata)
  );

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_arvalid_reg <= 1'b0;
      int_addr_reg <= {(ADDR_WIDTH){1'b0}};
      int_outstanding_reg <= {(OUT_WIDTH){1'b0}};
    end
    else
    begin
      if(int_valid_wire)
      begin
        int_arvalid_reg <= 1'b1;
      end

      if(int_arvalid_wire & int_arready_wire)
      begin
        int_arvalid_reg <= 1'b0;
        int_addr_reg <= int_addr_reg < cfg_data ? int_addr_reg + 1'b1 : {(ADDR_WIDTH){1'b0}};
      end

      /* Contador de rafagas en vuelo: +1 cuando se acepta un AR nuevo,
       * -1 cuando llega el ultimo beat (rlast) de una rafaga. Si ambos
       * eventos ocurren en el mismo ciclo, se cancelan (caso 'default'
       * a continuacion, sin cambio neto). */
      case ({(int_arvalid_wire & int_arready_wire), (m_axi_rvalid & m_axi_rlast)})
        2'b10: int_outstanding_reg <= int_outstanding_reg + 1'b1;
        2'b01: int_outstanding_reg <= int_outstanding_reg - 1'b1;
        default: int_outstanding_reg <= int_outstanding_reg;
      endcase
    end
  end

  output_buffer #(
    .DATA_WIDTH(AXI_ADDR_WIDTH)
  ) buf_0 (
    .aclk(aclk), .aresetn(aresetn),
    .in_data(min_addr + {int_addr_reg, 4'd0, {(ADDR_SIZE){1'b0}}}),
    .in_valid(int_arvalid_wire), .in_ready(int_arready_wire),
    .out_data(m_axi_araddr),
    .out_valid(m_axi_arvalid), .out_ready(m_axi_arready)
  );

  assign sts_data = int_addr_reg;

  assign m_axi_arid = {(AXI_ID_WIDTH){1'b0}};
  assign m_axi_arlen = 4'd15;
  assign m_axi_arsize = ADDR_SIZE;
  assign m_axi_arburst = 2'b01;
  assign m_axi_arcache = 4'b1111;

  assign m_axi_rready = 1'b1;

  assign m_axis_tvalid = ~int_empty_wire;

endmodule