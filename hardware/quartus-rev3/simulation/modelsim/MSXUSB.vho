-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus II 64-Bit"
-- VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

-- DATE "03/29/2020 15:05:11"

-- 
-- Device: Altera EPM7064SLC44-10 Package PLCC44
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY IEEE;
LIBRARY MAX;
USE IEEE.STD_LOGIC_1164.ALL;
USE MAX.MAX_COMPONENTS.ALL;

ENTITY 	msxusb IS
    PORT (
	address : IN std_logic_vector(15 DOWNTO 0);
	data : IN std_logic_vector(7 DOWNTO 0);
	iorq_n : IN std_logic;
	rd_n : IN std_logic;
	wr_n : IN std_logic;
	sltsl_n : IN std_logic;
	cs_n : OUT std_logic;
	busdir : OUT std_logic;
	address_upper : OUT std_logic
	);
END msxusb;

-- Design Ports Information
-- address[0]	=>  Location: PIN_41
-- address[1]	=>  Location: PIN_28
-- address[2]	=>  Location: PIN_27
-- address[3]	=>  Location: PIN_37
-- address[4]	=>  Location: PIN_18
-- address[5]	=>  Location: PIN_8
-- address[6]	=>  Location: PIN_9
-- address[7]	=>  Location: PIN_25
-- address[8]	=>  Location: PIN_11
-- address[9]	=>  Location: PIN_44
-- address[10]	=>  Location: PIN_20
-- address[11]	=>  Location: PIN_12
-- address[12]	=>  Location: PIN_31
-- address[13]	=>  Location: PIN_40
-- address[14]	=>  Location: PIN_16
-- address[15]	=>  Location: PIN_36
-- data[0]	=>  Location: PIN_39
-- data[1]	=>  Location: PIN_33
-- data[2]	=>  Location: PIN_24
-- data[3]	=>  Location: PIN_14
-- data[4]	=>  Location: PIN_29
-- data[5]	=>  Location: PIN_1
-- data[6]	=>  Location: PIN_43
-- data[7]	=>  Location: PIN_34
-- iorq_n	=>  Location: PIN_17
-- rd_n	=>  Location: PIN_2
-- wr_n	=>  Location: PIN_26
-- sltsl_n	=>  Location: PIN_19
-- cs_n	=>  Location: PIN_6
-- busdir	=>  Location: PIN_5
-- address_upper	=>  Location: PIN_4


ARCHITECTURE structure OF msxusb IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_address : std_logic_vector(15 DOWNTO 0);
SIGNAL ww_data : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_iorq_n : std_logic;
SIGNAL ww_rd_n : std_logic;
SIGNAL ww_wr_n : std_logic;
SIGNAL ww_sltsl_n : std_logic;
SIGNAL ww_cs_n : std_logic;
SIGNAL ww_busdir : std_logic;
SIGNAL ww_address_upper : std_logic;
SIGNAL \CH376|cs_ch376s_n~3_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|cs_ch376s_n~3_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \CH376|busdir~0_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~10_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~12_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~13_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~10_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~12_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[0]~27_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem0[0]~17_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem3[0]~17_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem2[0]~19_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm0_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm1_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm2_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm3_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm4_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pterm5_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pxor_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pclk_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_pena_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_paclr_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|mem1[0]~20_papre_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[7]~13sexpand0_datain_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|address_upper[7]~13sexpand1_datain_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|Equal6~2sexpand0_datain_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|Equal4~2sexpand0_datain_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \MAPPER|Equal2~2sexpand0_datain_bus\ : std_logic_vector(51 DOWNTO 0);
SIGNAL \iorq_n~dataout\ : std_logic;
SIGNAL \CH376|cs_ch376s_n~3_dataout\ : std_logic;
SIGNAL \rd_n~dataout\ : std_logic;
SIGNAL \CH376|busdir~0_dataout\ : std_logic;
SIGNAL \wr_n~dataout\ : std_logic;
SIGNAL \sltsl_n~dataout\ : std_logic;
SIGNAL \MAPPER|mem3[0]~17_pexpout\ : std_logic;
SIGNAL \MAPPER|mem3[0]~10_dataout\ : std_logic;
SIGNAL \MAPPER|mem2[0]~19_pexpout\ : std_logic;
SIGNAL \MAPPER|mem2[0]~12_dataout\ : std_logic;
SIGNAL \MAPPER|mem1[0]~20_pexpout\ : std_logic;
SIGNAL \MAPPER|mem1[0]~13_dataout\ : std_logic;
SIGNAL \MAPPER|mem0[0]~17_pexpout\ : std_logic;
SIGNAL \MAPPER|mem0[0]~10_dataout\ : std_logic;
SIGNAL \MAPPER|Equal6~2sexpand0_dataout\ : std_logic;
SIGNAL \MAPPER|Equal4~2sexpand0_dataout\ : std_logic;
SIGNAL \MAPPER|Equal2~2sexpand0_dataout\ : std_logic;
SIGNAL \MAPPER|address_upper[0]~12_dataout\ : std_logic;
SIGNAL \MAPPER|address_upper[7]~13sexpand0_dataout\ : std_logic;
SIGNAL \MAPPER|address_upper[7]~13sexpand1_dataout\ : std_logic;
SIGNAL \MAPPER|address_upper[0]~27_dataout\ : std_logic;
SIGNAL \data~dataout\ : std_logic_vector(7 DOWNTO 0);
SIGNAL \address~dataout\ : std_logic_vector(15 DOWNTO 0);
SIGNAL \ALT_INV_sltsl_n~dataout\ : std_logic;
SIGNAL \ALT_INV_wr_n~dataout\ : std_logic;
SIGNAL \ALT_INV_rd_n~dataout\ : std_logic;
SIGNAL \ALT_INV_iorq_n~dataout\ : std_logic;
SIGNAL \ALT_INV_address~dataout\ : std_logic_vector(15 DOWNTO 0);

