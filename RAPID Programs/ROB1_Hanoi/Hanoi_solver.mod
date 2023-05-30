MODULE Hanoi_solver

    !Inicializa el estado deseado dependiendo 
    !de la torre final seleccionada
    PROC initialize_desired_state()
        total_moves := 0;
        FOR i FROM 1 TO MAX_PIECES DO
            desired_state{END_STACK,i}:=i;

            !Para resolver con un numero menor de piezas,
            !se 'colocan' esas piezas a mano
            IF total_pieces<i THEN
                stacks{1,i}:=0;
                stacks{2,i}:=0;
                stacks{3,i}:=0;
                stacks{END_STACK,i}:=i;
            ENDIF
        ENDFOR

    ENDPROC

    !Algoritmo de Torres de Hanoi con la variante de que en el estado inicial
    !no todas las piezas tienen porqué estar en la misma torre. 
    PROC Hanoi(num end)

        initialize_desired_state;

        !La pieza más grande se quiere estar en el stack final
        moves{total_pieces}.end:=end;

        !Mientras no esté resuelto
        WHILE NOT stacks=desired_state DO

            !Se calcula el movimiento para cada pieza
            FOR i FROM total_pieces-1 TO 1 STEP -1 DO
                !Si la pieza i+1 está ya en el stack donde quiere estar, 
                !la pieza i quiere estar en el mismo stack que la i+1
                IF moves{i+1}.start=moves{i+1}.end THEN
                    moves{i}.end:=moves{i+1}.end;
                    !Si no, la pieza i no quiere estar donde empieza ni donde acaba la i+1
                ELSE
                    moves{i}.end:=6-(moves{i+1}.start+moves{i+1}.end);
                ENDIF
            ENDFOR

            !Se realiza el movimiento:
            !Mover el menor disco que no quiere estar donde está
            FOR i FROM 1 TO total_pieces DO
                IF NOT moves{i}.start=moves{i}.end THEN
                    make_hanoi_move moves{i};
!                    TPWrite "Movimiento desde: "\Num:=moves{i}.start;
!                    TPWrite "Hacia: "\Num:=moves{i}.end;

                    stacks{moves{i}.start,i}:=0;
                    stacks{moves{i}.end,i}:=i;
                    moves{i}.start:=moves{i}.end;
                    total_moves:=total_moves+1;
                    GOTO break;
                ENDIF
            ENDFOR
            break:
        ENDWHILE
        !TPWrite "Movimientos totales: "\Num:=total_moves;

    ENDPROC

    !Recibe el movimiento a hacer (Torre inicial y torre destino)   
    !y coordina los robots para realizar el movimiento.
    PROC make_hanoi_move(var hanoi_move mv)

        !En el caso de que la pieza involucre al robot2, se manda 
        !la orden primero para que ambos robots se muevan paralelamente
        IF mv.end=3 SocketSend socket1\Str:="place";
        IF mv.start=3 SocketSend socket1\Str:="pick";

        TEST mv.start
        CASE 1,2:
            move_to_stack mv.start,TRUE;
        CASE 3:
            move_to_pass_point TRUE;
        ENDTEST
        TEST mv.end
        CASE 1,2:
            move_to_stack mv.end,FALSE;
        CASE 3:
            move_to_pass_point FALSE;
        ENDTEST
    ENDPROC

ENDMODULE