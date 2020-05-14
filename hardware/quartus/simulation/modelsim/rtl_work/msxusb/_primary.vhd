library verilog;
use verilog.vl_types.all;
entity msxusb is
    port(
        in_a7_a0        : in     vl_logic_vector(7 downto 0);
        in_a15_a13_a12  : in     vl_logic_vector(2 downto 0);
        data            : in     vl_logic_vector(5 downto 0);
        iorq_n          : in     vl_logic;
        rd_n            : in     vl_logic;
        wr_n            : in     vl_logic;
        sltsl_n         : in     vl_logic;
        reset_n         : in     vl_logic;
        cs_ch376s_n     : out    vl_logic;
        busdir          : out    vl_logic;
        out_a13_a18     : out    vl_logic_vector(5 downto 0)
    );
end msxusb;
