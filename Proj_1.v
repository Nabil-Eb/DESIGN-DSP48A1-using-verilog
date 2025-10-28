module DSP48A1 #(
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,
    parameter CREG = 1,
    parameter DREG = 1,
    parameter MREG = 1,
    parameter PREG = 1,
    parameter CARRYINREG = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,
    parameter RSTTYPE = "SYNC", // "SYNC" or "ASYNC"
    parameter CARRYINSEL = "OPMODE5", // "CARRYIN" or "OPMODE5"
    parameter B_INPUT = "DIRECT" // "DIRECT" or "CASCADE"
)(
    input CLK,
    input [17:0] A, B, D,
    input [47:0] C,
    input [47:0] PCIN,
    input [17:0] BCIN,
    input [7:0] OPMODE,
    input CARRYIN,
    input CEA, CEB, CEC, CED, CEM, CEOPMODE, CEP, CECARRYIN,
    input RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN,
    output [35:0] M,
    output [47:0] P,
    output CARRYOUT,
    output [47:0] PCOUT,
    output [17:0] BCOUT,
    output CARRYOUTF
);

wire [17:0] A0, A1, B0, B1, D_reg, pre_add, pmux1;
wire [47:0] C_reg,P_past;
wire [7:0]  OPMODE_reg;
wire [35:0] mult;
wire CARRY,CIN,CO;
wire [48:0] post_add;
reg [47:0] X,Z;
register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(A0REG)) m1 ( .CLK(CLK), .RST(RSTA), .CE(CEA), .D(A), .Q(A0) );

generate
    if(B_INPUT == "DIRECT") begin
        register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(B0REG)) m2 ( .CLK(CLK), .RST(RSTB), .CE(CEB), .D(B), .Q(B0) );
    end
    else if(B_INPUT == "CASCADE") begin
        register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(B0REG)) m2 ( .CLK(CLK), .RST(RSTB), .CE(CEB), .D(BCIN), .Q(B0) );
    end
    else begin
        register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(B0REG)) m2 ( .CLK(CLK), .RST(RSTB), .CE(CEB), .D(0), .Q(B0) );
    end
endgenerate

register #(.WIDTH(48), .RSTTYPE(RSTTYPE), .REG(CREG)) m3 ( .CLK(CLK), .RST(RSTC), .CE(CEC), .D(C), .Q(C_reg) );
register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(DREG)) m4 ( .CLK(CLK), .RST(RSTD), .CE(CED), .D(D), .Q(D_reg) );
register #(.WIDTH(8), .RSTTYPE(RSTTYPE), .REG(OPMODEREG)) m5 ( .CLK(CLK), .RST(RSTOPMODE), .CE(CEOPMODE), .D(OPMODE), .Q(OPMODE_reg) );

assign pre_add = (OPMODE_reg[6]==1'b0) ?  D_reg + B0 : D_reg - B0;
assign pmux1   = (OPMODE_reg[4]==1'b0) ? B0 : pre_add;

register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(B1REG)) m6 ( .CLK(CLK), .RST(RSTB), .CE(CEB), .D(pmux1), .Q(B1) );
register #(.WIDTH(18), .RSTTYPE(RSTTYPE), .REG(A1REG)) m7 ( .CLK(CLK), .RST(RSTA), .CE(CEA), .D(A0), .Q(A1) );
assign BCOUT = B1;
assign mult = A1 * B1;
register #(.WIDTH(36), .RSTTYPE(RSTTYPE), .REG(MREG)) m8 ( .CLK(CLK), .RST(RSTM), .CE(CEM), .D(mult), .Q(M) );
assign CARRY= (CARRYINSEL=="OPMODE5") ? OPMODE_reg[5] : (CARRYINSEL=="CARRYIN") ? CARRYIN : 1'b0;
register #(.WIDTH(1), .RSTTYPE(RSTTYPE), .REG(CARRYINREG)) m9 ( .CLK(CLK), .RST(RSTCARRYIN), .CE(CECARRYIN), .D(CARRY), .Q(CIN) );

always @(*) begin
    case (OPMODE_reg[1:0])
        2'b00: X = 48'd0;
        2'b01: X = {12'd0, M};
        2'b10: X = P;
        2'b11: X = {D_reg[11:0], A1[17:0], B1[17:0]};
    endcase
    case (OPMODE_reg[3:2])
        2'b00: Z = 48'd0;
        2'b01: Z = PCIN;
        2'b10: Z = P;
        2'b11: Z = C_reg;
    endcase
end
assign post_add = (OPMODE_reg[7]==1'b0) ? (X+Z+CIN) : (Z-X-CIN);
assign P_past = post_add[47:0];
assign CO = post_add[48];
register #(.WIDTH(48), .RSTTYPE(RSTTYPE), .REG(PREG)) m10 ( .CLK(CLK), .RST(RSTP), .CE(CEP), .D(P_past), .Q(P) );
register #(.WIDTH(1), .RSTTYPE(RSTTYPE), .REG(CARRYOUTREG)) m11 ( .CLK(CLK), .RST(RSTCARRYIN), .CE(CECARRYIN), .D(CO), .Q(CARRYOUT) );
assign CARRYOUTF = CARRYOUT;
assign PCOUT = P;

endmodule