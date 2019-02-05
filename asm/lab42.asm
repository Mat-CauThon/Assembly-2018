
STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS



DSEG SEGMENT PARA PUBLIC "DATA"

my_array dw 2000 dup (?)
index_mes db 10,13,'Index x and y $'
search_el_mes db 10,13, 'Write your search element$'
minus_max_el_mes db 10,13,'Oops, you input wrong max elements of array (<0)$'
write_max_elements_stroka db 10,13,'Write max stroka element of array -> $'
write_max_elements_stolb db 10,13,'Write max stolb element of array -> $'
write_array DB 10,13,'Write your elements of array $'
error_test DB 10,13,'Wrong input data, try again $'
new_stroka db 10,13, 'New stroka in Array $'
new_string db 10,13, ' -> $'
enter_string db 10,13,'$'
max_stroka dw ?
max_stolb dw ?
max_el dw ?
two dw ?
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
	
	
	lea dx, write_max_elements_stroka
	mov ah,9
	int 21h
	

begin:
	call input_symbol
	call number_convert
	jc begin
	
	cmp ax,0
	jl run_away1
	
	;add ax,ax
	mov max_stroka[0],ax

	lea dx, write_max_elements_stolb
	mov ah,9
	int 21h
	
begin2:
	call input_symbol
	call number_convert
	jc begin2
	
	cmp ax,0
	jl run_away1
	
	;add ax,ax
	mov max_stolb[0],ax

	
	lea dx, write_array
	mov ah,9
	int 21h
	
	
	xor si,si
	xor cx,cx
	
	mov ax,max_stolb[0]
	mul max_stroka[0]
	mov cx,ax
	;add ax,ax
	mov max_el,ax
	;xor ax,ax
	;add cx,max_stolb
	;add cx,max_stroka
	
	push cx
	xor di,di
	mov bx,max_stroka
	add bx,bx
input_array:

	
	;mov di,2
	;div di
	;sub ax,2
	;div max_stroka[0]
	;mov ax,max_stroka[0]
	;call write
	
	
	cmp di,bx
	jne skip
	add bx,max_stroka
	add bx,max_stroka
	lea dx, new_stroka
	mov ah,9
	int 21h
	skip:
	
	
	xor ax,ax
	lea dx, new_string
	mov ah,9
	int 21h
	
	
	call input_symbol
	call number_convert
	jc input_array
	
	;xor ah,ah
	
	lea dx, my_array
	
	mov my_array[si], ax
	add si, 2
	
	add di, 2
	
	
	
loop input_array
	pop cx
	
	
	jmp runskip
	run_away1:
	
	lea dx, minus_max_el_mes
	mov ah,9
	int 21h
	jmp run_away
	
	
	runskip:
	
	
	
	lea dx, search_el_mes
	mov ah,9
	int 21h
	
	lea dx, enter_string
	mov ah,9
	int 21h
	
	
	call input_symbol
	call number_convert
	
	mov bx,ax
	lea dx, index_mes
	mov ah,9
	int 21h
	
	;mov ax,max_el
	;call write
	
	lea dx, enter_string
	mov ah,9
	int 21h
	
	mov ax,bx
	
	
	xor si,si
	xor di,di
	;xor bx,bx
search_index:	
	cmp bx,my_array[si]
	jne search_skip
	
	
	xor dx,dx
	xor ax,ax
	
	mov ax,si
	mov di,2
	cwd
	div di
	
	mov di, max_stroka
	cwd
	div di
	call write
	
	push dx
	xor ax,ax
	mov ah,' '
	int 29h
	
	
	pop dx
	mov ax,dx
	
	
	
	call write
	
	
	lea dx, enter_string
	mov ah,9
	int 21h
	
	search_skip:
	add si,2


loop search_index
	
	run_away:
ret
MAIN ENDP
	
		
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
	push si
	push di
	
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

	pop si
	pop di
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
	
		
		
		lea dx,error_test		;;
		mov ah,9				;;   вывод сообщения
		int 21h					;;
		;mov ax,si
		
		
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