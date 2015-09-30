LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_MISC.ALL; --for use of and_reduce()
 
LIBRARY WORK;
USE WORK.ALL;
--------------------------------------------------------------
-- synthesis VHDL_INPUT_VERSION VHDL_2008
--
--  This is a skeleton you can use for the win subblock.  This block determines
--  whether each of the 3 bets is a winner.  As described in the lab
--  handout, the first bet is a "straight-up" bet, teh second bet is 
--  a colour bet, and the third bet is a "dozen" bet.
--
--  This should be a purely combinational block.  There is no clock.
--  Remember the rules associated with Pattern 1 in the lectures.
--
---------------------------------------------------------------
ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win;
ARCHITECTURE behavioural OF win IS
  signal bet1_bitvalue : std_logic_vector(5 downto 0);
---  signal red_or_black : std_logic;
---  signal colour_compare: std_logic;
  signal spin_bit : std_logic_vector(5 downto 0);
  signal spin_int: integer;
  signal dozen_set: unsigned(1 downto 0);
---  signal loss_flag: std_logic;
  
BEGIN
--begin logic for bet1
bet1_bitvalue <= std_logic_vector(bet1_value); --convert unsigned to std logic vector
spin_bit <= std_logic_vector(spin_result_latched); --convert unsigned to std logic vector
bet1_wins <= and_reduce(bet1_bitvalue xnor spin_bit); --bitwise cmp of spin and bet, equality test

--begin logic for bet2
process (all)
  
  variable red_or_black : std_logic;
  variable colour_compare : std_logic;
  variable loss_flag : std_logic;
  
  begin
   if (spin_result_latched /= "000000") then
     case spin_result_latched is
      when "000010" | "000100" | "000110" | "001000" | "001010" | "001011" | "001101" | "001111" | "010001" | "010100" | "010110" | "011000" | "011010" | "011100" | "011101" | "011111" | "100001" | "100011" => red_or_black := '0'; --black
      when "000001" | "000011" | "000101" | "000111" | "001001" | "001100" | "001110" | "010000" | "010010" | "010011" | "010101" | "010111" | "011001" | "011011" | "011110" | "100000" | "100010" | "100100" => red_or_black := '1'; --red
      when others => red_or_black := '0';
     end case;
   else loss_flag := '1';
  end if;

  colour_compare := (red_or_black xor bet2_colour);

  case colour_compare is
     when '1' => bet2_wins <= '0';
     when '0' => bet2_wins <= '1';
     when others => bet2_wins <= '0';
  end case;
  
  if (loss_flag = '1') then
      bet2_wins <= '0';
  end if;
  
  loss_flag := '0';
end process;

--begin logic for bet 3
--store spin value in integer form for use in comparison
spin_int <= to_integer(spin_result_latched);

--logic to determine which dozen the spin belongs to
process(all)
  begin
    if (spin_int < 25) then
      if (spin_int < 13) then
        dozen_set <= "00";
        if (spin_int = 0) then
          dozen_set <= "11";
        end if;
      else dozen_set <= "01";
      end if;
    else dozen_set <= "10";
    end if;
  end process;
  
--set output signal to win/loss for dozen bet
bet3_wins <= (dozen_set(0) xnor bet3_dozen(0)) and (dozen_set(1) xnor bet3_dozen(1));

END;