BEGIN

ww_address <= address;
ww_data <= data;
ww_iorq_n <= iorq_n;
ww_rd_n <= rd_n;
ww_wr_n <= wr_n;
ww_sltsl_n <= sltsl_n;
cs_n <= ww_cs_n;
busdir <= ww_busdir;
address_upper <= ww_address_upper;

\CH376|cs_ch376s_n~3_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \iorq_n~dataout\ & NOT \address~dataout\(7) & NOT \address~dataout\(6) & NOT \address~dataout\(5) & \address~dataout\(4) & NOT \address~dataout\(3) & NOT \address~dataout\(2) & NOT 
\address~dataout\(1) & NOT \address~dataout\(0));

\CH376|cs_ch376s_n~3_pterm2_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\CH376|cs_ch376s_n~3_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|cs_ch376s_n~3_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & NOT \iorq_n~dataout\ & NOT \address~dataout\(7) & NOT \address~dataout\(6) & NOT \address~dataout\(5) & \address~dataout\(4) & NOT \address~dataout\(3) & NOT \address~dataout\(2) & NOT \address~dataout\(1) & 
NOT \address~dataout\(0) & NOT \rd_n~dataout\);

\CH376|busdir~0_pterm2_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pterm3_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\CH376|busdir~0_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\CH376|busdir~0_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~10_pterm0_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(13) & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~10_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(14) & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~10_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|mem3[0]~10_dataout\ & \data~dataout\(0));

\MAPPER|mem3[0]~10_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \sltsl_n~dataout\ & \address~dataout\(13) & NOT \wr_n~dataout\ & \address~dataout\(12) & \data~dataout\(0));

\MAPPER|mem3[0]~10_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~10_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~10_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~10_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~10_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem3[0]~10_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~10_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~12_pterm0_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(13) & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~12_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(14) & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~12_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|mem2[0]~12_dataout\ & \data~dataout\(0));

\MAPPER|mem2[0]~12_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \sltsl_n~dataout\ & NOT \address~dataout\(13) & NOT \wr_n~dataout\ & \address~dataout\(12) & \data~dataout\(0));

\MAPPER|mem2[0]~12_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~12_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~12_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~12_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~12_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem2[0]~12_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~12_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~13_pterm0_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(13) & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~13_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(14) & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~13_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|mem1[0]~13_dataout\ & \data~dataout\(0));

\MAPPER|mem1[0]~13_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \address~dataout\(14) & NOT \sltsl_n~dataout\ & \address~dataout\(13) & NOT \wr_n~dataout\ & \address~dataout\(12) & \data~dataout\(0));

\MAPPER|mem1[0]~13_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~13_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~13_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~13_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~13_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem1[0]~13_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~13_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~10_pterm0_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(13) & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~10_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(14) & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~10_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|mem0[0]~10_dataout\ & \data~dataout\(0));

