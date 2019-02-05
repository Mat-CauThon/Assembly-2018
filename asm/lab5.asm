
output MACRO number

    mov bx, number
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

ENDM

write_mes MACRO message

	lea dx, message
	mov ah,9
	int 21h

ENDM

convert MACRO
	test al,al    ;Проверка длины строки
    jz error	            ;Если равно 0, возвращаем ошибку
    mov bx, offset dx      	;BX = адрес строки
    mov bl,[bx]             ;BL = первый символ строки
    cmp bl,'-'              ;Сравнение первого символа с '-'
    jne stsdw_no_sign       ;Если не равно, то преобразуем как число без знака
    inc dx                  ;Инкремент адреса строки
    dec al                  ;Декремент длины строки
    stsdw_no_sign:
    call str_to_udec_word   ;Преобразуем строку в слово без знака
	jc error
    cmp bl,'-'              ;Снова проверяем знак
    jne stsdw_plus          ;Если первый символ не '-', то число положительное
    cmp ax,32768            ;Модуль отрицательного числа должен быть не больше 32768
    ja error		        ;Если больше (без знака), возвращаем ошибку
    neg ax                  ;Инвертируем число
    jmp stsdw_ok            ;Переход к нормальному завершению процедуры
    stsdw_plus:
    cmp ax,32767            ;Положительное число должно быть не больше 32767
    ja error      		    ;Если больше (без знака), возвращаем ошибку
    stsdw_ok:
    clc                     ;CF = 0

ENDM


input MACRO
 mov ah,0Ah              ;Функция DOS 0Ah - ввод строки в буфер
   
    lea dx,userNumber           ;DX = aдрес буфера
    int 21h                 ;Обращение к функции DOS
    mov al,[userNumber+1]       ;AL = длина введённой строки
    add dx,2                ;DX = адрес строки

ENDM



STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS



DSEG SEGMENT PARA PUBLIC "DATA"

write_num DB 10,13,'Write your number -> $'

userNumber DB 7,?,5 dup('?')
error_test DB 10,13,'ERROR $'
your_num DB 10,13,'Your number is -> $'
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
	convert
	
	mov di,ax
	
	write_mes your_num
	
	mov ax,di
	
	output ax
	
	
	
	jmp return_zero
	
  error:
		mov ax,03
		int 10h

	write_mes error_test
		
		
 return_zero:
 
RET

 
MAIN ENDP






 str_to_udec_word proc
    push cx                 ;Сохранение всех используемых регистров
    push dx
    push bx
    push si
    push di
 
    mov si, offset dx               ;SI = адрес строки
    mov di,10               ;DI = множитель 10 (основание системы счисления)
	xor cx,cx
	mov cl,al
	
    xor ax,ax               ;AX = 0
    xor bx,bx               ;BX = 0
 
studw_lp:
    mov bl,[si]             ;Загрузка в BL очередного символа строки
    inc si                  ;Инкремент адреса
    cmp bl,'0'              ;Если код символа меньше кода '0'
    jl studw_error          ; возвращаем ошибку
    cmp bl,'9'              ;Если код символа больше кода '9'
    jg studw_error          ; возвращаем ошибку
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
str_to_udec_word endp
	
CSEG ENDS



END MAIN


