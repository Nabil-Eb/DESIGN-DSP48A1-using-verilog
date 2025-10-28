module register #(
    parameter WIDTH = 18,
    parameter RSTTYPE = "SYNC",
    parameter REG = 1
)(
    input wire CLK,
    input wire RST,
    input wire CE,
    input wire [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q
);

generate
    if (REG == 1) begin
        // SYNC RESET
        if (RSTTYPE == "SYNC") begin : sync_block
            always @(posedge CLK) begin
                if (RST)
                    Q <= 0;
                else if (CE)
                    Q <= D;
            end
        end
        // ASYNC RESET
        else begin : async_block
            always @(posedge CLK or posedge RST) begin
                if (RST)
                    Q <= 0;
                else if (CE)
                    Q <= D;
            end
        end
    end
    else begin : bypass_block
        always @(*) begin
            Q = D;
        end
    end
endgenerate

endmodule
