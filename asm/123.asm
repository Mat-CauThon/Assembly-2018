STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ("STACK")
STSEG ENDS
;??????? ?????

DSEG SEGMENT PARA PUBLIC "DATA"


string     db      'Some stroka hear $'
string2 db 10,13,'lolkek$'
something db 90
string89 dw ?
DSEG ENDS
;??????? ?????
CSEG SEGMENT PARA PUBLIC "CODE"
   
 MAIN PROC FAR
ASSUME CS: CSEG, DS:DSEG, SS:STSEG, ES:DSEG
   PUSH DS
	XOR AX, AX
	PUSH AX

	MOV AX, DSEG
	MOV DS, AX
	MOV ES, AX
	
	lea dx, string
	mov ah,9
	int 21h
		
		mov al, '9'
	;	mov     ah,01h     
;		int     21h        ;в al — введённый символ
        lea     di,string  ;начало string
        stos    string2    ;сохраним введённый символ
		;inc di
		;stos	string89
lea dx, string
	mov ah,9
	int 21h

			
lea dx, string2
	mov ah,9
	int 21h
	
   ret
    
MAIN ENDP
CSEG ENDS
END MAIN