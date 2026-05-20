`timescale 1ns / 1ps
// =============================================================================
// Module      : herm_tb
// Project     : HERM — Hamming Enhanced RISC Module
// Description : Self-checking testbench for the HERM encoder-decoder pipeline.
//               Verifies three fault injection scenarios:
//                 1. Clean transmission (no error)
//                 2. Single data bit flip
//                 3. Single parity bit flip
//               All three cases should produce STATUS: PASS.
// =============================================================================

module herm_tb ();

    // -----------------------------------------------------------------------
    // DUT signals
    // -----------------------------------------------------------------------
    reg  [7:0]  data_in;
    wire [11:0] encoder_out;
    reg  [11:0] noisy_channel;
    wire [7:0]  data_out;

    // -----------------------------------------------------------------------
    // Instantiate encoder and decoder
    // -----------------------------------------------------------------------
    encoder dut_enc (
        .data     (data_in),
        .codeword (encoder_out)
    );

    decoder dut_dec (
        .codeword (noisy_channel),
        .data     (data_out)
    );

    // -----------------------------------------------------------------------
    // Stimulus
    // -----------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    initial begin
        pass_count   = 0;
        fail_count   = 0;
        noisy_channel = 12'b0;

        $display("================================================");
        $display("   HERM SYSTEM VERIFICATION");
        $display("   Hamming(12,8) Encoder-Decoder Pipeline");
        $display("================================================\n");

        // -------------------------------------------------------------------
        // TEST 1: Clean transmission — no errors injected
        // -------------------------------------------------------------------
        data_in       = 8'h41;       // ASCII 'A'
        #20;
        noisy_channel = encoder_out; // Perfect channel
        #20;

        $display("[TIME: %0t ns] TEST 1: NO NOISE", $time);
        $display("  TX Data    : 0x%h  (%b)", data_in, data_in);
        $display("  Codeword   : %b", encoder_out);
        $display("  RX Codeword: %b", noisy_channel);
        $display("  RX Data    : 0x%h  (%b)", data_out, data_out);

        if (data_out == data_in) begin
            $display("  STATUS     : PASS — Data Intact\n");
            pass_count = pass_count + 1;
        end else begin
            $display("  STATUS     : FAIL\n");
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------------------
        // TEST 2: Single data bit flip — bit index 5 (data bit position)
        // -------------------------------------------------------------------
        #40;
        data_in       = 8'hAA;
        #20;
        noisy_channel = encoder_out ^ 12'b000000100000; // Flip codeword[5]
        #20;

        $display("[TIME: %0t ns] TEST 2: SINGLE DATA BIT FLIP (codeword index 5)", $time);
        $display("  TX Data      : 0x%h  (%b)", data_in, data_in);
        $display("  TX Codeword  : %b", encoder_out);
        $display("  RX Codeword  : %b  (bit 5 flipped)", noisy_channel);
        $display("  Syndrome     : %b  (= decimal %0d → error at position %0d)",
                 dut_dec.syndrome, dut_dec.syndrome, dut_dec.syndrome);
        $display("  RX Data      : 0x%h  (%b)", data_out, data_out);

        if (data_out == data_in) begin
            $display("  STATUS       : PASS — Single-Bit Error Corrected\n");
            pass_count = pass_count + 1;
        end else begin
            $display("  STATUS       : FAIL\n");
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------------------
        // TEST 3: Parity bit flip — P4 at codeword index 3
        // -------------------------------------------------------------------
        #40;
        data_in       = 8'hF0;
        #20;
        noisy_channel = encoder_out ^ 12'b000000001000; // Flip codeword[3] = P4
        #20;

        $display("[TIME: %0t ns] TEST 3: PARITY BIT FLIP (P4 at codeword index 3)", $time);
        $display("  TX Data      : 0x%h  (%b)", data_in, data_in);
        $display("  TX Codeword  : %b", encoder_out);
        $display("  RX Codeword  : %b  (P4 flipped)", noisy_channel);
        $display("  Syndrome     : %b  (= decimal %0d → error at position %0d)",
                 dut_dec.syndrome, dut_dec.syndrome, dut_dec.syndrome);
        $display("  RX Data      : 0x%h  (%b)", data_out, data_out);

        if (data_out == data_in) begin
            $display("  STATUS       : PASS — Parity Bit Error Handled\n");
            pass_count = pass_count + 1;
        end else begin
            $display("  STATUS       : FAIL\n");
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------------------
        // Summary
        // -------------------------------------------------------------------
        $display("================================================");
        $display("   VERIFICATION COMPLETE");
        $display("   PASSED: %0d / 3    FAILED: %0d / 3", pass_count, fail_count);
        $display("================================================\n");

        $finish;
    end

endmodule
