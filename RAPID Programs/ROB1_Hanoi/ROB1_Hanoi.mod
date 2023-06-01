MODULE ROB1_Hanoi

    PROC main()
        END := FALSE;
        connected_to_server:=FALSE;
        n_pieces:=[0,0,0];

        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;
        
        !Cargar el trabajo de la camara
        CamSetProgramMode IntegratedVision1;
        CamLoadJob IntegratedVision1,camera_job;
        CamSetRunMode IntegratedVision1;

        TCP_connect;

        WHILE NOT END DO
            IF DO_solve=1 THEN
                get_initial_state;
                Hanoi END_STACK;
            ENDIF
        ENDWHILE
        TCP_close;

    ENDPROC

    PROC TCP_connect()
        !Crear socket y conectar
        SocketCreate socket1;
        SocketConnect socket1,server_IP,port_number;

        !Confirmar comunicacion
        SocketSend socket1\Str:="Hello server";
        SocketReceive socket1\Str:=received_string;
        connected_to_server:=TRUE;
    ENDPROC

    !Envia el mensaje de cierre al servidor y cierra el socket
    PROC TCP_close()
        SocketSend socket1\Str:="END";
        SocketReceive socket1\Str:=received_string;
        SocketClose socket1;
        connected_to_server:=FALSE;
    ENDPROC

    !Mover brazo a un punto de recogida/dejada en el workobject indicado. 
    !Indicar si recoge (1) o deja la pieza (0)
    PROC move_to_stack(num stack,bool grab_piece)
        IF stack = 1 THEN
            temp_wo:=wo_a;
        ELSE
            temp_wo:=wo_b;
        ENDIF

        IF grab_piece THEN
            MoveJ Offs(grab_point,0,0,(piece_height*n_pieces{stack})+50),fast_speed,fine,vacuum_tool\WObj:=temp_wo;
            MoveL Offs(grab_point,0,0,(piece_height*n_pieces{stack})),slow_speed,fine,vacuum_tool\WObj:=temp_wo;
            WaitTime 0.5;
            SetDO DO_ventosa, 1;
            n_pieces{stack} := n_pieces{stack} -1;
            WaitTime 0.5;
            MoveL Offs(grab_point,0,0,(piece_height*n_pieces{stack})+50),slow_speed,fine,vacuum_tool\WObj:=temp_wo;
        ELSE
            MoveJ Offs(grab_point,0,0,(piece_height*(n_pieces{stack}+1))+50),fast_speed,fine,vacuum_tool\WObj:=temp_wo;
            MoveL Offs(grab_point,0,0,(piece_height*(n_pieces{stack}+1))),slow_speed,fine,vacuum_tool\WObj:=temp_wo;
            WaitTime 0.5;
            SetDO DO_ventosa, 0;
            n_pieces{stack} := n_pieces{stack} +1;
            WaitTime 0.5;
            MoveL Offs(grab_point,0,0,(piece_height*(n_pieces{stack}+1))+50),slow_speed,fine,vacuum_tool\WObj:=temp_wo;
        ENDIF

        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;

    ENDPROC

    !Mueve el brazo al punto de paso. Se debe indicar 
    !si coge la pieza (1) o la pasa (0)
    PROC move_to_pass_point(bool grab_piece)
        MoveJ Offs(passing_point,0,-50,0),fast_speed,fine,vacuum_tool\WObj:=wobj0;
        MoveL passing_point,slow_speed,fine,vacuum_tool\WObj:=wobj0;

        IF grab_piece THEN
            !Espera la del otro robot que ha cogido la pieza y la ha movido al punto de paso
            SocketReceive socket1\Str:=received_string;
            SetDO DO_ventosa, 1;
            n_pieces{3} := n_pieces{3}-1;
            WaitTime 0.5;
            SocketSend socket1\Str:="vacuum_activated";
            WaitTime 0.5;
        ELSE
            !Si se pasa la pieza, se avisa al otro robot de que ya está listo
            SocketSend socket1\Str:="arrived";
            !Se espera a la orden "ok" indicando que el otro ha activado la ventosa
            SocketReceive socket1\Str:=received_string;
            SetDO DO_ventosa, 0;
            n_pieces{3} := n_pieces{3}+1;
            WaitTime 0.5;
        ENDIF

        MoveJ HOME,fast_speed,fine,vacuum_tool\WObj:=wobj0;
    ENDPROC

    !Obtiene el estado inicial de la escena, es decir, la posicion 
    !de la tres torres y el numero de piezas que hay en cada una
    PROC get_initial_state()

        !Enviar la orden para que el robot2 tambien analice su escena
        SocketSend socket1,\Str:="scan";

        !Adquiere imagen
        CamReqImage IntegratedVision1;

        !Posicion del Stack A
        CamGetParameter IntegratedVision1,"Stack_A.Fixture.X"\NumVar:=stack_A_pos.x;
        CamGetParameter IntegratedVision1,"Stack_A.Fixture.Y"\NumVar:=stack_A_pos.y;
        wo_a.oframe.trans.x:=stack_A_pos.x;
        wo_a.oframe.trans.y:=stack_A_pos.y;

        !Posicion del Stack B
        CamGetParameter IntegratedVision1,"Stack_B.Fixture.X"\NumVar:=stack_B_pos.x;
        CamGetParameter IntegratedVision1,"Stack_B.Fixture.Y"\NumVar:=stack_B_pos.y;
        wo_b.oframe.trans.x:=stack_B_pos.x;
        wo_b.oframe.trans.y:=stack_B_pos.y;

        get_number_of_pieces;

    ENDPROC

    !Obtiene el numero de piezas de cada torre
    PROC get_number_of_pieces()
        n_pieces := [0,0,0];
        !Obtiene la informacion de la torre C, y pasa el string a valor numerico para decodificarlo
        SocketSend socket1\Str:="info";
        SocketReceive socket1\Str:=received_string;
        str2val:=StrToVal(received_string,temp_num);

        !Itera todas las piezas
        FOR i FROM MAX_PIECES TO 1 STEP -1 DO
            temp_string:=NumToStr(i,0);
            CamGetParameter IntegratedVision1,"Circle"+temp_string+".Fixture.X"\NumVar:=temp_pos.x;
            CamGetParameter IntegratedVision1,"Circle"+temp_string+".Fixture.Y"\NumVar:=temp_pos.y;

            !Si la pieza se encuentra en la escena del robot 1, 
            IF temp_pos<>[0,0,0] THEN
                !Se calcula si esta cerca de la torre A, si es así, está en A y si no, está en B
                IF Distance(temp_pos,stack_A_pos)<50 THEN
                    n_pieces{1}:=n_pieces{1}+1;
                    moves{i}.start:=1;
                ELSE
                    n_pieces{2}:=n_pieces{2}+1;
                    moves{i}.start:=2;
                ENDIF
            ENDIF

            !Por otro lado si el digito en la posicion 'i' del mensaje recibido es igual a 'i'
            !Significa que la torre C, tiene esa pieza
            IF temp_num MOD 10=i THEN
                !Se incrementa el numero de piezas en C
                n_pieces{3}:=n_pieces{3}+1;
                !Se establece que esa pieza está inicialmente en C
                moves{i}.start:=3;
            ENDIF
            temp_num:=temp_num DIV 10;
        ENDFOR

        total_pieces:=n_pieces{1}+n_pieces{2}+n_pieces{3};
    ENDPROC

ENDMODULE