STSEG  SEGMENT  PARA  STACK  "STACK"
    DB 64 DUP ( '?' )
STSEG  ENDS

DSEG segment para public "data"
    num_str db 7,?, 7 dup('?')
    num dw ?
    error_msg db 13,10,'Error occurs! Check input data!$'
    enter_request db 13,10,'Please enter the number(5 sumbols max)$',13,10
DSEG ENDS

CSEG  SEGMENT PARA PUBLIC  "CODE"

    MAIN  PROC  FAR
        ASSUME  CS: CSEG, DS: DSEG, SS: STSEG
        
        push dx
        xor ax,ax
        push ax
        mov ax,dseg
        mov ds,ax
        
        mov ah,9               
        mov dx,offset enter_request  
        int 21h
        
        mov ah,10
        lea dx, num_str         
        int 21h                
        mov al,[num_str+1]      
        add dx,2                 
        
        test al,al              
        jz error                
        
        mov si,dx               
        mov bl,[si]
        cmp bl,'-'
        jne no_sign_conv
        inc si
        inc dx
        dec al
        
        
    no_sign_conv:
        push bx                 
        mov di,10               
        mov cx,ax               
        xor ch,ch
        xor ax,ax               
        xor bx,bx            
     
    no_sign_loop:
        mov bl,[si]             
        inc si                  
        cmp bl,'0'              
        jl error                
        cmp bl,'9'              
        jg error                
        sub bl,'0'             
        mul di                  ;AX = AX * 10
        jc error               
        add ax,bx               
        jc error                
        loop no_sign_loop      
        
        pop bx
        cmp bx,'-'
        jne stsdw_plus          
        cmp ax,32768            
        ja error               
        neg ax                 
        jmp finall_of_conv     
    stsdw_plus:
        cmp ax,32767            
        ja error 
       
    finall_of_conv: 
        mov num,ax               
       
       mov  bx, num
       mov  al, 13     
       int  29h
       mov  al, 10     
       int  29h
       or   bx, bx     
       jns  m1     
       mov  al, '-'     
       int  29h     
       neg  bx   
    m1:     
       mov  ax, bx
       xor  cx, cx
       mov  bx, 10
    m2:     
       xor  dx, dx
       div  bx
       add  dl, '0'
       push dx
       inc  cx
       test ax, ax
       jnz  m2
    m3:     
       pop ax
       int 29h
       loop m3  
       
       mov ah,8                
       int 21h
       
       ret
        
    error:
        mov dx,offset error_msg 
        mov ah,9                
        int 21h
        mov ah,8                
        int 21h
        ret
        
     
     MAIN ENDP

CSEG ENDS

END MAIN   
    