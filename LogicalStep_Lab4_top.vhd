LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic; --For clock input
	rst_n			: in	std_logic; --For reset signal
	pb				: in	std_logic_vector(3 downto 0); --Push buttons inputs
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

--Components used

	component Bidir_shift_reg port
	(
			CLK	: in std_logic := '0'; --Main clock input
			RESET_n	: in std_logic := '0'; --Reset signal
			CLK_EN	: in std_logic := '0'; --Clock enable from MOORE_SM1
			LEFT0_RIGHT1	: in std_logic := '0'; --Left/right shift signal
			REG_BITS	 : out std_logic_vector(3 downto 0) --4-bit output for register bits
	);
	end component;
	
	component MOORE_SM1 port
	(
			CLK		     		: in  std_logic := '0'; --Main clock input
         RESET_n      		: in  std_logic := '0'; --Reset signal
			EXT_BUTTON			: in  std_logic := '0'; --Extender toggle button
			EXT_ENBL				: in  std_logic := '0'; --Extender enable
			CURRENT				: in	std_logic_vector(3 downto 0); --Current 4 bit input from Bidir_shift_reg
         EXT_RESULT			: out std_logic; --Signal for left/right shift input for Bidir_shift_reg
			EXT_OUT				: out std_logic; --Extender out shift to output to Mealy_SM
			CLK_EN				: out std_logic; --Clk_en signal for 4-bit Bidir_shift_reg
			GRAP_ENBL			: out std_logic --Grappler enable for MOORE_SM2
	);
	end component;

	component MOORE_SM2 port
	(
          CLK		     		: in  std_logic := '0'; --Main clock input
          RESET_n      		: in  std_logic := '0'; --Reset signal
			 GRAP_BUTTON		: in  std_logic := '0'; --Grappler toggle button
			 GRAP_ENBL			: in  std_logic := '0'; --Grappler enable signal from MOORE_SM1
          GRAP_ON			   : out std_logic --Grappler active signal to led[3]
			 );
	end component;
	
	component U_D_Bin_Counter4bit port
	(
		CLK	: in std_logic := '0'; --Main clock input
		RESET_n	: in std_logic := '0'; --Reset signal
		CLK_EN	: in std_logic := '0'; --Clock enable from Mealy_SM
		UP1_DOWN0	: in std_logic := '0'; --Up/down counter signal
		COUNTER_BITS	: out std_logic_vector(3 downto 0) --4 bit output for counter
	);
	end component;
	
	component Compx4 port
	(
		temp1	: in std_logic_vector(3 downto 0);		--represents the 4-bit to be compared (i.e. current temp.)
		temp2	: in std_logic_vector(3 downto 0);		--represents the 4-bit being compared to (i.e. desired temp.)
		output	: out std_logic_vector(2 downto 0)	--result outputted as vector (i.e. output(2) is GT, output(1) is EQ, output(0) is LT)
	);
	end component;
	
	component Mealy_SM port
	(
          CLK		     		: in  std_logic := '0'; --Main clock input
          RESET_n      		: in  std_logic := '0'; --Reset signal
			 pb_in				: in 	std_logic_vector(1 downto 0); --Push button inputs
			 Xinput				: in 	std_logic_vector(2 downto 0); --X comparison input from Compx4
			 Yinput				: in	std_logic_vector(2 downto 0); --Y comparison input from Compx4
			 ext_out				: in	std_logic; --Extender out signal from MOORE_SM1
			 Xoutput				: out std_logic; --Up/down X counter output to U_D_Bin_Counter4bit
			 Youtput				: out std_logic; --Up/down Y counter output to U_D_Bin_Counter4bit
			 XCLK					: out std_logic; --X clock output to U_D_Bin_Counter4bit
			 YCLK					: out std_logic; --Y clock output to U_D_Bin_Counter4bit
			 led0					: out std_logic --led[0] for error
	);
	end component;
	
	component SevenSegment port
	(
   hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
	); 
	end component;
	
	component segment7_mux port
	(
          clk        : in  std_logic := '0'; 
			 DIN2 		: in  std_logic_vector(6 downto 0);	--7 bit input
			 DIN1 		: in  std_logic_vector(6 downto 0); --7 bit input
			 DOUT			: out	std_logic_vector(6 downto 0); --7 bit output to seg7 display
			 DIG2			: out	std_logic; --second digit output
			 DIG1			: out	std_logic --first digit output
   );
	end component;
	
	component Mux7 port
	(
			input1	: in std_logic_vector(6 downto 0);
			input2	: in std_logic_vector(6 downto 0);
			enable	: in std_logic;
			output	: out std_logic_vector(6 downto 0)
	);
	end component;
	
	
	component Mux4 port
	(
		input1	: in std_logic_vector(3 downto 0);
		input2	: in std_logic_vector(3 downto 0);
		enable	: in std_logic;
		output	: out std_logic_vector(3 downto 0)
	);
	end component;

	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean := FALSE; 	-- set to TRUE for simulation runs otherwise keep at 0.
   CONSTANT CLK_DIV_SIZE				: 	INTEGER := 26;    -- size of vectors for the counters

   SIGNAL 	Main_CLK						:  STD_LOGIC; 			-- main clock to drive sequencing of State Machine

	SIGNAL 	bin_counter					:  UNSIGNED(CLK_DIV_SIZE-1 downto 0); -- := to_unsigned(0,CLK_DIV_SIZE); -- reset binary counter to zero
	
	SIGNAL pb_bar : std_logic_vector(3 downto 0);