\MAPPER|mem0[0]~10_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \address~dataout\(14) & NOT \sltsl_n~dataout\ & NOT \address~dataout\(13) & NOT \wr_n~dataout\ & \address~dataout\(12) & \data~dataout\(0));

\MAPPER|mem0[0]~10_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~10_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~10_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~10_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~10_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem0[0]~10_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~10_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|Equal2~2sexpand0_dataout\ & \MAPPER|Equal4~2sexpand0_dataout\ & \MAPPER|Equal6~2sexpand0_dataout\ & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|address_upper[0]~12_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & \address~dataout\(13) & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|address_upper[0]~12_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|Equal6~2sexpand0_dataout\ & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \address~dataout\(13) & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|address_upper[0]~12_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|Equal4~2sexpand0_dataout\ & \MAPPER|Equal6~2sexpand0_dataout\ & NOT \address~dataout\(15) & \address~dataout\(14) & \address~dataout\(13) & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|address_upper[0]~12_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|address_upper[0]~12_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~12_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|address_upper[7]~13sexpand1_dataout\ & \MAPPER|address_upper[7]~13sexpand0_dataout\ & \MAPPER|address_upper[0]~27_dataout\);

\MAPPER|address_upper[0]~27_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \MAPPER|address_upper[0]~27_dataout\ & \MAPPER|address_upper[0]~12_dataout\);

\MAPPER|address_upper[0]~27_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \sltsl_n~dataout\ & \wr_n~dataout\ & \MAPPER|address_upper[0]~12_dataout\);

\MAPPER|address_upper[0]~27_pterm4_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \address~dataout\(14) & NOT \sltsl_n~dataout\ & \wr_n~dataout\ & \MAPPER|address_upper[0]~12_dataout\);

\MAPPER|address_upper[0]~27_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|address_upper[0]~27_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[0]~27_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(12) & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~17_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \wr_n~dataout\ & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~17_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \sltsl_n~dataout\ & \MAPPER|mem0[0]~10_dataout\);

\MAPPER|mem0[0]~17_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem0[0]~17_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem0[0]~17_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(12) & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~17_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \wr_n~dataout\ & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~17_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \sltsl_n~dataout\ & \MAPPER|mem3[0]~10_dataout\);

\MAPPER|mem3[0]~17_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem3[0]~17_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem3[0]~17_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(12) & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~19_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \wr_n~dataout\ & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~19_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \sltsl_n~dataout\ & \MAPPER|mem2[0]~12_dataout\);

\MAPPER|mem2[0]~19_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem2[0]~19_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem2[0]~19_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pterm0_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pterm1_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(12) & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~20_pterm2_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \wr_n~dataout\ & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~20_pterm3_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \sltsl_n~dataout\ & \MAPPER|mem1[0]~13_dataout\);

\MAPPER|mem1[0]~20_pterm4_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pterm5_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pxor_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pclk_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & 
gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_pena_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & 
vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc);

\MAPPER|mem1[0]~20_paclr_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|mem1[0]~20_papre_bus\ <= (gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd
& gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd & gnd);

\MAPPER|address_upper[7]~13sexpand0_datain_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \sltsl_n~dataout\ & \wr_n~dataout\);

\MAPPER|address_upper[7]~13sexpand1_datain_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \address~dataout\(14) & NOT \sltsl_n~dataout\ & \wr_n~dataout\);

\MAPPER|Equal6~2sexpand0_datain_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & \address~dataout\(13));

\MAPPER|Equal4~2sexpand0_datain_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & \address~dataout\(15) & NOT \address~dataout\(14) & NOT \address~dataout\(13));

\MAPPER|Equal2~2sexpand0_datain_bus\ <= (vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc
& vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & vcc & NOT \address~dataout\(15) & \address~dataout\(14) & \address~dataout\(13));
\ALT_INV_sltsl_n~dataout\ <= NOT \sltsl_n~dataout\;
\ALT_INV_wr_n~dataout\ <= NOT \wr_n~dataout\;
\ALT_INV_rd_n~dataout\ <= NOT \rd_n~dataout\;
\ALT_INV_iorq_n~dataout\ <= NOT \iorq_n~dataout\;
\ALT_INV_address~dataout\(15) <= NOT \address~dataout\(15);
\ALT_INV_address~dataout\(14) <= NOT \address~dataout\(14);
\ALT_INV_address~dataout\(13) <= NOT \address~dataout\(13);
\ALT_INV_address~dataout\(12) <= NOT \address~dataout\(12);
\ALT_INV_address~dataout\(7) <= NOT \address~dataout\(7);
\ALT_INV_address~dataout\(6) <= NOT \address~dataout\(6);
\ALT_INV_address~dataout\(5) <= NOT \address~dataout\(5);
\ALT_INV_address~dataout\(3) <= NOT \address~dataout\(3);
\ALT_INV_address~dataout\(2) <= NOT \address~dataout\(2);
\ALT_INV_address~dataout\(1) <= NOT \address~dataout\(1);
\ALT_INV_address~dataout\(0) <= NOT \address~dataout\(0);

