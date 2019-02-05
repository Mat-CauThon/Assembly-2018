input MACRO
 mov ah,0Ah              ;Функция DOS 0Ah - ввод строки в буфер
   
    lea dx,userNumber           ;DX = aдрес буфера
    int 21h                 ;Обращение к функции DOS
    mov al,[userNumber+1]       ;AL = длина введённой строки
    add dx,2                ;DX = адрес строки

ENDM

convert MACRO
	test al,al    ;Проверка длины строки
    jz errorMost	            ;Если равно 0, возвращаем ошибку
    mov bx, offset dx      	;BX = адрес строки
    mov bl,[bx]             ;BL = первый символ строки
    cmp bl,'-'              ;Сравнение первого символа с '-'
    jne stsdw_no_sign       ;Если не равно, то преобразуем как число без знака
    inc dx                  ;Инкремент адреса строки
    dec al                  ;Декремент длины строки
    stsdw_no_sign:
    call number_module   ;Преобразуем строку в слово без знака
	jc errorMost
    cmp bl,'-'              ;Снова проверяем знак
    jne stsdw_plus          ;Если первый символ не '-', то число положительное
    cmp ax,32768            ;Модуль отрицательного числа должен быть не больше 32768
    ja errorMost		        ;Если больше (без знака), возвращаем ошибку
    neg ax                  ;Инвертируем число
    jmp stsdw_ok            ;Переход к нормальному завершению процедуры
    stsdw_plus:
    cmp ax,32767            ;Положительное число должно быть не больше 32767
    ja errorMost      		    ;Если больше (без знака), возвращаем ошибку
    stsdw_ok:
    clc                     ;CF = 0

ENDM



divid MACRO where_save
LOCAL ok

		;inc si
		mov ax,dx
		
		mul ten
		mov bx,ax
		
		;cmp ax,di 	;; !!!!!!
		
		cwd
		div di
		
		cmp ax,0
		jge ok
		
		xor ax,ax
		
		ok:
		call write
		mov ax,bx

		mov where_save, ax
		
ENDM

write_mes MACRO what_write

	lea dx, what_write
	mov ah,9
	int 21h

ENDM


STSEG SEGMENT PARA STACK "STACK"
DB 128 DUP ( "STACK" )
STSEG ENDS



DSEG SEGMENT PARA PUBLIC "DATA"

userNumber DB 7,?,5 dup('?')	;Запись максимальной длины в первый байт буфера и обнуление второго байта (фактической длины)
error_test DB 'ERROR $'
error_big DB 'ERROR, Your number not a mezha $'
your_num DB 10,13,'Your function Z is -> $'
write_num DB 10,13,'Write your number x [-80,1646] -> $'

twenty db 20
ten db 10
five db 5
three db 3
two db 2
nine db 9

integ dw 0 	; целая
denth dw 0	; десятые
hundr dw 0	; сотые
thous dw 0	; тысячные
dthou dw 0	; дес тысячных
hthou dw 0	; сотни тысячных
milli dw 0	; милионная часть числа

stroka db 13, 10, ' '



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
	write_mes write_num
	
	
;;;;;

	input
	
;;;;;	

	convert
	
	
	mov bx, ax
	
		write_mes your_num
		
	mov ax,bx
	
	cmp ax,0
	jle second1 ;number <= 0
	first:
	
	xor dx,dx
	xor si,si
	xor di,di
	mov bx,ax			;save x

	mul bx				; ax = x^2
	mul three
	mov si,ax			; si = x^2
	
	
	
	mov ax,bx			; ax = x
	mul nine			; ax = 3x
	
	add ax,si			; ax = x^2 + 3x
	add ax,6			; ax = x^2+3x+2
	
	mov di,ax			; di = x^2+3x+2
	mov ax,bx			; ax = x
	mul twenty			; ax = 20x
	add ax,25			; ax = 20x+35
	
	
	
	
	
	jmp continue
	errorMost:
	jmp error
	prebigerror:
	jmp errorBig
	second1:
	jmp second
	continue:
	
	cwd
	div di
	call write

	mov integ, ax
	
		mov al,','
		int 29h
		
		
		

	divid denth
	divid thous
	divid thous
	divid dthou
	divid hthou
	divid milli
	
	

	
	
	jmp return_zero
	
	second:
		cmp ax,0
		jl minus
		mov al, '5'
		int 29h
		jmp return_zero
		
	minus:	
		
		push ax
		mov al, '-'
		int 29h
		pop ax
		
		neg ax  ;; 
		
		xor dx,dx
		xor si,si
		xor di,di
		mov bx,ax			;save x

		
		add ax,1
		mov di,ax			; si = 1 - x
	
		mov ax,bx			; ax = x
		;neg ax
		mul five			; ax = 5x
		mul bx				; ax = 5x^2

		;mov di,ax			; di = 5x^2
		
		
		cwd
		div di
	
	call write
	;integend:
	mov integ, ax
	
		mov al,','
		int 29h
		
	divid denth
	divid thous
	divid thous
	divid dthou
	divid hthou
	divid milli
	
	
	
	jmp return_zero
	
	

	
	error:
		mov ax,03  	;;  очистка экрана
		int 10h		;;

		
		write_mes error_test
		jmp return_zero
		
	errorBig:
		mov ax,03  	;;  очистка экрана
		int 10h		;;

		write_mes error_big
		
		
		
 return_zero:
 
 
RET

MAIN ENDP

	
write PROC

	push dx
	
	mov bx,ax
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

	pop dx
	ret
write ENDP


number_module PROC
    push cx                 ;Сохранение всех используемых регистров
    push dx
    push bx
    push si
    push di
 
    mov si, offset dx       ;SI = адрес строки
    mov di,10               ;DI = множитель 10 (основание системы счисления)
	
	;movcs cx,al не работает, спросить почему!
	xor cx,cx
	mov cl,al
	
    xor ax,ax               ;AX = 0
    xor bx,bx               ;BX = 0
 
studw_lp:
    mov bl,[si]             ;Загрузка в BL очередного символа строки
    inc si                  ;Инкремент адреса
    cmp bl,'0'              ;Если код символа меньше кода '0'
    jb studw_error          ; возвращаем ошибку
    cmp bl,'9'              ;Если код символа больше кода '9'
    ja studw_error          ; возвращаем ошибку
    sub bl,'0'              ;Преобразование символа-цифры в число
    mul di                  ;AX = AX * 10
    jc studw_error          ;Если результат больше 16 бит - ошибка
    add ax,bx               ;Прибавляем цифру
    jc studw_error          ;Если переполнение - ошибка
    loop studw_lp           ;Команда цикла
    jmp studw_exit          ;Успешное завершение (здесь всегда CF = 0)

studw_error:
    xor ax,ax               ;AX = 0
    stc                     ;CF = 1 (Возвращаем ошибку)

studw_exit:
    pop di                  ;Восстановление регистров
    pop si
    pop bx
    pop dx
    pop cx
    ret
number_module ENDP




CSEG ENDS
END MAIN