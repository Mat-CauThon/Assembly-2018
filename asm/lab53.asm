input MACRO
;push cx
;push si
 
 
 
 ;mov al,7
   ; mov cx,ax               ;Сохранение AX в CX
    mov ah,0Ah              ;Функция DOS 0Ah - ввод строки в буфер
  
    lea dx,userNumber           ;DX = aдрес буфера
    int 21h                 ;Обращение к функции DOS
    mov al,[userNumber+1]       ;AL = длина введённой строки
    add dx,2                ;DX = адрес строки
    ;mov ah,ch               ;Восстановление AH
	
	
;pop si
;pop cx
ENDM

write_local MACRO number
LOCAL m1
LOCAL m2
LOCAL m3
mov di, cx
	mov bx,number
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
mov cx,di
ENDM


write_mes MACRO what_write

	lea dx, what_write
	mov ah,9
	int 21h

ENDM




convert MACRO
LOCAL stsdw_no_sign
LOCAL stsdw_plus
LOCAL stsdw_ok
LOCAL okey
LOCAL preerror
	test al,al    ;Проверка длины строки
    jz preerror	            ;Если равно 0, возвращаем ошибку
    mov bx, offset dx      	;BX = адрес строки
    mov bl,[bx]             ;BL = первый символ строки
    cmp bl,'-'              ;Сравнение первого символа с '-'
    jne stsdw_no_sign       ;Если не равно, то преобразуем как число без знака
    inc dx                  ;Инкремент адреса строки
    dec al                  ;Декремент длины строки
    stsdw_no_sign:
    call number_module   ;Преобразуем строку в слово без знака
	jc preerror
    cmp bl,'-'              ;Снова проверяем знак
    jne stsdw_plus          ;Если первый символ не '-', то число положительное
    cmp ax,32768            ;Модуль отрицательного числа должен быть не больше 32768
    ja preerror		        ;Если больше (без знака), возвращаем ошибку
    neg ax                  ;Инвертируем число
    jmp stsdw_ok            ;Переход к нормальному завершению процедуры
    stsdw_plus:
    cmp ax,32767            ;Положительное число должно быть не больше 32767
    ja preerror      		    ;Если больше (без знака), возвращаем ошибку
    stsdw_ok:
    clc                     ;CF = 0
	jmp okey
	
	preerror:
	
		
		
		;lea dx,error_test		;;
		;mov ah,9				;;   вывод сообщения
		;int 21h					;;
		;mov ax,si
		write_mes error_test
		
	okey:
	
	

ENDM


STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS



DSEG SEGMENT PARA PUBLIC "DATA"

my_array dw 20000 dup (?)
max_mes db 10,13, 'Max element = $'
min_mes db 10,13, 'Min element = $'
sorted_mes db 10,13,'Your sorted array -> $'
summa_mes db 10,13,'Summa of your array = $'
minus_max_el_mes db 10,13,'Oops, you input wrong max elements of array ( <0 ) $'
error_size_mes db 10,13,'Oops, summa of elements is too big$'
write_max_elements db 10,13,'Write max elements of array -> $'
write_array DB 10,13,'Write your elements of array $'
error_test DB 10,13,'Wrong input data, try again $'
new_string db 10,13, ' -> $'
enter_string db 10,13,'$'

userNumber DB 7,?,5 dup('?')




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
	
	
	;lea dx, write_max_elements
	;mov ah,9
	;int 21h
	write_mes write_max_elements
	

begin:
	;call input_symbol
	input
	call number_convert
	jc begin
	
	cmp ax,0
	jl run_away1
	
	mov cx,ax
	
	;lea dx, write_array
	;mov ah,9
	;int 21h
	write_mes write_array
	
	xor si,si
	;mov si,0h
	
	mov bx,cx

input_array:
	xor ax,ax
	;lea dx, new_string
	;mov ah,9
	;int 21h
	write_mes new_string
	
	;call input_symbol
	input
	call number_convert
	
	jc input_array
	
	;xor ah,ah
	
	lea dx, my_array
	
	mov my_array[si], ax
	add si, 2
	
loop input_array
	mov cx,bx
	
	jmp runskip
	run_away1:
	

	write_mes minus_max_el_mes
	
	jmp run_away
	
	runskip:
	

	write_mes enter_string
	
	xor si,si
	;xor ah,ah
	;inc si
	
	
call summa_array
jo run_away_summa
mov bx,ax


	write_mes summa_mes
mov ax,bx
call write
	
	write_mes enter_string
run_away_summa:	
	
