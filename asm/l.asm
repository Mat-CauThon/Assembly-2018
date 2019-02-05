STSEG SEGMENT PARA STACK "STACK"
STSEG ENDS


DSEG SEGMENT PARA PUBLIC "DATA"

VERY_IMPORTANT_VAR DB 98, 121, 32, 115, 118, 105, 110, 33
USER_NUM DB 7, ?, 5 DUP(?)  ; 5 СИМВОЛОВ ДЛЯ ВВОДА (ЧТО БЫ ВЛЕЗТЬ В 2 БАЙТА)
PROMPT DB 'ENTER NUM -> $'  ; СООБЩЕНИЕ ДЛЯ ВВОДА
ERROR_MSG DB 'ERROR',10,'$' ; СООБЩЕНИЕ О ОШИБКЕ С ПЕРЕВОДОМ СТРОКИ
DIGIT DW 0                  ; ТУТ ХРАНИМ ЧИСЛО

DSEG ENDS


CSEG SEGMENT PARA PUBLIC "CODE"

MAIN PROC FAR

  ASSUME CS: CSEG, DS: DSEG, SS: STSEG
  ; СТАРТОВЫЕ ПРИГОТОВЛЕНИЯ
  PUSH DS
  XOR AX, AX
  PUSH AX

  MOV AX, DSEG
  MOV DS, AX
 
 
  JMP START ; ПРЫГАЕМ НА СТАРТ А СНИЗУ ОБЬЯВИМ "ФУНКЦИИ"
 
PRINT_ERROR: ; ВЫВОД ОШИБКИ
  LEA DX, ERROR_MSG
  MOV AH, 9
  INT 21H
  ;INT 4CH
 

START:
  MOV DIGIT, 0
 
  ; ПРОСЬБА ВВЕСТИ ЧИСЛО

  LEA DX, PROMPT
  MOV AH, 9
  INT 21H

  ; ВВОД

  LEA DX, USER_NUM
  MOV AH, 10
  INT 21H  

  ; ПЕРЕВОД СТРОКИ
  MOV AL, 10
  INT 29H

  

; ПЕРЕТВОРЕННЯ НА ЧИСЛО
; DX = СВОЙ ФЛАГ ОТРИЦАТЕЛЬНОГО ЧИСЛА
; DI = СЧЕТЧИК (ИНДЕКС) СТРОКИ
; CX = СЧЕТЧИК ДЛЯ СТЕПЕНИ

  MOV DI, 0 ; DI = ИНДЕКС СИМВОЛА В МАССИВЕ
  
N1:
  XOR AX, AX
  MOV BX, OFFSET USER_NUM ; BX = *USER_NUM
  ;LEA BX, USER_NUM
  MOV AL, [BX+DI+2] ; AL = USER_NUM[I] Т.Е. ТЕКУЩИЙ СИМВОЛ
  
  ; ПРОВЕРКИ
  
  ; ЕСЛИ ЧИСЛО ПЕРЕЙТИ НА IS_NUM, ИНАЧЕ ПРОДОЛЖИТЬ
  CMP AL, ':'    ; ':' = '9'+1
  JNB NOT_NUM     ; JUMP NOT_NUM IF AL > '9'
  CMP AL, '0'    
  JB NOT_NUM     ; JUMP NOT_NUM IF AL < '0'
  JMP IS_NUM      ; ELSE JUMP IS_NUM
 
NOT_NUM:

  ; ЕСЛИ НЕ ЧИСЛО И НЕ ЗНАК МИНУСА ТО ОШИБКА
  CMP AX, '-'    
  JNZ PRINT_ERROR   ; ERROR IF NOT '-'
  
  ; ЕСЛИ ЗНАК МИНУСА НО НЕ ПЕРВЫМ ТО ОШИБКА
  OR DI, DI
  JNZ PRINT_ERROR   ; ERROR IF NOT FIRST
  
  ; ЕСЛИ НЕТУ ОШИБОК ТО СТАВИМ ФЛАГ МИНУСА И ОБРАБАТЫВАЕМ СРАЗУ СЛЕДУЮЩИЙ СИМВОЛ
 ; MOV DX, 1  ; SET MINUS FLAG
  POP AX
  PUSH 1
  
  INC DI
  JMP N1 ; NEXT SYMB
  
IS_NUM:  
  SUB AX, '0' ; ATOI, AX ТЕПЕРЬ ЧИСЛО
  
  ; 10 ^ N <=> BL ^ (LEN - I - 1)
  XOR CX, CX
  MOV CL, [BX+1] ; CX = N, FROM LEN-1 TO 0
  INC DI ; I++
  SUB CX, DI
  XOR BX, BX
  MOV BX, 10 ; BL = 10

  
  JCXZ SKIP_POW ; ЕСЛИ ПОКАЗАТЕЛЬ СТЕПЕНИ 0 ТО НЕ УМНОЖАЕМ
POW:          
  MUL BX        ; ИНАЧЕ УМНОЖАЕМ НУЖНОЕ КОЛ-ВО РАЗ
  JO PRINT_ERROR    ; ERROR IF OVERFLOW
  LOOP POW
SKIP_POW:
  
  
  ADD DIGIT, AX ; ПРИБАВЛЯЕМ ПОЛУЧЕННОЕ ЧИСЛО В ЕГО ЗАКОННОЕ МЕСТО В ОПЕРАТИВКЕ
  JO PRINT_ERROR    ; ERROR IF OVERFLOW
  
  ; ЕСЛИ ЕЩЕ ЕСТЬ СИМВОЛЫ ОБРАБОТАТЬ ИХ
  MOV BX, OFFSET USER_NUM
  MOV AL, [BX+1]; AL = LEN USER_NUM
  CMP AX, DI ; IF I != LEN => JUMP N1
  JNZ N1
  
  ; ЕСЛИ СИМВОЛОВ БОЛЬШЕ НЕТУ
  ; ДЕЛАЕМ ЧИСЛО ОТРИЦАТЕЛЬНЫМ, ЕСЛИ НУЖНО
  CMP DX, 1
  JNZ PRINTING ; ЕСЛИ НЕ НУЖНО ПРОПУСКАЕМ
  NEG DIGIT
  
  
   
PRINTING:   ; ВЫВОД
  
  MOV BX, DIGIT   ; НАШЕ ЧИСЛО ТЕПЕРЬ В BX
  ; ПРОВЕРЯЕМ МИНУС, ПРИНТИМ ЕСЛИ НУЖНО
  OR BX, BX
  JNS M1 ; JUMP IF SF == 0 (IF POSITIVE)
  MOV AL, '-' ; ELSE PRINT SYMBOL '-'
  INT 29H 
  NEG BX ; AND MADE POSITIVE
  
M1:
  MOV AX, BX 
  XOR CX, CX
  MOV BX, 10 ; DIVIDER = 10
M2:
  ; ДЕЛАЕМ ИЗ ОСТАЧИ СИМВОЛ И ПУШИМ В СТЕК
  XOR DX, DX
  DIV BX ; AX = AX // BX;  DX = AX % BX    BX = 10
  ADD DL, '0' ; ITOA DX
  PUSH DX
  INC CX  ; CX++
  TEST AX, AX
  JNZ M2 ; IF NOT 0 JUMP M2
M3:
  ; ПРИНТИМ СТЕК
  POP AX; PRINT AX
  INT 29H
  LOOP M3; CX--; JUMP M3

  RET



MAIN ENDP

CSEG ENDS
END MAIN