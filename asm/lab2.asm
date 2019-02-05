STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS



DSEG SEGMENT PARA PUBLIC "DATA"
MAS DB 'Test 1$'
MASERROR DB 'ERROR NOT A SYMBOL$'
userNumber DB 7,?,5 dup('?')

error_test DB 'ERROR',10,'$' ; СООБЩЕНИЕ О ОШИБКЕ С ПЕРЕВОДОМ СТРОКИ



DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"

 


MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG
; адреса повернення
  PUSH DS
  XOR AX, AX
  PUSH AX

  MOV AX, DSEG
  MOV DS, AX

  
  
;;;;;

input_str:
	mov al,7
    mov cx,ax               ;Сохранение AX в CX
    mov ah,0Ah              ;Функция DOS 0Ah - ввод строки в буфер
    ;mov [userNumber],al         ;Запись максимальной длины в первый байт буфера
    mov byte[userNumber+1],0    ;Обнуление второго байта (фактической длины)
    lea dx,userNumber           ;DX = aдрес буфера
    int 21h                 ;Обращение к функции DOS
    mov al,[userNumber+1]       ;AL = длина введённой строки
    add dx,2                ;DX = адрес строки
    mov ah,ch               ;Восстановление AH
	
	
	
	mov di,0
	xor cx,cx
	mov cl,al
	xor bx,bx               ;BX = 0
symbol_testing:
	
	;lea si,dx               ;SI = адрес строки
    mov si,10               ;SI = множитель 10 (основание системы счисления)
    xor ax,ax               ;AX = 0

	lea bx, userNumber
	
	

    mov al,[bx+di+2]        ;Загрузка в AL очередного символа строки
    inc di                  ;Инкремент адреса
    cmp al,'0'              ;Если код символа меньше кода '0'
    jb symbol_test
    cmp al,'9'              ;Если код символа больше кода '9'
    ja symbol_test
	
	
    sub ax,'0'              ;Преобразование символа-цифры в число
    mul si                  ;AX = AX * 10
    jc error       		    ;Если результат больше 16 бит - ошибка
    add bx,ax               ;Прибавляем цифру
    jc error	            ;Если переполнение - ошибка
    loop symbol_testing           ;Команда цикла
   
	


	
	;mov bx, num
	or bx, bx
	jns m1
	mov al, '-'
	int 29h
	neg bx
	m1:
	mov ax, bx
	xor cx, cx
	mov bx, 10
	m2:
	xor dx, dx
	div bx
	add dl, '0'
	push dx
	inc cx
	test ax, ax
	jnz m2
	m3:
	pop ax
	int 29h
	loop m3

	jmp return_zero
	
	
symbol_test:
	
		cmp al,'-'
		jne  error
		
		or di,di
		jnz error
		
		pop ax
		push 1
		
		jmp symbol_testing


	
  error:
		lea dx,error_test
		mov ah,9
		int 21h

 return_zero:
 
RET

 
   


MAIN ENDP
CSEG ENDS
END MAIN