-- Location: PIN_41
\address[0]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(0),
	dataout => \address~dataout\(0));

-- Location: PIN_28
\address[1]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(1),
	dataout => \address~dataout\(1));

-- Location: PIN_27
\address[2]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(2),
	dataout => \address~dataout\(2));

-- Location: PIN_37
\address[3]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(3),
	dataout => \address~dataout\(3));

-- Location: PIN_18
\address[4]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(4),
	dataout => \address~dataout\(4));

-- Location: PIN_8
\address[5]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(5),
	dataout => \address~dataout\(5));

-- Location: PIN_9
\address[6]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(6),
	dataout => \address~dataout\(6));

-- Location: PIN_25
\address[7]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(7),
	dataout => \address~dataout\(7));

-- Location: PIN_17
\iorq_n~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_iorq_n,
	dataout => \iorq_n~dataout\);

-- Location: LC11
\CH376|cs_ch376s_n~3\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \CH376|cs_ch376s_n~3_pterm0_bus\,
	pterm1 => \CH376|cs_ch376s_n~3_pterm1_bus\,
	pterm2 => \CH376|cs_ch376s_n~3_pterm2_bus\,
	pterm3 => \CH376|cs_ch376s_n~3_pterm3_bus\,
	pterm4 => \CH376|cs_ch376s_n~3_pterm4_bus\,
	pterm5 => \CH376|cs_ch376s_n~3_pterm5_bus\,
	pxor => \CH376|cs_ch376s_n~3_pxor_bus\,
	pclk => \CH376|cs_ch376s_n~3_pclk_bus\,
	papre => \CH376|cs_ch376s_n~3_papre_bus\,
	paclr => \CH376|cs_ch376s_n~3_paclr_bus\,
	pena => \CH376|cs_ch376s_n~3_pena_bus\,
	dataout => \CH376|cs_ch376s_n~3_dataout\);

-- Location: PIN_2
\rd_n~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_rd_n,
	dataout => \rd_n~dataout\);

-- Location: LC14
\CH376|busdir~0\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "invert",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \CH376|busdir~0_pterm0_bus\,
	pterm1 => \CH376|busdir~0_pterm1_bus\,
	pterm2 => \CH376|busdir~0_pterm2_bus\,
	pterm3 => \CH376|busdir~0_pterm3_bus\,
	pterm4 => \CH376|busdir~0_pterm4_bus\,
	pterm5 => \CH376|busdir~0_pterm5_bus\,
	pxor => \CH376|busdir~0_pxor_bus\,
	pclk => \CH376|busdir~0_pclk_bus\,
	papre => \CH376|busdir~0_papre_bus\,
	paclr => \CH376|busdir~0_paclr_bus\,
	pena => \CH376|busdir~0_pena_bus\,
	dataout => \CH376|busdir~0_dataout\);

-- Location: PIN_31
\address[12]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(12),
	dataout => \address~dataout\(12));

-- Location: PIN_26
\wr_n~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_wr_n,
	dataout => \wr_n~dataout\);

-- Location: PIN_19
\sltsl_n~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_sltsl_n,
	dataout => \sltsl_n~dataout\);

-- Location: LC1
\MAPPER|mem3[0]~17\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "vcc",
	output_mode => "comb",
	pexp_mode => "on")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|mem3[0]~17_pterm0_bus\,
	pterm1 => \MAPPER|mem3[0]~17_pterm1_bus\,
	pterm2 => \MAPPER|mem3[0]~17_pterm2_bus\,
	pterm3 => \MAPPER|mem3[0]~17_pterm3_bus\,
	pterm4 => \MAPPER|mem3[0]~17_pterm4_bus\,
	pterm5 => \MAPPER|mem3[0]~17_pterm5_bus\,
	pxor => \MAPPER|mem3[0]~17_pxor_bus\,
	pclk => \MAPPER|mem3[0]~17_pclk_bus\,
	papre => \MAPPER|mem3[0]~17_papre_bus\,
	paclr => \MAPPER|mem3[0]~17_paclr_bus\,
	pena => \MAPPER|mem3[0]~17_pena_bus\,
	pexpout => \MAPPER|mem3[0]~17_pexpout\);