----------------------------------------------------------------------------------------------------

--***INPUTS OF Compx4s***--
	SIGNAL X_target						: std_logic_vector(3 downto 0);
	SIGNAL Y_target						: std_logic_vector(3 downto 0);
	SIGNAL Xoutput							: std_logic_vector(3 downto 0);
	SIGNAL Youtput							: std_logic_vector(3 downto 0);

--***INPUTS OF MEALY STATE MACHINE***--
	SIGNAL X_comp							: std_logic_vector(2 downto 0);
	SIGNAL Y_comp							: std_logic_vector(2 downto 0);
	SIGNAL ext_out							: std_logic := '0';

--***INPUTS FOR UP/DOWN BINARY COUNTER***--
	SIGNAL XUD								: std_logic;
	SIGNAL YUD								: std_logic;
	SIGNAL XCLK								: std_logic;
	SIGNAL YCLK								: std_logic;

--***INPUTS FOR MUX7s***--
	SIGNAL displayA						: std_logic_vector(6 downto 0);
	SIGNAL displayB						: std_logic_vector(6 downto 0);
	SIGNAL MUX2_XIN						: std_logic_vector(6 downto 0);
	SIGNAL MUX2_YIN						: std_logic_vector(6 downto 0);
	SIGNAL error							: std_logic := '0';

--***INPUTS FOR SEGMENT7 MUX***--
	SIGNAL new_displayA					: std_logic_vector(6 downto 0);
	SIGNAL new_displayB					: std_logic_vector(6 downto 0);

--***INPUTS FOR SEVENSEGMENT DISPLAYS***--
	SIGNAL displayA_in					: std_logic_vector(3 downto 0);
	SIGNAL displayB_in					: std_logic_vector(3 downto 0);

--***INPUTS FOR MOORE STATE MACHINE 1 (EXTENDER)***--
	SIGNAL ext_en							: std_logic := '0';
	SIGNAL bidir_output					: std_logic_vector(3 downto 0);
	
--***INPUTS FOR BIDIRECTIONAL SHIFT REGISTER***--
	SIGNAL ext_result						: std_logic;
	SIGNAL bidir_clk						: std_logic;

--***INPUTS FOR MOORE STATE MACHINE 2 (GRAPPLER)***-
	SIGNAL grap_en							: std_logic := '0';
	
BEGIN

-- CLOCKING GENERATOR WHICH DIVIDES THE INPUT CLOCK DOWN TO A LOWER FREQUENCY

BinCLK: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counter <= bin_counter + 1;
      END IF;
   END PROCESS;

Clock_Source:
				Main_Clk <= 
				clkin_50 when sim = TRUE else				-- for simulations only
				std_logic(bin_counter(23));								-- for real FPGA operation

pb_bar <= not(pb); --Inverting the push buttons

	X_target <= sw(7 downto 4); --Assigning switches 7 thru 4 to be the X target coordinate
	Y_target <= sw(3 downto 0); --Assigning switches 3 thru 0 to be the Y target coordinate

--COMPONENT HOOKUP FOR MUX4s--
--Description: This controls what should be displayed on the seg7 display.
--             If the respective push button is not pressed, the target coordinate
--             will be sent to the Seven Segment decoders. If the respective push button is pressed, the coordinate
--             which is counting up or down will be displayed.
	INST0: Mux4 port map(X_target, Xoutput, pb_bar(3), displayA_in);
	INST1: Mux4 port map(Y_target, Youtput, pb_bar(2), displayB_in);
	
