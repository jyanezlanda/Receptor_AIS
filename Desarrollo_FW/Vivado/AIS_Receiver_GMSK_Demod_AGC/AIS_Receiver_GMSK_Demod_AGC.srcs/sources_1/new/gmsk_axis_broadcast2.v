// ============================================================
// gmsk_axis_broadcast2.v
//
// ============================================================

module gmsk_axis_broadcast2 #(
    parameter DATA_WIDTH = 24
) (
    input  wire        clk,
    input  wire        aresetn,

    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire        s_axis_tvalid,

    output wire [DATA_WIDTH-1:0] m0_axis_tdata,
    output wire        m0_axis_tvalid,

    output wire [DATA_WIDTH-1:0] m1_axis_tdata,
    output wire        m1_axis_tvalid
);
    assign m0_axis_tdata  = s_axis_tdata;
    assign m1_axis_tdata  = s_axis_tdata;
    assign m0_axis_tvalid = s_axis_tvalid;
    assign m1_axis_tvalid = s_axis_tvalid;
endmodule