-- Location: PIN_39
\data[0]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(0),
	dataout => \data~dataout\(0));

-- Location: PIN_40
\address[13]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(13),
	dataout => \address~dataout\(13));

-- Location: PIN_16
\address[14]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(14),
	dataout => \address~dataout\(14));

-- Location: PIN_36
\address[15]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(15),
	dataout => \address~dataout\(15));

-- Location: LC2
\MAPPER|mem3[0]~10\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pexpin => \MAPPER|mem3[0]~17_pexpout\,
	pterm0 => \MAPPER|mem3[0]~10_pterm0_bus\,
	pterm1 => \MAPPER|mem3[0]~10_pterm1_bus\,
	pterm2 => \MAPPER|mem3[0]~10_pterm2_bus\,
	pterm3 => \MAPPER|mem3[0]~10_pterm3_bus\,
	pterm4 => \MAPPER|mem3[0]~10_pterm4_bus\,
	pterm5 => \MAPPER|mem3[0]~10_pterm5_bus\,
	pxor => \MAPPER|mem3[0]~10_pxor_bus\,
	pclk => \MAPPER|mem3[0]~10_pclk_bus\,
	papre => \MAPPER|mem3[0]~10_papre_bus\,
	paclr => \MAPPER|mem3[0]~10_paclr_bus\,
	pena => \MAPPER|mem3[0]~10_pena_bus\,
	dataout => \MAPPER|mem3[0]~10_dataout\);

-- Location: LC3
\MAPPER|mem2[0]~19\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "vcc",
	output_mode => "comb",
	pexp_mode => "on")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|mem2[0]~19_pterm0_bus\,
	pterm1 => \MAPPER|mem2[0]~19_pterm1_bus\,
	pterm2 => \MAPPER|mem2[0]~19_pterm2_bus\,
	pterm3 => \MAPPER|mem2[0]~19_pterm3_bus\,
	pterm4 => \MAPPER|mem2[0]~19_pterm4_bus\,
	pterm5 => \MAPPER|mem2[0]~19_pterm5_bus\,
	pxor => \MAPPER|mem2[0]~19_pxor_bus\,
	pclk => \MAPPER|mem2[0]~19_pclk_bus\,
	papre => \MAPPER|mem2[0]~19_papre_bus\,
	paclr => \MAPPER|mem2[0]~19_paclr_bus\,
	pena => \MAPPER|mem2[0]~19_pena_bus\,
	pexpout => \MAPPER|mem2[0]~19_pexpout\);

-- Location: LC4
\MAPPER|mem2[0]~12\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pexpin => \MAPPER|mem2[0]~19_pexpout\,
	pterm0 => \MAPPER|mem2[0]~12_pterm0_bus\,
	pterm1 => \MAPPER|mem2[0]~12_pterm1_bus\,
	pterm2 => \MAPPER|mem2[0]~12_pterm2_bus\,
	pterm3 => \MAPPER|mem2[0]~12_pterm3_bus\,
	pterm4 => \MAPPER|mem2[0]~12_pterm4_bus\,
	pterm5 => \MAPPER|mem2[0]~12_pterm5_bus\,
	pxor => \MAPPER|mem2[0]~12_pxor_bus\,
	pclk => \MAPPER|mem2[0]~12_pclk_bus\,
	papre => \MAPPER|mem2[0]~12_papre_bus\,
	paclr => \MAPPER|mem2[0]~12_paclr_bus\,
	pena => \MAPPER|mem2[0]~12_pena_bus\,
	dataout => \MAPPER|mem2[0]~12_dataout\);

