--------------------------------------------------------------------------------
-- Company: Red Pitaya
-- Engineer: Miha Gjura
--
-- Design Name: led
-- Project Name: Red Pitaya V0.94
-- Target Device: Red Pitaya STEMlab 125-14
-- Tool versions: Vivado 2020.1
-- Description: Led Counter code
-- Sys Registers: 403_00000 to 403_fffff (uses MIMO PID register space)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity led is
  port (
    clk_i   : in  std_logic;                        -- bus clock
    rstn_i  : in  std_logic;                        -- bus reset - active low
    led_o   : out std_logic_vector(7 downto 0);     -- led bus
    sys_addr  : in  std_logic_vector(31 downto 0);  -- bus address
    sys_wdata : in  std_logic_vector(31 downto 0);  -- bus write data
    sys_wen   : in  std_logic;                      -- bus write enable
    sys_ren   : in  std_logic;                      -- bus read enable
    sys_rdata : out std_logic_vector(31 downto 0);  -- bus read data
    sys_err   : out std_logic;                      -- bus error indicator
    sys_ack   : out std_logic                       -- bus acknowledge signal
    );
end led;

architecture Behavioral of led is
    signal count_speed : unsigned(31 downto 0) := to_unsigned(1, 32);
    signal led_count : unsigned(31 downto 0) := (others => '0');

begin

    count: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rstn_i = '0' then
                led_count <= (others => '0');
            else
                led_count <= led_count + count_speed;
            end if;
        end if;
    end process;

    led_o <= std_logic_vector(led_count(31 downto 24));

    -- Handling non-connected system signals
    -- sys_ack <= '1';
    sys_err <= '0';

    --  Registers, write & control logic
    pbus: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rstn_i = '0' then

            else
                sys_ack <= sys_wen or sys_ren;    -- acknowledge transactions

--                if sys_wen='1' then               -- decode address & write registers
--                    if sys_addr(19 downto 0)=X"00054" then
--
--                    end if;
--                end if;
            end if;
        end if;
    end process;

    -- decode address & read data
    with sys_addr(19 downto 0) select
        sys_rdata <= X"FEEDBACC" when x"00050",   -- ID
                     X"00000000" when others;

end Behavioral;