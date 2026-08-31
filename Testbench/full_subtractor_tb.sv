`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: full_subtractor_tb.sv
// Description: 
//Self-checking testbench for full_subtractor.
//Exhaustively tests all 8 input combinations (a, b, bin) and compares DUT output against an independently computed 
//expected result, reporting PASS/FAIL and a final summary.
//////////////////////////////////////////////////////////////////////////////////
module tb_full_subtractor;
    logic a, b, bin;
    logic diff, bout;

    logic [1:0]expected;   // {expected_bout, expected_diff}
    int pass_count;
    int fail_count;

  full_subtractor dut ( .a(a), .b(b), .bin(bin), .diff(diff), .bout(bout));

    // Reference model: full binary subtraction (a - b - bin), independent of DUT logic
    //'automatic' keyword allows function to be reentrant
    function automatic [1:0]expected_result(input logic a_i, b_i, bin_i);
        logic signed [2:0] result;
        begin
            result = a_i - b_i - bin_i ;   // range of possible outcomes: -2....1
            expected_result = {result[1], result[0]}; // {borrow, diff} for 1-bit sub
        end
    endfunction

    task automatic run_check(input logic a_i, b_i, bin_i);
        begin
            a = a_i; 
            b = b_i; 
            bin = bin_i;
            #10;
            expected = expected_result(a_i, b_i, bin_i);

            if ({bout, diff} === expected) begin
                pass_count++;
                $display("PASS | a=%0b b=%0b bin=%0b | diff=%0b bout=%0b (expected diff=%0b bout=%0b)",a,b,bin,diff,bout,expected[0],expected[1]);
            end else begin
                fail_count++;
                $display("FAIL | a=%0b b=%0b bin=%0b | diff=%0b bout=%0b (expected diff=%0b bout=%0b)",a,b,bin,diff,bout,expected[0],expected[1]);
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        for (int i = 0; i < 8; i++) begin
            run_check(i[2], i[1], i[0]);
        end

        $display("-------------------------------------------------------------");
        $display("TOTAL: %0d  PASS: %0d  FAIL: %0d", pass_count + fail_count, pass_count, fail_count);
        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TEST(S) FAILED", fail_count);

        $finish;
    end

endmodule
