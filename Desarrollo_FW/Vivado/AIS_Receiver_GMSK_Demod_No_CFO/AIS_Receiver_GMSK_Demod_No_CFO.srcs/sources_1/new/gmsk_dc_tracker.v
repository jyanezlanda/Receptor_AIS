module gmsk_dc_tracker #(
    parameter DATA_WIDTH = 24,
    parameter SHIFT      = 5
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire signed [DATA_WIDTH-1:0] s_axis_soft_tdata,
    input  wire        s_axis_soft_tvalid,

    output reg  signed [DATA_WIDTH-1:0] dc_tdata,
    output reg         dc_tvalid
);

    reg signed [DATA_WIDTH+SHIFT-1:0] acc;

    wire signed [DATA_WIDTH-1:0] dc_actual = acc[DATA_WIDTH+SHIFT-1:SHIFT];
    wire signed [DATA_WIDTH:0]   error     = s_axis_soft_tdata - dc_actual;   // 1 bit extra: soft-dc puede exceder DATA_WIDTH bits

    always @(posedge clk) begin
        if (!aresetn) begin
            acc      <= {(DATA_WIDTH+SHIFT){1'b0}};
            dc_tvalid <= 1'b0;
        end else if (s_axis_soft_tvalid) begin
            acc      <= acc + error;
            dc_tdata  <= dc_actual;
            dc_tvalid <= 1'b1;
        end else begin
            dc_tvalid <= 1'b0;
        end
    end

endmodule
