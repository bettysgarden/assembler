; 19. Дано предложение. Определить, сколько слов максимальной длины

.model tiny ; модель памяти, используемая для Com     
org 100h
.data
    mess_input_str db "Введите строку: $"
    mess_input_sym db "Введите символ для поиска:$"   
    mess_str db "Введенная строка>>$"
    result db "Количество слов максимальной длины: $" 
    
    buffer  db 255, ?, 255 dup (?) 
    space   db ' '
    end     db '$' 
    crlf	db	0dh,0ah,'$' 
    
    count   db 0 
    
.code ; начало сегмента кода

start:    
    xor cx,cx   
    xor di,di   
    
    call ReadString    ; cl -длина строки, dx - строка          
    call Enter  

; вызов процедуры с сохранением параметров
    lea di, buffer; передаем строку чз стек
    push di   
                      
    cld
    call count_max_length_words       
    int 20h    

count_max_length_words proc
    
    push bp        ;сохраняем регистры       
    mov bp,sp  
                            
	push	AX		; сохраняем регистры
	push	CX		
	push	BX		
	push	DX		
	push	SI		
	push	DI   

	xor cx,cx
	xor di,di
	xor ax,ax	
	
	mov di, [bp+4] 	 ; буффер	
	mov cx, [di + 1] ; длина строки 
	lea si, [di + 2] ; первый символ в буффере  
 
    
	inc di   ;адрес указывает на символ
	inc di   ;   
    mov bx,cx 
    
    mov dx,0  ; сохраним максимум
    push dx 
       
    mov al, [di]    ; читаем первый символ
    dec cx          ; уменьшаем длину строки
    inc di
    
    cmp al, end    
    je exit 
    cmp al, space       
    je skip_spaces_di  ; пропускаем пробелы      
    jmp skip_tail_di 
                  
 
find:
    inc count 
    push dx 
    cmp al,end      
    je exit 
    jmp skip_spaces_di

skip_tail_di: 
    ;идет по di до первого равного пробелу знака
    mov al, space
    REPNZ scasb   ; REPNZ — повторять операцию, 
                  ;пока флаг ZF показывает «не равно или не ноль».
    inc cx
    dec di
    sub bx,cx   ;вычитаем из текущего адреса, который хранится в EDI, адрес начала строки(хранится в ESI ),
                ;таким образом находим длину строки вместе с терминальным символом              
    pop dx
    cmp dx,bx   ; нашли слово такой же длины как макс
    je find
    cmp bx,dx   ; если макс < тек длины 
    jl skip_spaces_di
    ; иначе
    mov count,1
    push bx
                              

skip_spaces_di:   
    mov al, space
    REPZ scasb   ;идет по di до первого отличного от пробела знака 
    dec di 
    inc cx
    mov bx,cx
    cmp cl,0      
    je exit   
    jmp skip_tail_di       

exit:   
mov ah,09h
	lea dx,mess_str
	int 21h 
	call Enter 
mov ah,09h
	lea dx,buffer + 2
	int 21h     
	call Enter 
mov ah,09h
	lea dx,Result
	int 21h
	call Enter 
	xor ax,ax 
	mov al, count
	call WriteInteger
   
	call Enter 
              
	POP	DI		;   восстанавливаем регистры
	POP	SI		; 
	POP	DX		;
	POP	BX		;
	POP	CX		;
	POP	AX		; 
	pop bp
	mov ah, 4ch ; выход
    int 21h    
    
count_max_length_words endp
            
             

ReadString proc
    mov ah, 9h ; приглашение пользователю о вводе строки
    lea dx, mess_input_str
    int 21h
    
    mov ah,0Ah  ; ввод строки
    lea dx,buffer
    int 21h     
 
    xor bx,bx     
    mov bl,[buffer+1]   ; длина введенной строки - в BL 
    mov [buffer+bx+2],'$' ; вставляем последним символом

    mov dl,0ah
    mov ah,2
    int 21h ; курсор - на следующую строку  
    ret   

ReadString endp 

Enter proc
    mov ah,09h
    lea dx,crlf
    int 21h    
    ret
Enter endp   

WriteInteger  PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        XOR  CX, CX
        MOV  BX, 10
        CMP  AX, 0 ;
        JGE  PushDigitNumChar
        
    WriteMinus:
        PUSH AX
        MOV  DL, '-'
        MOV  AH, 2
        INT  21h
        POP  AX
        NEG  AX
        
    PushDigitNumChar:
        XOR  DX, DX
        IDIV BX ; ax = ax div bx
        PUSH DX ; dx = ax mod bx 
        INC  CX
        CMP  AX, 0
        JG   PushDigitNumChar
        
    PopDigitNumInt:
        POP AX
        ADD AL, '0'
        CALL WriteChar
        LOOP PopDigitNumInt
        
        POP DX
        POP CX
        POP BX
        POP AX
        RET
WriteInteger  ENDP   

WriteInteger1 proc  
    	push    	ax  
    	push    	cx  
    	push    	bx  
    	push    	dx  
    	xor     	cx, cx  
    	mov     	bx, 10  
	; число отрицательное?    
    	cmp     	ax,0
    	jl      	negative	; если - да
    	jmp     	positive	; если - нет
	; вывести минус и поменять знак
negative:
    	push    	ax
    	mov     	dl, '-'  
    	mov     	ah, 2  
    	int         21h
    	pop     	ax
    	neg     	ax  

	; получить 10-цифры и поместить их в стек,
	; в cx - количество полученных цифр
positive:  
    	xor     	dx, dx  
    	idiv    	bx  
    	push    	dx  
    	inc     	cx  
    	cmp     	ax,0     
    	jg     	positive  

	; достать из стека, перевести в код ASSII  и вывести  
popl: 
    	pop     	ax  
    	add     	al, '0'  
    	call    	WriteChar   
    	
    	loop    	popl  

    	pop     	dx
   	    pop     	bx  
    	pop     	cx  
   	    pop     	ax 
    	ret  
WriteInteger1 endp  


WriteChar PROC
        PUSH AX
        PUSH DX
        
        MOV  DL, AL
        MOV  AH, 2
        INT  21h
        
        POP  DX
        POP  AX
        RET
WriteChar ENDP    

    
   