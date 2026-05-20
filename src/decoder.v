// =============================================================================
// Module      : decoder
// Project     : HERM — Hamming Enhanced RISC Module
// Description : Hamming(12,8) decoder — receives a 12-bit codeword, computes
//               a 4-bit syndrome to locate any single-bit error, corrects it,
//               and extracts the original 8-bit data.
//
// Syndrome interpretation:
//   syndrome = 0000 → No error
//   syndrome = N    → Error at codeword bit position N (1-indexed),
//                     i.e., codeword[N-1] is flipped and corrected.
// =============================================================================

module decoder (
    input  [11:0] codeword,
    output [7:0]  data
);

    // ------------------------------------------------------------------
    // Step 1: Recompute parity bits from received data positions only
    //         (excludes the stored parity bit itself — compared separately)
    // ------------------------------------------------------------------
    wire p1_calc, p2_calc, p4_calc, p8_calc;

    assign p1_calc = codeword[2]  ^ codeword[4]  ^ codeword[6]  ^
                     codeword[8]  ^ codeword[10];

    assign p2_calc = codeword[2]  ^ codeword[5]  ^ codeword[6]  ^
                     codeword[9]  ^ codeword[10];

    assign p4_calc = codeword[4]  ^ codeword[5]  ^ codeword[6]  ^
                     codeword[11];

    assign p8_calc = codeword[8]  ^ codeword[9]  ^ codeword[10] ^
                     codeword[11];

    // ------------------------------------------------------------------
    // Step 2: Build syndrome — each bit is 1 if computed parity
    //         mismatches stored parity bit in received codeword
    // ------------------------------------------------------------------
    wire [3:0] syndrome;

    assign syndrome[0] = p1_calc ^ codeword[0];   // P1 stored at index 0
    assign syndrome[1] = p2_calc ^ codeword[1];   // P2 stored at index 1
    assign syndrome[2] = p4_calc ^ codeword[3];   // P4 stored at index 3
    assign syndrome[3] = p8_calc ^ codeword[7];   // P8 stored at index 7

    // ------------------------------------------------------------------
    // Step 3: Correct the error — flip the bit at position (syndrome)
    //         syndrome is a 4-bit value = 1-indexed error position
    // ------------------------------------------------------------------
    reg [11:0] corrected_codeword;

    always @(*) begin
        corrected_codeword = codeword;
        if (syndrome != 4'b0000) begin
            // syndrome gives the 1-indexed position of the erroneous bit
            corrected_codeword[syndrome - 1] = ~codeword[syndrome - 1];
        end
    end

    // ------------------------------------------------------------------
    // Step 4: Extract original 8 data bits from corrected codeword
    //         (strips out parity bits at positions 1,2,4,8 → indices 0,1,3,7)
    // ------------------------------------------------------------------
    assign data = {
        corrected_codeword[11],   // data[7]
        corrected_codeword[10],   // data[6]
        corrected_codeword[9],    // data[5]
        corrected_codeword[8],    // data[4]
        corrected_codeword[6],    // data[3]
        corrected_codeword[5],    // data[2]
        corrected_codeword[4],    // data[1]
        corrected_codeword[2]     // data[0]
    };

endmodule
