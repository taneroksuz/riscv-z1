import wires::*;

module fetch_stage
(
  input logic rst,
  input logic clk,
  input mem_out_type imem_out,
  output mem_in_type imem_in,
  input fetch_in_type d,
  output fetch_out_type q
);

  fetch_reg_type r,rin;
  fetch_reg_type v;

  always_comb begin

    v = r;

    v.valid = ~d.e.clear;
    v.stall = ~imem_out.mem_ready | d.d.stall | d.e.stall | d.e.clear;
    v.instr = imem_out.mem_rdata;

    if (d.d.jump == 1) begin
      v.pc = d.d.address;
    end else if (v.stall == 0) begin
      v.pc = v.pc + 4;
    end

    imem_in.mem_valid = v.valid;
    imem_in.mem_instr = 1;
    imem_in.mem_addr = v.pc;
    imem_in.mem_wdata = 0;
    imem_in.mem_wstrb = 0;

    rin = v;

    q.pc = r.pc;
    q.instr = v.instr;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;

  end

  always_ff @(posedge clk) begin
    if (rst) begin
      r <= init_fetch_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
