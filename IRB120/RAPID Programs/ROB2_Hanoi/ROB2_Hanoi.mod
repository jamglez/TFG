MODULE ROB2_Hanoi

    PROC main()
        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;
        
        !Carga el trabajo de la camara y lo pone en modo de funcionamiento
        CamSetProgramMode mycamera;
        CamLoadJob mycamera,camera_job;
        CamSetRunMode mycamera;
        
        TCP_connect;

        WHILE keep_listening DO
            SocketReceive client_socket\Str:=received_order;

            IF received_order="scan" THEN
                get_initial_state;

            ELSEIF received_order="info" THEN
                SocketSend client_socket\Str:=initial_state;

            ELSEIF received_order="place" THEN
                move_to_pass_point TRUE;
                move_to_stack FALSE;

            ELSEIF received_order="pick" THEN
                move_to_stack TRUE;
                move_to_pass_point FALSE;

            ELSEIF received_order="END" THEN
                TCP_close;
            ENDIF
        ENDWHILE
    ENDPROC

    !Comenzar comunicacion
    PROC TCP_connect()
        SocketCreate server_socket;
        SocketBind server_socket,IP_Address,port_number;
        SocketListen server_socket;
        SocketAccept server_socket,client_socket;

        SocketReceive client_socket\Str:=received_order;
        SocketSend client_socket\Str:="Conexion establecida";

    ENDPROC

    !Shutdown the connection
    PROC TCP_close()
        SocketSend client_socket\Str:="Cerrando conexion";
        SocketClose client_socket;
        SocketClose server_socket;
        keep_listening:=FALSE;
    ENDPROC

    !Mover brazo a un punto de recogida/dejada
    !Indicar si recoge (1) o deja la pieza (0)
    PROC move_to_stack(bool grab_piece)


        IF grab_piece THEN
            MoveJ Offs(stack_point,0,0,(piece_height*pieces_on_C)+50),fast_speed,fine,vacuum_tool\WObj:=wo_c;
            MoveL Offs(stack_point,0,0,(piece_height*pieces_on_C)),slow_speed,fine,vacuum_tool\WObj:=wo_c;

            WaitTime 0.5;
            SetDO ventosa,1;
            pieces_on_C:=pieces_on_C-1;
            WaitTime 0.5;

            MoveL Offs(stack_point,0,0,(piece_height*pieces_on_C)+50),slow_speed,fine,vacuum_tool\WObj:=wo_c;
        ELSE
            MoveJ Offs(stack_point,0,0,(piece_height*(pieces_on_C+1))+50),fast_speed,fine,vacuum_tool\WObj:=wo_c;
            MoveL Offs(stack_point,0,0,(piece_height*(pieces_on_C+1))),slow_speed,fine,vacuum_tool\WObj:=wo_c;

            WaitTime 0.5;
            SetDO ventosa, 0;
            pieces_on_C:=pieces_on_C+1;
            WaitTime 0.5;

            MoveL Offs(stack_point,0,0,(piece_height*(pieces_on_C+1))+50),slow_speed,fine,vacuum_tool\WObj:=wo_c;
        ENDIF

        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;

    ENDPROC

    !Mueve el brazo al punto de paso. Se debe indicar 
    !si coge la pieza (1) o la pasa (0)
    PROC move_to_pass_point(bool grab_piece)
        MoveJ Offs(passing_point,0,50,0),fast_speed,fine,vacuum_tool\WObj:=wobj0;
        MoveL passing_point,slow_speed,fine,vacuum_tool\WObj:=wobj0;

        IF grab_piece THEN
            !Espera la del otro robot que ha cogido la pieza y la ha movido al punto de paso
            SocketReceive client_socket\Str:=received_string;
            SetDO ventosa, 1;
            WaitTime 0.5;
            SocketSend client_socket\Str:="ok";
            WaitTime 0.5;
        ELSE
            !Si se pasa la pieza, se avisa al otro robot de que ya está listo
            SocketSend client_socket\Str:="Ready";
            !Se espera a la orden "ok" indicando que el otro ha activado la ventosa
            SocketReceive client_socket\Str:=received_string;
            SetDO ventosa, 0;
            WaitTime 0.5;
            SetDO ventosa, 0;
            WaitTime 0.5;
        ENDIF
        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;
    ENDPROC

    !Obtiene el estado inicial, comprobando que piezas se encuentran en la torre C,
    !de modo que el string 'initial_state' contiene las piezas de C. 
    !Por ejemplo, si los discos 2 y 5 estan en C, 'initial_state' seria 02005.
    PROC get_initial_state()
        !Inicializa el estado a nulo y adquiere la imagen
        initial_state:="";
        CamReqImage mycamera;

        !Obtiene la posicion de la torre C
        CamGetParameter mycamera,"Stack_C.Fixture.X"\NumVar:=stack_C_pos.x;
        CamGetParameter mycamera,"Stack_C.Fixture.Y"\NumVar:=stack_C_pos.y;
        wo_c.oframe.trans.x:=stack_C_pos.x;
        wo_c.oframe.trans.y:=stack_C_pos.y;

        !Obtiene el número de piezas que hay en la torre C
        FOR i FROM 1 TO MAX_PIECES DO
            !Posicion de la pieza i
            temp_string:=NumToStr(i,0);
            CamGetParameter mycamera,"Circle"+temp_string+".Fixture.X"\NumVar:=temp_pos.x;
            CamGetParameter mycamera,"Circle"+temp_string+".Fixture.Y"\NumVar:=temp_pos.y;

            !si no es nula, significa que está en la torre
            IF temp_pos<>[0,0,0] THEN
                pieces_on_C:=pieces_on_C+1;
                initial_state:=initial_state+temp_string;
            ELSE
                initial_state:=initial_state+"0";
            ENDIF

        ENDFOR
    ENDPROC
ENDMODULE