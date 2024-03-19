module dff(clk,reset,din,dout);
          input clk,reset,din;
          output dout;
          logic dout;
          
          always@(posedge clk,negedge reset)
               if(!reset)
                   dout <= 0;
               else
                   dout <= din;
endmodule
     
module ones_counter(clk,reset,data,count);
           input clk,reset,data;
           output [0:3] count;
         
           dff d1(clk,reset,data,count[0]);
           dff d2(count[0],reset,~count[1],count[1]);
           dff d3(count[1],reset,~count[2],count[2]);
           dff d4(count[2],reset,~count[3],count[3]);
         
endmodule
                  