-- Location: LC5
\MAPPER|mem1[0]~20\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "vcc",
	output_mode => "comb",
	pexp_mode => "on")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|mem1[0]~20_pterm0_bus\,
	pterm1 => \MAPPER|mem1[0]~20_pterm1_bus\,
	pterm2 => \MAPPER|mem1[0]~20_pterm2_bus\,
	pterm3 => \MAPPER|mem1[0]~20_pterm3_bus\,
	pterm4 => \MAPPER|mem1[0]~20_pterm4_bus\,
	pterm5 => \MAPPER|mem1[0]~20_pterm5_bus\,
	pxor => \MAPPER|mem1[0]~20_pxor_bus\,
	pclk => \MAPPER|mem1[0]~20_pclk_bus\,
	papre => \MAPPER|mem1[0]~20_papre_bus\,
	paclr => \MAPPER|mem1[0]~20_paclr_bus\,
	pena => \MAPPER|mem1[0]~20_pena_bus\,
	pexpout => \MAPPER|mem1[0]~20_pexpout\);

-- Location: LC6
\MAPPER|mem1[0]~13\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pexpin => \MAPPER|mem1[0]~20_pexpout\,
	pterm0 => \MAPPER|mem1[0]~13_pterm0_bus\,
	pterm1 => \MAPPER|mem1[0]~13_pterm1_bus\,
	pterm2 => \MAPPER|mem1[0]~13_pterm2_bus\,
	pterm3 => \MAPPER|mem1[0]~13_pterm3_bus\,
	pterm4 => \MAPPER|mem1[0]~13_pterm4_bus\,
	pterm5 => \MAPPER|mem1[0]~13_pterm5_bus\,
	pxor => \MAPPER|mem1[0]~13_pxor_bus\,
	pclk => \MAPPER|mem1[0]~13_pclk_bus\,
	papre => \MAPPER|mem1[0]~13_papre_bus\,
	paclr => \MAPPER|mem1[0]~13_paclr_bus\,
	pena => \MAPPER|mem1[0]~13_pena_bus\,
	dataout => \MAPPER|mem1[0]~13_dataout\);

-- Location: LC7
\MAPPER|mem0[0]~17\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "vcc",
	output_mode => "comb",
	pexp_mode => "on")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|mem0[0]~17_pterm0_bus\,
	pterm1 => \MAPPER|mem0[0]~17_pterm1_bus\,
	pterm2 => \MAPPER|mem0[0]~17_pterm2_bus\,
	pterm3 => \MAPPER|mem0[0]~17_pterm3_bus\,
	pterm4 => \MAPPER|mem0[0]~17_pterm4_bus\,
	pterm5 => \MAPPER|mem0[0]~17_pterm5_bus\,
	pxor => \MAPPER|mem0[0]~17_pxor_bus\,
	pclk => \MAPPER|mem0[0]~17_pclk_bus\,
	papre => \MAPPER|mem0[0]~17_papre_bus\,
	paclr => \MAPPER|mem0[0]~17_paclr_bus\,
	pena => \MAPPER|mem0[0]~17_pena_bus\,
	pexpout => \MAPPER|mem0[0]~17_pexpout\);

-- Location: LC8
\MAPPER|mem0[0]~10\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pexpin => \MAPPER|mem0[0]~17_pexpout\,
	pterm0 => \MAPPER|mem0[0]~10_pterm0_bus\,
	pterm1 => \MAPPER|mem0[0]~10_pterm1_bus\,
	pterm2 => \MAPPER|mem0[0]~10_pterm2_bus\,
	pterm3 => \MAPPER|mem0[0]~10_pterm3_bus\,
	pterm4 => \MAPPER|mem0[0]~10_pterm4_bus\,
	pterm5 => \MAPPER|mem0[0]~10_pterm5_bus\,
	pxor => \MAPPER|mem0[0]~10_pxor_bus\,
	pclk => \MAPPER|mem0[0]~10_pclk_bus\,
	papre => \MAPPER|mem0[0]~10_papre_bus\,
	paclr => \MAPPER|mem0[0]~10_paclr_bus\,
	pena => \MAPPER|mem0[0]~10_pena_bus\,
	dataout => \MAPPER|mem0[0]~10_dataout\);

-- Location: SEXP5
\MAPPER|Equal6~2sexpand0\ : max_sexp
PORT MAP (
	datain => \MAPPER|Equal6~2sexpand0_datain_bus\,
	dataout => \MAPPER|Equal6~2sexpand0_dataout\);

-- Location: SEXP3
\MAPPER|Equal4~2sexpand0\ : max_sexp
PORT MAP (
	datain => \MAPPER|Equal4~2sexpand0_datain_bus\,
	dataout => \MAPPER|Equal4~2sexpand0_dataout\);

