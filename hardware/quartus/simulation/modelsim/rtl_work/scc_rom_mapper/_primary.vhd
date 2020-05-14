library verilog;
use verilog.vl_types.all;
entity scc_rom_mapper is
    port(
        wr_n            : in     vl_logic;
        sltsl_n         : in     vl_logic;
        reset_n         : in     vl_logic;
        a15_a13_a12     : in     vl_logic_vector(2 downto 0);
        data            : in     vl_logic_vector(5 downto 0);
        address_upper   : out    vl_logic_vector(5 downto 0)
    );
end scc_rom_mapper;
