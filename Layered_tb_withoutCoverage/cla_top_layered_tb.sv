`timescale 1ns/1ns

// Interface definition
interface cla_if(input clk);
  logic [15:0] a, b;
  logic cin;
  logic [15:0] sum;
  logic carry_out16;

  clocking driver_cb @(negedge clk);
    default input #1 output #1;
    output a, b, cin;
  endclocking

  clocking mon_cb @(negedge clk);
    default input #1 output #1;
    input a, b, cin, sum, carry_out16;
  endclocking

  modport DRIVER (clocking driver_cb, input clk);
  modport MONITOR (clocking mon_cb, input clk);
endinterface

// Transaction class definition
class transaction;
  rand bit [15:0] a, b;
  rand bit cin;
  bit [15:0] sum;
  bit carry_out16;

  function bit compare(transaction other);
    return (this.a == other.a) && (this.b == other.b) &&
           (this.cin == other.cin) && (this.sum == other.sum) &&
           (this.carry_out16 == other.carry_out16);
  endfunction
endclass

// Generator class definition
class generator;
  mailbox gen2driv;
  transaction g_trans;

  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction

  task main(input int count);
    repeat(count) begin
      g_trans = new();
      assert(g_trans.randomize());
      gen2driv.put(g_trans);
    end
  endtask
endclass

// Driver class definition
class driver;
  mailbox gen2driv, driv2sb;
  virtual cla_if.DRIVER claif;
  transaction d_trans;
  event driven;

  function new(mailbox gen2driv, driv2sb, virtual cla_if.DRIVER claif, event driven);
    this.gen2driv = gen2driv;
    this.claif = claif;
    this.driven = driven;
    this.driv2sb = driv2sb;
  endfunction

  task main(input int count);
    repeat(count) begin
      d_trans = new();
      gen2driv.get(d_trans);

      @(claif.driver_cb);
      claif.driver_cb.a <= d_trans.a;
      claif.driver_cb.b <= d_trans.b;
      claif.driver_cb.cin <= d_trans.cin;

      driv2sb.put(d_trans);
      -> driven;
    end
  endtask
endclass

// Monitor class definition
class monitor;
  mailbox mon2sb;
  virtual cla_if.MONITOR claif;
  transaction m_trans;
  event driven;

  function new(mailbox mon2sb, virtual cla_if.MONITOR claif, event driven);
    this.mon2sb = mon2sb;
    this.claif = claif;
    this.driven = driven;
  endfunction

  task main(input int count);
    @(driven);

    @(claif.mon_cb);
    repeat(count) begin
      m_trans = new();
      @(posedge claif.clk);
      m_trans.sum = claif.mon_cb.sum;
      m_trans.carry_out16 = claif.mon_cb.carry_out16;
      m_trans.a = claif.mon_cb.a;
      m_trans.b = claif.mon_cb.b;
      m_trans.cin = claif.mon_cb.cin;
      mon2sb.put(m_trans);
    end
  endtask
endclass

// Scoreboard class definition
class scoreboard;
  mailbox driv2sb, mon2sb;
  transaction d_trans, m_trans;
  event driven;
  int pass, fail;

  function new(mailbox driv2sb, mon2sb);
    this.driv2sb = driv2sb;
    this.mon2sb = mon2sb;
  endfunction

  task main(input int count);
    $display("------------------Scoreboard Test Starts--------------------");
    repeat(count) begin
      // Get the expected inputs first
      d_trans = new();
      driv2sb.get(d_trans);

      // Calculate expected result
      {d_trans.carry_out16, d_trans.sum} = d_trans.a + d_trans.b + d_trans.cin;

      // Now get the actual results
      m_trans = new();
      mon2sb.get(m_trans);

      if(!m_trans.compare(d_trans)) begin
        fail++;
        $display("\033[31mTest No.%d Failed\033[0m : a=%h b=%h cin=%b  Expected sum=%h cout=%b  Resulted sum=%h cout=%b",
        pass + fail, d_trans.a, d_trans.b, d_trans.cin, d_trans.sum, d_trans.carry_out16, m_trans.sum, m_trans.carry_out16);
      end
      else begin
        pass++;
      end
    end
    $display("\033[1;33mData flow: Passed %0d out of Total %0d Tests\033[0m", pass, pass + fail);
    $display("------------------Scoreboard Test Ends--------------------");
  endtask
endclass

// Environment class definition
class environment;
  mailbox gen2driv, driv2sb, mon2sb;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  event driven;
  virtual cla_if claif;

  function new(virtual cla_if claif);
    this.claif = claif;
    gen2driv = new();
    driv2sb = new();
    mon2sb = new();
    gen = new(gen2driv);
    drv = new(gen2driv, driv2sb, claif.DRIVER, driven);
    mon = new(mon2sb, claif.MONITOR, driven);
    scb = new(driv2sb, mon2sb);
  endfunction

  task main(input int count);
    fork
      gen.main(count);
      drv.main(count);
      mon.main(count);
      scb.main(count);
    join
  endtask
endclass

// Test program
program test(cla_if claif);
  environment env;

  initial begin
    env = new(claif);
    env.main(12000); // Run 1000 tests
    $finish;
  end
endprogram

// Top-level module
module cla_top_layered_tb;
  bit clk;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Interface instantiation
  cla_if claif(clk);

  // Test instantiation
  test test01(claif);

  // Dump generation
  initial begin
    $dumpfile("cla_16bit_tb.vcd");
    $dumpvars;
  end

  // DUT instantiation
  cla_top DUT (
    .a(claif.a),
    .b(claif.b),
    .cin(claif.cin),
    .sum(claif.sum),
    .carry_out16(claif.carry_out16),
    .clk(clk)
  );

endmodule