--COMPONENT HOOKUP FOR MEALY STATE MACHINE--
--Description: This controls the X and Y coordinate movement of the robotic arm. It gives a signal
--             to the extender to tell it when it can move.
	INST2: Mealy_SM port map(Main_Clk, rst_n, pb_bar(3 downto 2), X_comp, Y_comp, ext_out, XUD, YUD, XCLK, YCLK, error);

	leds(0) <= error; --Assigning leds[0] to show that an error occurred

--COMPONENT HOOKUP FOR TWO UP/DOWN 4 BIT BINARY COUNTER--
--Description: This counts up or down depending on its inputs. It is a 4 bit binary counter
	INST3: U_D_Bin_Counter4bit port map(Main_Clk, rst_n, XCLK, XUD, Xoutput);
	INST4: U_D_Bin_Counter4bit port map(Main_Clk, rst_n, YCLK, YUD, Youtput);
	
--COMPONENT HOOKUP FOR COMPX4--
--Description: This compares two 4 bit digit and gives a 3 bit output with the least siginificant
--             bit corresponding to being less than, the 2nd bit corresponding to being equal to
--             and the last bit corresponding to being greater than
	INST5: Compx4 port map(Xoutput, X_target, X_comp);
	INST6: Compx4 port map(Youtput, Y_target, Y_comp);
	
--COMPONENT HOOKUP FOR SEVEN SEGMENT DISPLAYS--
--Description: This takes a 4 bit input and outputs a 7 bit output to be displayed
--             on the displays
	INST7: SevenSegment port map(displayA_in, displayA);
	INST8: SevenSegment port map(displayB_in, displayB);

--COMPONENT HOOKUP OF MUX7s TO DISPLAY FLASHING DIGITS IF ERROR OCCURS--
--Description: INST9 and INST10 controls the flashing of the digits when an error occurs.
--             "0000000" is muxed with the output of the SevenSegment decoder using the Main_Clk
--             as the enable signal. This is outputted to the signals MUX2_XIN and MUX2_YIN.

	INST9: Mux7 port map("0000000", displayA, Main_Clk, MUX2_XIN);
	INST10: Mux7 port map("0000000", displayB, Main_Clk, MUX2_YIN);

--Description: INST11 and INST12 controls what digits to output depending on if an error occurs or not.
--             If an error does not occur, display A/B is outputted. If an error occurs MUX2_XIN/MUX2_YIN is
--             outputted
	INST11: Mux7 port map(displayA, MUX2_XIN, error, new_displayA);
	INST12: Mux7 port map(displayB, MUX2_YIN, error, new_displayB);

--COMPONENT HOOKUP FOR SEGMENT7_MUX--
--Description: The corresponding digits are displayed
	INST13: segment7_mux port map(clkin_50, new_displayA, new_displayB, seg7_data, seg7_char1, seg7_char2);

	ext_en <= (NOT XCLK AND NOT YCLK) AND (XUD AND YUD); --If the XCLK and YCLK is 0 as well as the Up/Down signal for X and Y

--COMPONENT HOOKUP FOR MOORE STATE MACHINE 1 (EXTENDER)--
--Description: This state machine controls the operation of the extender. The extender
--             can only move if the X and Y coordinates are met
	INST14: MOORE_SM1 port map(Main_Clk, rst_n, pb_bar(1), ext_en, bidir_output, ext_result, ext_out, bidir_clk, grap_en);
	
--COMPONENT HOOKUP FOR BIDIRECTIONAL SHIFT REGISTER--
--Description: This shift register shifts bits to the left and right depending on its bidir_clk input
	INST15: Bidir_shift_reg port map(Main_clk, rst_n, bidir_clk, ext_result, bidir_output);
	
	leds(7 downto 4) <= bidir_output; --Assigning leds 7 thru 4 to show that the extender is extending

--COMPONENT HOOKUP FOR MOORE STATE MACHINE 2 (GRAPPLER)--
--Description: This state machine controls the operation of the grappler. The grappler can only
--             be active is the extender is fully extended.
	INST16: MOORE_SM2 port map(Main_Clk, rst_n, pb_bar(0), grap_en, leds(3));

END SimpleCircuit;
