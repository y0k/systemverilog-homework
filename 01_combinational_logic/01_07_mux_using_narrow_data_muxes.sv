module mux_4_1_width_2
(
  input  [1:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [1:0] y
);

  assign y = sel [1] ? (sel [0] ? d3 : d2)
                     : (sel [0] ? d1 : d0);

endmodule

//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  wire [1:0] sel0, sel1;
  wire [1:0] y0, y1;
  
  mux_4_1_width_2 mux0 (
    .d0({d0[1], d0[0]}),
    .d1({d1[1], d1[0]}),
    .d2({d2[1], d2[0]}),
    .d3({d3[1], d3[0]}),
    .sel(sel[1:0]),
    .y(y0)
  );
  
  mux_4_1_width_2 mux1 (
    .d0({d0[3], d0[2]}),
    .d1({d1[3], d1[2]}),
    .d2({d2[3], d2[2]}),
    .d3({d3[3], d3[2]}),
    .sel(sel[1:0]),
    .y(y1)
  );
  
  assign y = {y1, y0};

  // TODO

  // Implement mux_4_1 with 4-bit data
  // using two instances of mux_4_1_width_2 with 2-bit data


endmodule

//----------------------------------------------------------------------------

module testbench;

  logic [3:0] d0, d1, d2, d3;
  logic [1:0] sel;
  logic [3:0] y;

  mux_4_1 inst
  (
    .d0  (d0), .d1 (d1), .d2 (d2), .d3 (d3),
    .sel (sel),
    .y   (y)
  );

  task test
    (
      input [3:0] td0, td1, td2, td3,
      input [1:0] tsel,
      input [3:0] ty
    );

    { d0, d1, d2, d3, sel } = { td0, td1, td2, td3, tsel };

    # 1;

    $display ("TEST d { %h %h %h %h } sel %d y %h",
        d0, d1, d2, d3, sel, y);

    if (y !== ty)
      begin
        $display ("%s FAIL: %h EXPECTED", `__FILE__, ty);
        $finish;
      end

  endtask

  initial
    begin
      test ('ha, 'hb, 'hc, 'hd, 0, 'ha);
      test ('ha, 'hb, 'hc, 'hd, 1, 'hb);
      test ('ha, 'hb, 'hc, 'hd, 2, 'hc);
      test ('ha, 'hb, 'hc, 'hd, 3, 'hd);

      test (7, 10, 3, 'x, 0, 7);
      test (7, 10, 3, 'x, 1, 10);
      test (7, 10, 3, 'x, 2, 3);
      test (7, 10, 3, 'x, 3, 'x);

      $display ("%s PASS", `__FILE__);
      $finish;
    end

endmodule
