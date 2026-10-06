// Implementation of a 8:1 multiplexor using mux4_1 and mux2_1 modules
module mux8_1 (
  input  logic i000, i001, i010, i011, i100, i101, i110, i111,
  input  logic sel0, sel1, sel2,
  output logic out
  );

  logic v0, v1;

  mux4_1 m0(.i00(i000), .i01(i001), .i10(i010), .i11(i011), .sel0, .sel1, .out(v0));
  mux4_1 m1(.i00(i100), .i01(i101), .i10(i110), .i11(i111), .sel0, .sel1, .out(v1));
  
  mux2_1 m (.i0(v0), .i1(v1), .sel(sel2), .out(out));
  
endmodule  // mux8_1
