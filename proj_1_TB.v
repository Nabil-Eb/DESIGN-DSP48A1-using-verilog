module DSP48A1_TB();
localparam A0REG = 0;
localparam A1REG = 1;
localparam B0REG = 0;
localparam B1REG = 1;
localparam CREG = 1;
localparam DREG = 1;
localparam MREG = 1;
localparam PREG = 1;
localparam CARRYINREG = 1;
localparam CARRYOUTREG = 1;
localparam OPMODEREG = 1;
localparam CARRYINSEL = "OPMODE5";
localparam B_INPUT = "DIRECT";
localparam RSTTYPE = "SYNC";
reg CLK;
reg RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN;
reg CEA, CEB, CEC, CED, CEM, CEOPMODE, CEP, CECARRYIN;
reg [17:0] A, B, D, BCIN;
reg [47:0] C, PCIN;
reg [7:0] OPMODE;
reg CARRYIN;

wire [35:0] M;
wire [47:0] P, PCOUT;
wire [17:0] BCOUT;
wire CARRYOUT, CARRYOUTF;

DSP48A1 #(
    .A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
    .CREG(CREG), .DREG(DREG), .MREG(MREG), .PREG(PREG),
    .CARRYINREG(CARRYINREG), .CARRYOUTREG(CARRYOUTREG),
    .OPMODEREG(OPMODEREG), .CARRYINSEL(CARRYINSEL), .B_INPUT(B_INPUT),
    .RSTTYPE(RSTTYPE)
) dut (
    .CLK(CLK),
    .A(A), .B(B), .C(C), .D(D), .BCIN(BCIN), .PCIN(PCIN),
    .CARRYIN(CARRYIN),
    .CEA(CEA), .CEB(CEB), .CEC(CEC), .CED(CED), .CEM(CEM), .CEOPMODE(CEOPMODE),
    .CEP(CEP), .CECARRYIN(CECARRYIN),
    .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTD(RSTD), .RSTM(RSTM),
    .RSTOPMODE(RSTOPMODE), .RSTP(RSTP), .RSTCARRYIN(RSTCARRYIN),
    .M(M), .P(P), .CARRYOUT(CARRYOUT), .PCOUT(PCOUT), .BCOUT(BCOUT), .CARRYOUTF(CARRYOUTF)
    ,.OPMODE(OPMODE)
);

initial begin
    CLK=0;
    forever #1 CLK = ~CLK;
end

initial begin
     {RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN} = 8'b11111111;
    {CEA, CEB, CEC, CED, CEM, CEOPMODE, CEP, CECARRYIN} = 8'b0;
    {A, B, C, D, BCIN, PCIN} = 0;
    CARRYIN = 0;
    OPMODE = 0;

    //2.1 Reset
    @(negedge CLK);

    if (P !== 0 || M !== 0 || CARRYOUT !== 0) $display("Reset test failed");
    else $display("Reset test passed");

    {RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN} = 8'b00000000;
    {CEA, CEB, CEC, CED, CEM, CEOPMODE, CEP, CECARRYIN} = 8'b11111111;

    //2.2 path 1
    OPMODE= 8'b11011101;
    A=18'd20; B=18'd10; C=48'd350; D=18'd25;
    BCIN = $urandom % 262144; PCIN = ({$urandom, $urandom} % (1 << 48)); CARRYIN = $urandom % 2;
    repeat(4) @(negedge CLK);
    if (BCOUT !== 18'hf || M !== 36'h12c || P !== 48'h32 || PCOUT!== 48'h32 || CARRYOUT !== 0 || CARRYOUTF !== 0)
        $display("Path 1 failed");
    else $display("Path 1 passed");

     //2.3 Path 2
    A = 18'd20; B = 18'd10; C = 48'd350; D = 18'd25; OPMODE = 8'b00010000;
    BCIN = $urandom % 262144; PCIN = ({$urandom, $urandom} % (1 << 48)) ; CARRYIN = $urandom % 2;
    repeat (3) @(negedge CLK);
    if (BCOUT !== 18'h23 || M !== 36'h2bc || P !== 48'd0 || PCOUT!== 48'd0 || CARRYOUT !== 0 || CARRYOUTF !== 0)
        $display("Path 2 failed");
    else $display("Path 2 passed");

    //2.4 Path 3 
    A = 18'd20; B = 18'd10; C = 48'd350; D = 18'd25; OPMODE = 8'b00001010;
    BCIN = $urandom % 262144; PCIN = ({$urandom, $urandom} % (1 << 48)); CARRYIN = $urandom % 2;
    repeat (3) @(negedge CLK);
    if (BCOUT !== 18'ha || M !== 36'hc8 || P !== 48'd0 || PCOUT!== 48'd0 || CARRYOUT !== 0 || CARRYOUTF !== 0)
    $display("Path 3 failed");
    else $display("Path 3 passed");

    //2.5 Path 4
    A = 18'd5; B = 18'd6; C = 48'd350; D = 18'd25; PCIN = 48'd3000; OPMODE = 8'b10100111;
    BCIN = $urandom % 262144; CARRYIN = $urandom % 2;
    repeat (3) @(negedge CLK);
    if (BCOUT !== 18'h6 || M !== 36'h1e || P !== 48'hfe6fffec0bb1 || PCOUT!== 48'hfe6fffec0bb1 || CARRYOUT !== 1 || CARRYOUTF !== 1)
        $display("Path 4 failed");
    else $display("Path 4 passed");

    $display("Simulation complete.");

    $finish;

end

endmodule