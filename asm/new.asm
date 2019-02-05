STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
MAS DB 'ERROR Limit EXENDED$'
DUMP DB 7,?,7 dup('?')


DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"



print_someone_shit:
push dx
push ax
lea dx, mas
mov ah,9
int 21h
pop dx
pop ax
ret


 
 
MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG
; адреса повернення
PUSH DS
;mov AX, 0
PUSH AX
;init DS
MOV AX, DSEG
MOV DS, AX



;;;;;


call print_someone_shit
   
   
  




RET






MAIN ENDP
CSEG ENDS
END MAIN