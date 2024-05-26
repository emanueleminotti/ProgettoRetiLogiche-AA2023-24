-- TB EXAMPLE PFRL 2023-2024

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity project_tb_08 is
end project_tb_08;

architecture project_tb_08_arch of project_tb_08 is
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);

    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    signal memory_control : std_logic := '0';

    -- first run
    constant SCENARIO_LENGTH : integer := 16;
    type scenario_type is array (0 to SCENARIO_LENGTH*2-1) of integer;
    signal scenario_input : scenario_type := (156, 0, 4, 0, 85, 0, 58, 0, 96, 0, 45, 0, 172, 0, 58, 0, 69, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
    signal scenario_full  : scenario_type := (156, 31, 4, 31, 85, 31, 58, 31, 96, 31, 45, 31, 172, 31, 58, 31, 69, 31, 69, 30, 69, 29, 69, 28, 69, 27, 69, 26, 1, 31, 1, 30);
    constant SCENARIO_ADDRESS : integer := 1;

    -- second run
    constant SCENARIO_LENGTH_2 : integer := 12;
    type scenario_type_2 is array (0 to SCENARIO_LENGTH_2*2-1) of integer;
    signal scenario_input_2 : scenario_type_2 := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    signal scenario_full_2  : scenario_type_2 := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
    constant SCENARIO_ADDRESS_2 : integer := 40;


    -- third run
    constant SCENARIO_LENGTH_3 : integer := 916;
    type scenario_type_3 is array (0 to SCENARIO_LENGTH_3*2-1) of integer;
    signal scenario_input_3 : scenario_type_3 := (161, 0, 206, 0, 113, 0, 249, 0, 16, 0, 142, 0, 135, 0, 207, 0, 159, 0, 254, 0, 234, 0, 234, 0, 120, 0, 137, 0, 75, 0, 14, 0, 176, 0, 220, 0, 124, 0, 211, 0, 65, 0, 162, 0, 169, 0, 31, 0, 20, 0, 152, 0, 198, 0, 106, 0, 119, 0, 113, 0, 135, 0, 180, 0, 95, 0, 116, 0, 52, 0, 122, 0, 139, 0, 120, 0, 171, 0, 116, 0, 190, 0, 68, 0, 54, 0, 9, 0, 100, 0, 80, 0, 55, 0, 77, 0, 110, 0, 44, 0, 231, 0, 15, 0, 201, 0, 192, 0, 168, 0, 92, 0, 7, 0, 121, 0, 2, 0, 87, 0, 55, 0, 143, 0, 254, 0, 190, 0, 185, 0, 121, 0, 218, 0, 19, 0, 116, 0, 76, 0, 143, 0, 77, 0, 182, 0, 199, 0, 207, 0, 226, 0, 163, 0, 50, 0, 196, 0, 28, 0, 105, 0, 191, 0, 67, 0, 20, 0, 223, 0, 138, 0, 152, 0, 74, 0, 230, 0, 237, 0, 67, 0, 173, 0, 246, 0, 71, 0, 151, 0, 123, 0, 124, 0, 142, 0, 71, 0, 0, 0, 16, 0, 225, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 139, 0, 226, 0, 95, 0, 214, 0, 9, 0, 102, 0, 204, 0, 187, 0, 111, 0, 209, 0, 156, 0, 218, 0, 201, 0, 199, 0, 251, 0, 194, 0, 198, 0, 4, 0, 61, 0, 47, 0, 167, 0, 248, 0, 247, 0, 240, 0, 52, 0, 92, 0, 171, 0, 194, 0, 151, 0, 151, 0, 220, 0, 123, 0, 206, 0, 23, 0, 22, 0, 204, 0, 192, 0, 128, 0, 60, 0, 67, 0, 174, 0, 251, 0, 57, 0, 29, 0, 68, 0, 155, 0, 113, 0, 28, 0, 252, 0, 230, 0, 208, 0, 248, 0, 81, 0, 165, 0, 106, 0, 187, 0, 57, 0, 153, 0, 188, 0, 138, 0, 12, 0, 197, 0, 0, 0, 62, 0, 101, 0, 160, 0, 191, 0, 189, 0, 44, 0, 227, 0, 63, 0, 15, 0, 80, 0, 107, 0, 80, 0, 143, 0, 239, 0, 104, 0, 26, 0, 138, 0, 239, 0, 191, 0, 39, 0, 196, 0, 40, 0, 131, 0, 224, 0, 134, 0, 28, 0, 111, 0, 249, 0, 194, 0, 1, 0, 121, 0, 141, 0, 72, 0, 226, 0, 99, 0, 141, 0, 164, 0, 92, 0, 66, 0, 124, 0, 134, 0, 107, 0, 25, 0, 220, 0, 190, 0, 196, 0, 159, 0, 56, 0, 96, 0, 164, 0, 81, 0, 157, 0, 111, 0, 223, 0, 6, 0, 211, 0, 27, 0, 237, 0, 100, 0, 193, 0, 168, 0, 180, 0, 110, 0, 157, 0, 154, 0, 38, 0, 22, 0, 73, 0, 66, 0, 245, 0, 217, 0, 102, 0, 247, 0, 219, 0, 34, 0, 23, 0, 123, 0, 207, 0, 82, 0, 169, 0, 61, 0, 64, 0, 172, 0, 180, 0, 93, 0, 248, 0, 60, 0, 125, 0, 146, 0, 59, 0, 164, 0, 70, 0, 139, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 71, 0, 99, 0, 60, 0, 12, 0, 66, 0, 175, 0, 175, 0, 176, 0, 207, 0, 79, 0, 58, 0, 90, 0, 201, 0, 40, 0, 81, 0, 246, 0, 141, 0, 115, 0, 164, 0, 206, 0, 211, 0, 129, 0, 225, 0, 9, 0, 26, 0, 173, 0, 54, 0, 34, 0, 49, 0, 188, 0, 29, 0, 31, 0, 16, 0, 45, 0, 94, 0, 61, 0, 192, 0, 170, 0, 134, 0, 115, 0, 160, 0, 209, 0, 118, 0, 219, 0, 190, 0, 196, 0, 77, 0, 36, 0, 58, 0, 178, 0, 68, 0, 60, 0, 137, 0, 203, 0, 75, 0, 95, 0, 242, 0, 59, 0, 188, 0, 84, 0, 181, 0, 207, 0, 172, 0, 5, 0, 112, 0, 140, 0, 20, 0, 245, 0, 161, 0, 65, 0, 96, 0, 80, 0, 60, 0, 0, 0, 198, 0, 244, 0, 168, 0, 175, 0, 199, 0, 26, 0, 68, 0, 57, 0, 120, 0, 66, 0, 178, 0, 151, 0, 39, 0, 227, 0, 174, 0, 40, 0, 101, 0, 0, 0, 112, 0, 112, 0, 187, 0, 238, 0, 62, 0, 221, 0, 192, 0, 154, 0, 115, 0, 255, 0, 202, 0, 48, 0, 48, 0, 113, 0, 235, 0, 66, 0, 246, 0, 244, 0, 208, 0, 134, 0, 114, 0, 77, 0, 63, 0, 102, 0, 69, 0, 234, 0, 152, 0, 227, 0, 82, 0, 87, 0, 134, 0, 40, 0, 184, 0, 168, 0, 150, 0, 132, 0, 113, 0, 57, 0, 240, 0, 67, 0, 166, 0, 139, 0, 194, 0, 1, 0, 173, 0, 161, 0, 239, 0, 246, 0, 60, 0, 246, 0, 116, 0, 44, 0, 92, 0, 156, 0, 216, 0, 210, 0, 144, 0, 105, 0, 96, 0, 55, 0, 39, 0, 14, 0, 49, 0, 31, 0, 150, 0, 129, 0, 165, 0, 33, 0, 3, 0, 182, 0, 22, 0, 71, 0, 21, 0, 67, 0, 148, 0, 147, 0, 51, 0, 21, 0, 215, 0, 103, 0, 253, 0, 151, 0, 111, 0, 134, 0, 34, 0, 193, 0, 18, 0, 133, 0, 146, 0, 227, 0, 223, 0, 150, 0, 173, 0, 35, 0, 117, 0, 23, 0, 137, 0, 127, 0, 195, 0, 101, 0, 34, 0, 38, 0, 11, 0, 57, 0, 219, 0, 221, 0, 201, 0, 128, 0, 180, 0, 68, 0, 246, 0, 137, 0, 117, 0, 209, 0, 252, 0, 185, 0, 147, 0, 237, 0, 91, 0, 177, 0, 55, 0, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 0, 108, 0, 204, 0, 149, 0, 160, 0, 92, 0, 225, 0, 238, 0, 217, 0, 184, 0, 116, 0, 217, 0, 181, 0, 158, 0, 54, 0, 79, 0, 194, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 77, 0, 185, 0, 88, 0, 255, 0, 197, 0, 47, 0, 70, 0, 151, 0, 79, 0, 135, 0, 61, 0, 137, 0, 136, 0, 209, 0, 197, 0, 150, 0, 34, 0, 82, 0, 78, 0, 202, 0, 123, 0, 7, 0, 133, 0, 120, 0, 254, 0, 72, 0, 83, 0, 7, 0, 228, 0, 205, 0, 108, 0, 61, 0, 228, 0, 59, 0, 18, 0, 196, 0, 125, 0, 197, 0, 235, 0, 220, 0, 62, 0, 0, 0, 116, 0, 124, 0, 204, 0, 132, 0, 26, 0, 21, 0, 10, 0, 219, 0, 232, 0, 161, 0, 37, 0, 155, 0, 255, 0, 47, 0, 183, 0, 143, 0, 0, 0, 49, 0, 16, 0, 246, 0, 189, 0, 215, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 53, 0, 243, 0, 76, 0, 12, 0, 148, 0, 27, 0, 11, 0, 102, 0, 28, 0, 107, 0, 190, 0, 83, 0, 253, 0, 85, 0, 32, 0, 153, 0, 239, 0, 40, 0, 27, 0, 247, 0, 73, 0, 87, 0, 134, 0, 246, 0, 215, 0, 56, 0, 213, 0, 181, 0, 133, 0, 221, 0, 62, 0, 100, 0, 8, 0, 61, 0, 204, 0, 238, 0, 110, 0, 66, 0, 192, 0, 251, 0, 134, 0, 71, 0, 139, 0, 164, 0, 69, 0, 122, 0, 112, 0, 65, 0, 185, 0, 10, 0, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 238, 0, 22, 0, 216, 0, 70, 0, 53, 0, 123, 0, 82, 0, 194, 0, 11, 0, 249, 0, 224, 0, 199, 0, 28, 0, 119, 0, 170, 0, 19, 0, 124, 0, 199, 0, 3, 0, 53, 0, 60, 0, 83, 0, 94, 0, 159, 0, 155, 0, 238, 0, 137, 0, 145, 0, 74, 0, 241, 0, 1, 0, 6, 0, 198, 0, 81, 0, 21, 0, 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 71, 0, 71, 0, 49, 0, 117, 0, 180, 0, 159, 0, 233, 0, 196, 0, 133, 0, 215, 0, 126, 0, 214, 0, 203, 0, 120, 0, 132, 0, 193, 0, 72, 0, 30, 0, 86, 0, 161, 0, 117, 0, 162, 0, 137, 0, 236, 0, 233, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    signal scenario_full_3  : scenario_type_3 := (161, 31, 206, 31, 113, 31, 249, 31, 16, 31, 142, 31, 135, 31, 207, 31, 159, 31, 254, 31, 234, 31, 234, 31, 120, 31, 137, 31, 75, 31, 14, 31, 176, 31, 220, 31, 124, 31, 211, 31, 65, 31, 162, 31, 169, 31, 31, 31, 20, 31, 152, 31, 198, 31, 106, 31, 119, 31, 113, 31, 135, 31, 180, 31, 95, 31, 116, 31, 52, 31, 122, 31, 139, 31, 120, 31, 171, 31, 116, 31, 190, 31, 68, 31, 54, 31, 9, 31, 100, 31, 80, 31, 55, 31, 77, 31, 110, 31, 44, 31, 231, 31, 15, 31, 201, 31, 192, 31, 168, 31, 92, 31, 7, 31, 121, 31, 2, 31, 87, 31, 55, 31, 143, 31, 254, 31, 190, 31, 185, 31, 121, 31, 218, 31, 19, 31, 116, 31, 76, 31, 143, 31, 77, 31, 182, 31, 199, 31, 207, 31, 226, 31, 163, 31, 50, 31, 196, 31, 28, 31, 105, 31, 191, 31, 67, 31, 20, 31, 223, 31, 138, 31, 152, 31, 74, 31, 230, 31, 237, 31, 67, 31, 173, 31, 246, 31, 71, 31, 151, 31, 123, 31, 124, 31, 142, 31, 71, 31, 71, 30, 16, 31, 225, 31, 225, 30, 225, 29, 225, 28, 225, 27, 225, 26, 225, 25, 225, 24, 225, 23, 225, 22, 225, 21, 225, 20, 225, 19, 225, 18, 225, 17, 225, 16, 225, 15, 225, 14, 225, 13, 225, 12, 225, 11, 225, 10, 225, 9, 225, 8, 225, 7, 139, 31, 226, 31, 95, 31, 214, 31, 9, 31, 102, 31, 204, 31, 187, 31, 111, 31, 209, 31, 156, 31, 218, 31, 201, 31, 199, 31, 251, 31, 194, 31, 198, 31, 4, 31, 61, 31, 47, 31, 167, 31, 248, 31, 247, 31, 240, 31, 52, 31, 92, 31, 171, 31, 194, 31, 151, 31, 151, 31, 220, 31, 123, 31, 206, 31, 23, 31, 22, 31, 204, 31, 192, 31, 128, 31, 60, 31, 67, 31, 174, 31, 251, 31, 57, 31, 29, 31, 68, 31, 155, 31, 113, 31, 28, 31, 252, 31, 230, 31, 208, 31, 248, 31, 81, 31, 165, 31, 106, 31, 187, 31, 57, 31, 153, 31, 188, 31, 138, 31, 12, 31, 197, 31, 197, 30, 62, 31, 101, 31, 160, 31, 191, 31, 189, 31, 44, 31, 227, 31, 63, 31, 15, 31, 80, 31, 107, 31, 80, 31, 143, 31, 239, 31, 104, 31, 26, 31, 138, 31, 239, 31, 191, 31, 39, 31, 196, 31, 40, 31, 131, 31, 224, 31, 134, 31, 28, 31, 111, 31, 249, 31, 194, 31, 1, 31, 121, 31, 141, 31, 72, 31, 226, 31, 99, 31, 141, 31, 164, 31, 92, 31, 66, 31, 124, 31, 134, 31, 107, 31, 25, 31, 220, 31, 190, 31, 196, 31, 159, 31, 56, 31, 96, 31, 164, 31, 81, 31, 157, 31, 111, 31, 223, 31, 6, 31, 211, 31, 27, 31, 237, 31, 100, 31, 193, 31, 168, 31, 180, 31, 110, 31, 157, 31, 154, 31, 38, 31, 22, 31, 73, 31, 66, 31, 245, 31, 217, 31, 102, 31, 247, 31, 219, 31, 34, 31, 23, 31, 123, 31, 207, 31, 82, 31, 169, 31, 61, 31, 64, 31, 172, 31, 180, 31, 93, 31, 248, 31, 60, 31, 125, 31, 146, 31, 59, 31, 164, 31, 70, 31, 139, 31, 10, 31, 10, 30, 10, 29, 10, 28, 10, 27, 10, 26, 10, 25, 10, 24, 10, 23, 10, 22, 10, 21, 10, 20, 10, 19, 10, 18, 10, 17, 10, 16, 10, 15, 10, 14, 10, 13, 10, 12, 10, 11, 10, 10, 10, 9, 10, 8, 71, 31, 99, 31, 60, 31, 12, 31, 66, 31, 175, 31, 175, 31, 176, 31, 207, 31, 79, 31, 58, 31, 90, 31, 201, 31, 40, 31, 81, 31, 246, 31, 141, 31, 115, 31, 164, 31, 206, 31, 211, 31, 129, 31, 225, 31, 9, 31, 26, 31, 173, 31, 54, 31, 34, 31, 49, 31, 188, 31, 29, 31, 31, 31, 16, 31, 45, 31, 94, 31, 61, 31, 192, 31, 170, 31, 134, 31, 115, 31, 160, 31, 209, 31, 118, 31, 219, 31, 190, 31, 196, 31, 77, 31, 36, 31, 58, 31, 178, 31, 68, 31, 60, 31, 137, 31, 203, 31, 75, 31, 95, 31, 242, 31, 59, 31, 188, 31, 84, 31, 181, 31, 207, 31, 172, 31, 5, 31, 112, 31, 140, 31, 20, 31, 245, 31, 161, 31, 65, 31, 96, 31, 80, 31, 60, 31, 60, 30, 198, 31, 244, 31, 168, 31, 175, 31, 199, 31, 26, 31, 68, 31, 57, 31, 120, 31, 66, 31, 178, 31, 151, 31, 39, 31, 227, 31, 174, 31, 40, 31, 101, 31, 101, 30, 112, 31, 112, 31, 187, 31, 238, 31, 62, 31, 221, 31, 192, 31, 154, 31, 115, 31, 255, 31, 202, 31, 48, 31, 48, 31, 113, 31, 235, 31, 66, 31, 246, 31, 244, 31, 208, 31, 134, 31, 114, 31, 77, 31, 63, 31, 102, 31, 69, 31, 234, 31, 152, 31, 227, 31, 82, 31, 87, 31, 134, 31, 40, 31, 184, 31, 168, 31, 150, 31, 132, 31, 113, 31, 57, 31, 240, 31, 67, 31, 166, 31, 139, 31, 194, 31, 1, 31, 173, 31, 161, 31, 239, 31, 246, 31, 60, 31, 246, 31, 116, 31, 44, 31, 92, 31, 156, 31, 216, 31, 210, 31, 144, 31, 105, 31, 96, 31, 55, 31, 39, 31, 14, 31, 49, 31, 31, 31, 150, 31, 129, 31, 165, 31, 33, 31, 3, 31, 182, 31, 22, 31, 71, 31, 21, 31, 67, 31, 148, 31, 147, 31, 51, 31, 21, 31, 215, 31, 103, 31, 253, 31, 151, 31, 111, 31, 134, 31, 34, 31, 193, 31, 18, 31, 133, 31, 146, 31, 227, 31, 223, 31, 150, 31, 173, 31, 35, 31, 117, 31, 23, 31, 137, 31, 127, 31, 195, 31, 101, 31, 34, 31, 38, 31, 11, 31, 57, 31, 219, 31, 221, 31, 201, 31, 128, 31, 180, 31, 68, 31, 246, 31, 137, 31, 117, 31, 209, 31, 252, 31, 185, 31, 147, 31, 237, 31, 91, 31, 177, 31, 55, 31, 200, 31, 200, 30, 200, 29, 200, 28, 200, 27, 200, 26, 200, 25, 200, 24, 200, 23, 200, 22, 200, 21, 200, 20, 200, 19, 200, 18, 200, 17, 200, 16, 200, 15, 200, 14, 200, 13, 200, 12, 200, 11, 200, 10, 200, 9, 200, 8, 200, 7, 200, 6, 200, 5, 200, 4, 200, 3, 200, 2, 200, 1, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 200, 0, 31, 31, 108, 31, 204, 31, 149, 31, 160, 31, 92, 31, 225, 31, 238, 31, 217, 31, 184, 31, 116, 31, 217, 31, 181, 31, 158, 31, 54, 31, 79, 31, 194, 31, 194, 30, 194, 29, 194, 28, 194, 27, 194, 26, 194, 25, 194, 24, 194, 23, 194, 22, 194, 21, 194, 20, 194, 19, 194, 18, 194, 17, 194, 16, 194, 15, 194, 14, 194, 13, 194, 12, 194, 11, 194, 10, 194, 9, 194, 8, 194, 7, 194, 6, 194, 5, 77, 31, 185, 31, 88, 31, 255, 31, 197, 31, 47, 31, 70, 31, 151, 31, 79, 31, 135, 31, 61, 31, 137, 31, 136, 31, 209, 31, 197, 31, 150, 31, 34, 31, 82, 31, 78, 31, 202, 31, 123, 31, 7, 31, 133, 31, 120, 31, 254, 31, 72, 31, 83, 31, 7, 31, 228, 31, 205, 31, 108, 31, 61, 31, 228, 31, 59, 31, 18, 31, 196, 31, 125, 31, 197, 31, 235, 31, 220, 31, 62, 31, 62, 30, 116, 31, 124, 31, 204, 31, 132, 31, 26, 31, 21, 31, 10, 31, 219, 31, 232, 31, 161, 31, 37, 31, 155, 31, 255, 31, 47, 31, 183, 31, 143, 31, 143, 30, 49, 31, 16, 31, 246, 31, 189, 31, 215, 31, 215, 30, 215, 29, 215, 28, 215, 27, 215, 26, 215, 25, 215, 24, 215, 23, 215, 22, 215, 21, 215, 20, 215, 19, 215, 18, 215, 17, 215, 16, 215, 15, 215, 14, 215, 13, 215, 12, 215, 11, 215, 10, 215, 9, 215, 8, 215, 7, 215, 6, 215, 5, 215, 4, 215, 3, 215, 2, 215, 1, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 215, 0, 53, 31, 243, 31, 76, 31, 12, 31, 148, 31, 27, 31, 11, 31, 102, 31, 28, 31, 107, 31, 190, 31, 83, 31, 253, 31, 85, 31, 32, 31, 153, 31, 239, 31, 40, 31, 27, 31, 247, 31, 73, 31, 87, 31, 134, 31, 246, 31, 215, 31, 56, 31, 213, 31, 181, 31, 133, 31, 221, 31, 62, 31, 100, 31, 8, 31, 61, 31, 204, 31, 238, 31, 110, 31, 66, 31, 192, 31, 251, 31, 134, 31, 71, 31, 139, 31, 164, 31, 69, 31, 122, 31, 112, 31, 65, 31, 185, 31, 10, 31, 191, 31, 191, 30, 191, 29, 191, 28, 191, 27, 191, 26, 191, 25, 191, 24, 191, 23, 191, 22, 191, 21, 191, 20, 238, 31, 22, 31, 216, 31, 70, 31, 53, 31, 123, 31, 82, 31, 194, 31, 11, 31, 249, 31, 224, 31, 199, 31, 28, 31, 119, 31, 170, 31, 19, 31, 124, 31, 199, 31, 3, 31, 53, 31, 60, 31, 83, 31, 94, 31, 159, 31, 155, 31, 238, 31, 137, 31, 145, 31, 74, 31, 241, 31, 1, 31, 6, 31, 198, 31, 81, 31, 21, 31, 88, 31, 88, 30, 88, 29, 88, 28, 88, 27, 88, 26, 88, 25, 88, 24, 88, 23, 88, 22, 88, 21, 88, 20, 88, 19, 88, 18, 88, 17, 88, 16, 88, 15, 88, 14, 88, 13, 88, 12, 88, 11, 88, 10, 88, 9, 88, 8, 88, 7, 88, 6, 88, 5, 88, 4, 88, 3, 88, 2, 88, 1, 88, 0, 71, 31, 71, 31, 49, 31, 117, 31, 180, 31, 159, 31, 233, 31, 196, 31, 133, 31, 215, 31, 126, 31, 214, 31, 203, 31, 120, 31, 132, 31, 193, 31, 72, 31, 30, 31, 86, 31, 161, 31, 117, 31, 162, 31, 137, 31, 236, 31, 233, 31, 233, 30, 233, 29, 233, 28, 233, 27, 233, 26, 233, 25, 233, 24, 233, 23, 233, 22, 233, 21, 233, 20, 233, 19, 233, 18, 233, 17, 233, 16, 233, 15, 233, 14, 233, 13, 233, 12, 233, 11, 233, 10, 233, 9, 233, 8, 233, 7, 233, 6, 233, 5, 233, 4, 233, 3, 233, 2, 233, 1, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0, 233, 0);
    -- constant SCENARIO_ADDRESS_3 : integer := 28;
    constant SCENARIO_ADDRESS_3 : integer := 128;


    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                
                o_done => tb_done,
                
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.
    
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        wait for 50 ns;

        -- Signal initialization and reset of the component
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        
        -- Wait some time for the component to reset...
        wait for 50 ns;
        
        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO_LENGTH*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;


        -- Configure second run
        
        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_2(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH, 10));
        
        tb_start <= '1';

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        wait for 5 ns;
        
        tb_start <= '0';

        -- start sencond run without reset

        wait for 50 ns;

        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_2, 10));
        
        tb_start <= '1';

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        wait for 5 ns;
        
        tb_start <= '0';
        
        wait for 50 ns;

        -- configure third run
        -- write over already elaborated data
        memory_control <= '0';
        wait until falling_edge(tb_clk);
        
        -- Configure third run

        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_3(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';

        -- start third run without reset

        wait for 50 ns;

        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_3, 10));
        
        tb_start <= '1';

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        
        wait for 5 ns;
        
        tb_start <= '0';

        
        wait;
        
    end process;

    -- Process without sensitivity list designed to test the actual component.
    test_routine : process
    begin

        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';

        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH*2-1 loop
            assert RAM(SCENARIO_ADDRESS+i) = std_logic_vector(to_unsigned(scenario_full(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);


        -- second run
        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            assert RAM(SCENARIO_ADDRESS_2+i) = std_logic_vector(to_unsigned(scenario_full_2(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_2(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);



        -- third run
        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            assert RAM(SCENARIO_ADDRESS_3+i) = std_logic_vector(to_unsigned(scenario_full_3(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_3(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);



        -- end

        assert false report "Simulation Ended! TEST PASSATO (EXAMPLE)" severity failure;
    end process;

end architecture;
