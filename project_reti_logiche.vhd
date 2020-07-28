------------------------------------------------------------------------------------
--
-- Prova Finale (Progetto di Reti Logiche)
-- Prof. Gianluca Palermo - Anno 2019/2020
--
-- Lorenzo Ye (Codice persona 10610223 - Matricola 890472)
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
    port (
    i_clk : in std_logic;
    i_start : in std_logic;
    i_rst : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
    );
    end project_reti_logiche;

architecture project of project_reti_logiche is
    type states is (WAIT_START, RAM_REQ, WAIT_FOR_RAM, MEM, CHECK_WZ, ENCODE, DONE);
    signal current_state, next_state : states;
    signal next_o_done, next_o_en, next_o_we : std_logic := '0';
    signal next_o_data : std_logic_vector(7 downto 0) := "00000000";
	signal next_o_address : std_logic_vector(15 downto 0) := "0000000000000000";
	signal addr_received, next_addr_received: boolean := false;
	
	signal addr_in_wz, next_addr_in_wz: boolean := false;
	
	signal wz_offset, next_wz_offset: std_logic_vector(3 downto 0) := "0000";
	
	signal wz_num, next_wz_num: std_logic_vector(2 downto 0) := "000";
	
	signal address_count, next_address_count : std_logic_vector(15 downto 0) := "0000000000000000";
	
	signal mem_addr, mem_wz, next_mem_addr, next_mem_wz, wz_address : integer range 0 to 127 := 0;
    
    begin
       process(i_clk, i_rst)
            begin
                if (i_rst = '1') then
                    addr_received <= false;
                    addr_in_wz <= false;
                    wz_offset <= "0000";
                    wz_num <= "000";
                    mem_addr <= 0;
                    mem_wz <= 0;
                    wz_address <= 0;
                    address_count <= "0000000000000000";
                    
                    current_state <= WAIT_START;
                elsif(i_clk'event and i_clk = '1') then
                    o_done <= next_o_done;
                    o_en <= next_o_en;
                    o_we <= next_o_we;
                    o_data <= next_o_data;
                    o_address <= next_o_address;
                    
                    addr_in_wz <= next_addr_in_wz;
                    
                    addr_received <= next_addr_received;
                    
                    wz_offset <= next_wz_offset;
                    
                    wz_num <= next_wz_num;
                    
                    address_count <= next_address_count;
                    
                    mem_addr <= next_mem_addr;
                    mem_wz <= next_mem_wz;
                    wz_address <= conv_integer(address_count);
                    
                    current_state <= next_state;
                end if;
            end process; 
        
        
        
        process(current_state, i_data, i_start, addr_received, addr_in_wz, wz_offset, wz_num, mem_addr, mem_wz, wz_address, next_o_address, address_count)
            begin
                next_o_done <= '0';
                next_o_en <= '0';
                next_o_we <= '0';
                next_o_data <= "00000000";
                next_o_address <= "0000000000000000";
                
                
                next_o_address <= next_o_address;
                
                next_addr_in_wz <= addr_in_wz;
                    
                next_addr_received <= addr_received;
                    
                next_wz_offset <= wz_offset;
                    
                next_wz_num <= wz_num;
                
                next_address_count <= address_count;  
                    
                next_mem_addr <= mem_addr;
                next_mem_wz <= mem_wz;
                    
                next_state <= current_state;
                
                case current_state is
                    when WAIT_START =>
                        if(i_start = '1') then
                            next_state <= RAM_REQ;
                        end if;
   
                    when RAM_REQ =>
                        next_o_en <= '1';
                        next_o_we <= '0';
                        if(not addr_received) then
                            next_o_address <= "0000000000001000"; --index = 8
                        else
                            next_o_address <= address_count; --only for the first WZ
                        end if;
                        
                        next_state <= WAIT_FOR_RAM;
                        
                    when WAIT_FOR_RAM =>
                        next_state <= MEM;    
                        
                    when MEM =>
                        if(not addr_received) then
                            next_mem_addr <= conv_integer(i_data);
                            next_addr_received <= true;
                            next_state <= RAM_REQ;
                        else
                            next_mem_wz <= conv_integer(i_data);
                            next_state <= CHECK_WZ;
                        end if;
                        
                    when CHECK_WZ =>
                        if(mem_addr = mem_wz) then
                            next_addr_in_wz <= true;
                            next_wz_offset <= "0001";
                            next_wz_num <= std_logic_vector(to_unsigned(wz_address, 3));
                            next_state <= ENCODE;
                        elsif(mem_addr = mem_wz + 1) then
                            next_addr_in_wz <= true;
                            next_wz_offset <= "0010";
                            next_wz_num <= std_logic_vector(to_unsigned(wz_address, 3));
                            next_state <= ENCODE;
                        elsif(mem_addr = mem_wz + 2) then
                            next_addr_in_wz <= true;
                            next_wz_offset <= "0100";
                            next_wz_num <= std_logic_vector(to_unsigned(wz_address, 3));
                            next_state <= ENCODE;
                        elsif(mem_addr = mem_wz + 3) then
                            next_addr_in_wz <= true;
                            next_wz_offset <= "1000";
                            next_wz_num <= std_logic_vector(to_unsigned(wz_address, 3));
                            next_state <= ENCODE;
                        elsif(wz_address = 7) then
                            next_addr_in_wz <= false;
                            next_state <= ENCODE;
                        else
                            next_o_en <= '1';
                            next_o_we <= '0';
                            --next_addr_in_wz <= false;
                            next_address_count <= address_count + "0000000000000001";
                            next_state <= RAM_REQ;
                        end if;
                    
                                            
                    when ENCODE =>
                        next_o_en <= '1';
                        next_o_we <= '1';
                        next_o_address <= "0000000000001001"; --index = 9
                        if(addr_in_wz) then
                            next_o_data <= "1" & wz_num & wz_offset;
                        else
                            next_o_data <= std_logic_vector(to_unsigned(mem_addr, 8));
                        end if;
                        next_o_done <= '1';
                        
                        next_state <= DONE;
                    when DONE =>
                        if(i_start = '0') then
                            next_addr_received <= false;
                            next_addr_in_wz <= false;
                            next_wz_offset <= "0000";
                            next_wz_num <= "000";
                            next_mem_addr <= 0;
                            next_mem_wz <= 0;
                            next_address_count <= "0000000000000000";
                            
                            next_state <= WAIT_START;
                        end if;
                 end case;
            end process;
   end project;