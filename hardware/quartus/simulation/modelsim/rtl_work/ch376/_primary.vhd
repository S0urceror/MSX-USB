library verilog;
use verilog.vl_types.all;
entity ch376 is
    port(
        io_address      : in     vl_logic_vector(7 downto 0);
        iorq_n          : in     vl_logic;
        rd_n            : in     vl_logic;
        cs_ch376s_n     : out    vl_logic;
        busdir          : out    vl_logic
    );
end ch376;