call sort_array

	;lea dx, sorted_mes
	;mov ah,9
	;int 21h
	write_mes sorted_mes
	
	
	mov bx,cx
go_away_array:
	;mov ax, '0'
	;mov bl, offset my_array
	xor ah,ah
	mov ax, my_array[si]
	call write
	;write_number
	add si, 2
	mov al, ' '
	int 29h
	loop go_away_array
	mov cx,bx
	
	
	;lea dx, min_mes
	;mov ah,9
	;int 21h	
	write_mes min_mes
	
	mov ax,my_array[0]

	write_local ax
	
	;call write
	;write_number
	;lea dx, max_mes
	;mov ah,9
	;int 21h	
	write_mes max_mes
	
	mov si,cx
	add si,si
	sub si,2
	mov ax,my_array[si]
	;call write
   	write_local ax
	;write_number

   


	run_away:
RET
MAIN ENDP
	
sort_array proc
	push cx                 ;Сохранение всех используемых регистров
    push dx
    push bx
    push si
    push di

	xor si,si
	add cx,cx
	
	sort:
	add si, 2
	mov di,my_array[si]
	sub si, 2
	cmp my_array[si], di
	jle continue
	mov bx,my_array[si]
	mov my_array[si],di
	mov my_array[si+2],bx
	
	cmp si,0
	je continue
	sub si,4
	
	continue:
	add si,2

	mov bx,si
	add bx,2
	cmp bx,cx
	jl sort
	
	
	
	skip:
	pop di                  ;Восстановление регистров
    pop si
    pop bx
    pop dx
    pop cx
ret
sort_array endp
	
	
	
summa_array proc
	push cx                 ;Сохранение всех используемых регистров
    push dx
    push bx
    push si
    push di
	
	xor ax,ax
	xor si,si
metka_loop:
	
	
	add ax,my_array[si]
	jo error_size
	add si,2
	loop metka_loop
	
	jmp norm
	error_size:
		;lea dx,error_size_mes	;;
		;mov ah,9				;;   вывод сообщения
		;int 21h					;;
		write_mes error_size_mes
	norm:
	pop di                  ;Восстановление регистров
    pop si
    pop bx
    pop dx
    pop cx
    ret
summa_array endp	
	
	
	
input_symbol proc

push cx
push si
	mov al,7
    mov cx,ax               ;Сохранение AX в CX
    mov ah,0Ah              ;Функция DOS 0Ah - ввод строки в буфер
  
    lea dx,userNumber           ;DX = aдрес буфера
    int 21h                 ;Обращение к функции DOS
    mov al,[userNumber+1]       ;AL = длина введённой строки
    add dx,2                ;DX = адрес строки
    mov ah,ch               ;Восстановление AH
pop si
pop cx

ret
input_symbol endp

write PROC

	push dx
	push ax
	push bx
	push cx
	
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

	pop cx
	pop bx
	pop ax
	pop dx
	ret
write ENDP
	
	
	
number_convert proc

	;push ax
	push bx
	push dx
	push cx
	push si
	
    test al,al              ;Проверка длины строки
    jz preerror	            ;Если равно 0, возвращаем ошибку
	
	mov si,ax
	
    mov bx, offset dx      	;BX = адрес строки
    mov bl,[bx]             ;BL = первый символ строки
    cmp bl,'-'              ;Сравнение первого символа с '-'
    jne stsdw_no_sign       ;Если не равно, то преобразуем как число без знака
    inc dx                  ;Инкремент адреса строки
    dec al                  ;Декремент длины строки
stsdw_no_sign:
    call number_module  	 ;Преобразуем строку в слово без знака
	jc preerror
    cmp bl,'-'              ;Снова проверяем знак
    jne stsdw_plus          ;Если первый символ не '-', то число положительное
    cmp ax,32768           ;Модуль отрицательного числа должен быть не больше 32768
    ja preerror		        ;Если больше (без знака), возвращаем ошибку
    neg ax                  ;Инвертируем число
    jmp stsdw_ok            ;Переход к нормальному завершению процедуры
stsdw_plus:
    cmp ax,32767           ;Положительное число должно быть не больше 32767
    ja preerror 		    ;Если больше (без знака), возвращаем ошибку
stsdw_ok:
    clc   	;CF = 0
	jmp okey
	
	preerror:
	
		
		
		;lea dx,error_test		;;
		;mov ah,9				;;   вывод сообщения
		;int 21h					;;
		;mov ax,si
		write_mes error_test
		
	okey:

	pop si
	pop cx
	pop dx
	pop bx
	
	ret
number_convert endp	
	
	
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