-- Location: SEXP1
\MAPPER|Equal2~2sexpand0\ : max_sexp
PORT MAP (
	datain => \MAPPER|Equal2~2sexpand0_datain_bus\,
	dataout => \MAPPER|Equal2~2sexpand0_dataout\);

-- Location: LC10
\MAPPER|address_upper[0]~12\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|address_upper[0]~12_pterm0_bus\,
	pterm1 => \MAPPER|address_upper[0]~12_pterm1_bus\,
	pterm2 => \MAPPER|address_upper[0]~12_pterm2_bus\,
	pterm3 => \MAPPER|address_upper[0]~12_pterm3_bus\,
	pterm4 => \MAPPER|address_upper[0]~12_pterm4_bus\,
	pterm5 => \MAPPER|address_upper[0]~12_pterm5_bus\,
	pxor => \MAPPER|address_upper[0]~12_pxor_bus\,
	pclk => \MAPPER|address_upper[0]~12_pclk_bus\,
	papre => \MAPPER|address_upper[0]~12_papre_bus\,
	paclr => \MAPPER|address_upper[0]~12_paclr_bus\,
	pena => \MAPPER|address_upper[0]~12_pena_bus\,
	dataout => \MAPPER|address_upper[0]~12_dataout\);

-- Location: SEXP10
\MAPPER|address_upper[7]~13sexpand0\ : max_sexp
PORT MAP (
	datain => \MAPPER|address_upper[7]~13sexpand0_datain_bus\,
	dataout => \MAPPER|address_upper[7]~13sexpand0_dataout\);

-- Location: SEXP7
\MAPPER|address_upper[7]~13sexpand1\ : max_sexp
PORT MAP (
	datain => \MAPPER|address_upper[7]~13sexpand1_datain_bus\,
	dataout => \MAPPER|address_upper[7]~13sexpand1_dataout\);

-- Location: LC16
\MAPPER|address_upper[0]~27\ : max_mcell
-- pragma translate_off
GENERIC MAP (
	operation_mode => "normal",
	output_mode => "comb",
	pexp_mode => "off")
-- pragma translate_on
PORT MAP (
	pterm0 => \MAPPER|address_upper[0]~27_pterm0_bus\,
	pterm1 => \MAPPER|address_upper[0]~27_pterm1_bus\,
	pterm2 => \MAPPER|address_upper[0]~27_pterm2_bus\,
	pterm3 => \MAPPER|address_upper[0]~27_pterm3_bus\,
	pterm4 => \MAPPER|address_upper[0]~27_pterm4_bus\,
	pterm5 => \MAPPER|address_upper[0]~27_pterm5_bus\,
	pxor => \MAPPER|address_upper[0]~27_pxor_bus\,
	pclk => \MAPPER|address_upper[0]~27_pclk_bus\,
	papre => \MAPPER|address_upper[0]~27_papre_bus\,
	paclr => \MAPPER|address_upper[0]~27_paclr_bus\,
	pena => \MAPPER|address_upper[0]~27_pena_bus\,
	dataout => \MAPPER|address_upper[0]~27_dataout\);

-- Location: PIN_11
\address[8]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(8));

-- Location: PIN_44
\address[9]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(9));

-- Location: PIN_20
\address[10]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(10));

-- Location: PIN_12
\address[11]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_address(11));

-- Location: PIN_33
\data[1]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(1));

-- Location: PIN_24
\data[2]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(2));

-- Location: PIN_14
\data[3]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(3));

-- Location: PIN_29
\data[4]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(4));

-- Location: PIN_1
\data[5]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(5));

-- Location: PIN_43
\data[6]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(6));

-- Location: PIN_34
\data[7]~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "input",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_data(7));

-- Location: PIN_6
\cs_n~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \CH376|cs_ch376s_n~3_dataout\,
	oe => VCC,
	padio => ww_cs_n);

-- Location: PIN_5
\busdir~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \CH376|busdir~0_dataout\,
	oe => VCC,
	padio => ww_busdir);

-- Location: PIN_4
\address_upper~I\ : max_io
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	operation_mode => "output",
	weak_pull_up => "false")
-- pragma translate_on
PORT MAP (
	datain => \MAPPER|address_upper[0]~27_dataout\,
	oe => VCC,
	padio => ww_address_upper);
END structure;


