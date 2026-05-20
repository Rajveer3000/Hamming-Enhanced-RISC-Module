// =============================================================================
// Module      : encoder
// Project     : HERM — Hamming Enhanced RISC Module
// Description : Hamming(12,8) encoder — encodes 8-bit data into a 12-bit
//               codeword by inserting 4 parity bits at positions 1, 2, 4, 8
//               (1-indexed). Capable of detecting and enabling correction of
//               any single-bit error in the transmitted codeword.
//
// Codeword bit layout (0-indexed, LSB = index 0):
//   [0]  = P1  (parity, covers positions 1,3,5,7,9,11)
//   [1]  = P2  (parity, covers positions 2,3,6,7,10,11)
//   [2]  = data[0]
//   [3]  = P4  (parity, covers positions 4,5,6,7,12)
//   [4]  = data[1]
//   [5]  = data[2]
//   [6]  = data[3]
//   [7]  = P8  (parity, covers positions 8,9,10,11,12)
//   [8]  = data[4]
//   [9]  = data[5]
//   [10] = data[6]
//   [11] = data[7]
// =============================================================================

module encoder (
    input  [7:0]  data,
    output [11:0] codeword
);

    wire P1, P2, P4, P8;

    // Even parity: each parity bit XORs all data bits at positions it covers
    assign P1 = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
    assign P2 = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
    assign P4 = data[1] ^ data[2] ^ data[3] ^ data[7];
    assign P8 = data[4] ^ data[5] ^ data[6] ^ data[7];

    // Assemble codeword: interleave parity bits at power-of-2 positions
    assign codeword = {data[7:4], P8, data[3:1], P4, data[0], P2, P1};

endmodule
