MODULE Data

    RECORD hanoi_move
        num start;
        num end;
    ENDRECORD

    CONST num MAX_PIECES:=5;
    PERS num END_STACK:=3;
    PERS num n_pieces{3}:=[0,0,0];
    VAR num total_pieces;
    VAR num total_moves:=0;
    VAR num stacks{3,MAX_PIECES}:=[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]];
    VAR num desired_state{3,MAX_PIECES}:=[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]];
    VAR hanoi_move moves{MAX_PIECES}:=[[0,0],[0,0],[0,0],[0,0],[0,0]];

    !Comunicacion TCP/IP
    CONST string server_IP:="172.21.33.222";
    CONST num port_number:=8000;
    PERS bool connected_to_server:=False;
    VAR string received_string;
    VAR socketdev socket1;

    !Vision
    CONST string camera_job:="ROB1_Hanoi.job";
    VAR string temp_string;
    VAR bool str2val;
    VAR num temp_num;
    VAR pos temp_pos;
    VAR pos stack_A_pos;
    VAR pos stack_B_pos;

    !Variables y parametros
    PERS bool END;
    CONST num piece_height:=20;
    CONST speeddata fast_speed:=v100;
    CONST speeddata slow_speed:=v20;
    PERS tooldata vacuum_tool:=[TRUE,[[0,0,60],[1,0,0,0]],[0.4,[0,0,1],[1,0,0,0],0,0,0]];
    CONST robtarget HOME:=[[236.38,23.25,480.49],[0.000528585,7.18936E-05,-1,-3.4913E-05],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget passing_point:=[[320.70,424.54,445.79],[0.499854,-0.5003,0.499355,0.500491],[0,1,-2,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget grab_point:=[[5,10,-37.84],[0.000122904,-0.00141816,-0.999999,-0.000343476],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    TASK PERS wobjdata wo_a:=[FALSE,TRUE,"",[[448.203,36.8258,60.9458],[0.999999,-0.000331686,0.000243147,0.00150912]],[[-68.9876,-112.51,0],[1,0,0,0]]];
    TASK PERS wobjdata wo_b:=[FALSE,TRUE,"",[[448.203,36.8258,60.9458],[0.999999,-0.000331686,0.000243147,0.00150912]],[[-68.3876,87.3479,0],[1,0,0,0]]];
    TASK PERS wobjdata temp_wo:=[FALSE, TRUE, "",[[448.203, 36.8258, 60.9458],[0.999999, -0.000331686, 0.000243147, 0.00150912]],[[-68.3971,87.3761,0],[1,0,0,0]]];

ENDMODULE