module rot_phase_gen #(
    parameter ACC_WIDTH = 23,
    parameter OUT_WIDTH = 24
) (
    input  wire                 aclk,
    input  wire                 aresetn,
    input  wire [ACC_WIDTH-1:0] pinc,
    output wire [OUT_WIDTH-1:0] m_axis_tdata,
    output wire                 m_axis_tvalid,
    input  wire                 m_axis_tready
);
    reg [ACC_WIDTH-1:0] fase;
    assign m_axis_tvalid = aresetn;
    assign m_axis_tdata  = {{(OUT_WIDTH - ACC_WIDTH){fase[ACC_WIDTH-1]}}, fase};

    always @(posedge aclk) begin
        if (!aresetn)           fase <= {ACC_WIDTH{1'b0}};
        else if (m_axis_tready) fase <= fase + pinc;
    end
endmodule