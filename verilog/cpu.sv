import wires::*;

module cpu
(
  input logic rst,
  input logic clk,
  output logic [0  : 0] memory_valid,
  output logic [0  : 0] memory_instr,
  output logic [31 : 0] memory_addr,
  output logic [31 : 0] memory_wdata,
  output logic [3  : 0] memory_wstrb,
  input logic [31  : 0] memory_rdata,
  input logic [0   : 0] memory_ready,
  input logic [0   :0] extern_irpt,
  input logic [0   :0] timer_irpt,
  input logic [0   :0] soft_irpt
);
  timeunit 1ns;
  timeprecision 1ps;

  agu_in_type agu_in;
  agu_out_type agu_out;
  alu_in_type alu_in;
  alu_out_type alu_out;
  bcu_in_type bcu_in;
  bcu_out_type bcu_out;
  lsu_in_type lsu_in;
  lsu_out_type lsu_out;
  csr_alu_in_type csr_alu_in;
  csr_alu_out_type csr_alu_out;
  muldiv_in_type muldiv_in;
  muldiv_out_type muldiv_out;
  decoder_in_type decoder_in;
  decoder_out_type decoder_out;
  compress_in_type compress_in;
  compress_out_type compress_out;
  forwarding_in_type forwarding_in;
  forwarding_out_type forwarding_out;
  csr_in_type csr_in;
  csr_out_type csr_out;
  register_in_type register_in;
  register_out_type register_out;
  fetch_in_type fetch_in;
  decode_in_type decode_in;
  execute_in_type execute_in;
  fetch_out_type fetch_out;
  decode_out_type decode_out;
  execute_out_type execute_out;
  prefetch_in_type prefetch_in;
  prefetch_out_type prefetch_out;
  mem_in_type imem_in;
  mem_out_type imem_out;
  mem_in_type dmem_in;
  mem_out_type dmem_out;

  assign fetch_in.f = fetch_out;
  assign fetch_in.d = decode_out;
  assign fetch_in.e = execute_out;
  assign decode_in.f = fetch_out;
  assign decode_in.d = decode_out;
  assign decode_in.e = execute_out;
  assign execute_in.f = fetch_out;
  assign execute_in.d = decode_out;
  assign execute_in.e = execute_out;

  agu agu_comp
  (
    .agu_in (agu_in),
    .agu_out (agu_out)
  );

  alu alu_comp
  (
    .alu_in (alu_in),
    .alu_out (alu_out)
  );

  bcu bcu_comp
  (
    .bcu_in (bcu_in),
    .bcu_out (bcu_out)
  );

  lsu lsu_comp
  (
    .lsu_in (lsu_in),
    .lsu_out (lsu_out)
  );

  csr_alu csr_alu_comp
  (
    .csr_alu_in (csr_alu_in),
    .csr_alu_out (csr_alu_out)
  );

  muldiv muldiv_comp
  (
    .rst (rst),
    .clk (clk),
    .muldiv_in (muldiv_in),
    .muldiv_out (muldiv_out)
  );

  forwarding forwarding_comp
  (
    .forwarding_in (forwarding_in),
    .forwarding_out (forwarding_out)
  );

  decoder decoder_comp
  (
    .decoder_in (decoder_in),
    .decoder_out (decoder_out)
  );

  compress compress_comp
  (
    .compress_in (compress_in),
    .compress_out (compress_out)
  );

  register register_comp
  (
    .rst (rst),
    .clk (clk),
    .register_in (register_in),
    .register_out (register_out)
  );

  csr csr_comp
  (
    .rst (rst),
    .clk (clk),
    .csr_in (csr_in),
    .csr_out (csr_out),
    .extern_irpt (extern_irpt),
    .timer_irpt (timer_irpt),
    .soft_irpt (soft_irpt)
  );

  arbiter arbiter_comp
  (
    .rst (rst),
    .clk (clk),
    .imem_in (imem_in),
    .imem_out (imem_out),
    .dmem_in (dmem_in),
    .dmem_out (dmem_out),
    .memory_valid (memory_valid),
    .memory_instr (memory_instr),
    .memory_addr (memory_addr),
    .memory_wdata (memory_wdata),
    .memory_wstrb (memory_wstrb),
    .memory_rdata (memory_rdata),
    .memory_ready (memory_ready)
  );

  prefetch prefetch_comp
  (
    .rst (rst),
    .clk (clk),
    .prefetch_in (prefetch_in),
    .prefetch_out (prefetch_out)
  );

  fetch_stage fetch_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .csr_out (csr_out),
    .prefetch_out (prefetch_out),
    .prefetch_in (prefetch_in),
    .imem_out (imem_out),
    .imem_in (imem_in),
    .d (fetch_in),
    .q (fetch_out)
  );

  decode_stage decode_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .decoder_out (decoder_out),
    .decoder_in (decoder_in),
    .compress_out (compress_out),
    .compress_in (compress_in),
    .agu_out (agu_out),
    .agu_in (agu_in),
    .bcu_out (bcu_out),
    .bcu_in (bcu_in),
    .register_out (register_out),
    .register_in (register_in),
    .forwarding_out (forwarding_out),
    .forwarding_in (forwarding_in),
    .csr_out (csr_out),
    .csr_in (csr_in),
    .dmem_in (dmem_in),
    .d (decode_in),
    .q (decode_out)
  );

  execute_stage execute_stage_comp
  (
    .rst (rst),
    .clk (clk),
    .alu_out (alu_out),
    .alu_in (alu_in),
    .lsu_out (lsu_out),
    .lsu_in (lsu_in),
    .csr_alu_out (csr_alu_out),
    .csr_alu_in (csr_alu_in),
    .muldiv_out (muldiv_out),
    .muldiv_in (muldiv_in),
    .register_in (register_in),
    .forwarding_in (forwarding_in),
    .csr_out (csr_out),
    .csr_in (csr_in),
    .dmem_out (dmem_out),
    .d (execute_in),
    .q (execute_out)
  );

endmodule
