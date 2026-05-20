// =============================================================================
// Module      : herm_top
// Project     : HERM — Hamming Enhanced RISC Module
// Description : Top-level wrapper connecting the encoder and decoder through
//               a simulated noisy channel. The injected_error input allows
//               fault injection for verification — set to 12'b0 for clean
//               transmission. Any single bit flip in injected_error is
//               automatically detected and corrected by the decoder.
//
// Port Summary:
//   data_in        [7:0]   — Original 8-bit data to transmit
//   injected_error [11:0]  — Bitmask of channel errors (12'b0 = no error)
//   data_out       [7:0]   — Recovered 8-bit data after error correction
//   codeword       [11:0]  — Encoded 12-bit codeword (encoder output)
//   rx_codeword    [11:0]  — Received codeword after channel noise
// =============================================================================

module herm_top (
    input  [7:0]  data_in,
    input  [11:0] injected_error,
    output [7:0]  data_out,
    output [11:0] codeword,
    output [11:0] rx_codeword
);

    wire [11:0] encoded;

    encoder enc (
        .data     (data_in),
        .codeword (encoded)
    );

    assign codeword    = encoded;
    assign rx_codeword = encoded ^ injected_error;

    decoder dec (
        .codeword (rx_codeword),
        .data     (data_out)
    );

endmodule
