MODULE Data

    CONST num MAX_PIECES:=5;

    !Comunicacion
    CONST string IP_Address:="172.21.33.222";
    CONST num port_number:=8000;
    VAR socketdev server_socket;
    VAR socketdev client_socket;
    VAR string received_order;
    VAR string received_string;
    VAR bool keep_listening:=TRUE;

    !Vision
    CONST string camera_job:="ROB2_Hanoi.job";
    VAR pos stack_C_pos;
    VAR num pieces_on_C;
    VAR string initial_state;
    VAR string temp_string;
    VAR pos temp_pos;

    !Movimiento
    CONST num piece_height:=20;
    CONST speeddata fast_speed:=v100;
    CONST speeddata slow_speed:=v20;
    PERS tooldata vacuum_tool:=[TRUE,[[0,0,60],[1,0,0,0]],[0.4,[0,0,1],[1,0,0,0],0,0,0]];
    TASK PERS wobjdata wo_c:=[FALSE,TRUE,"",[[425.876,15.5516,34.3723],[1,-0.000789703,0.000489273,-1.0788E-05]],[[-59.2493,-1.66285,0],[1,0,0,0]]];
    CONST robtarget stack_point:=[[-0.08,0.09,-13],[0.000332633,0.000292296,-1,-0.000781366],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget HOME:=[[236.38,23.25,480.49],[0.000528585,7.18936E-05,-1,-3.4913E-05],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget passing_point:=[[300,-352.5,450],[0.5,0.5,0.5,-0.5],[-1,-2,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];

ENDMODULE