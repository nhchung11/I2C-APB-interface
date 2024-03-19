`ifndef STI
`define STI

class stimulus;
  rand  bit value;
  constraint distribution {value dist { 0  := 1 , 1 := 1 }; } 
endclass
`endif