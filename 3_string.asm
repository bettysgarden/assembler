; 19. ���� �����������. ����������, ������� ���� ������������ �����

.model tiny ; ������ ������, ������������ ��� Com     
org 100h
.data
    mess_input_str db "������� ������: $"
    mess_input_sym db "������� ������ ��� ������:$"   
    mess_str db "��������� ������>>$"
    result db "���������� ���� ������������ �����: $" 
    
    buffer  db 255, ?, 255 dup (?) 
    space   db ' '
    end     db '$' 
    crlf	db	0dh,0ah,'$' 
    
    count   db 0 
    
.code ; ������ �������� ����

start:    
    xor cx,cx   
    xor di,di   
    
    call ReadString    ; cl -����� ������, dx - ������          
    call Enter  

; ����� ��������� � ����������� ����������
    lea di, buffer; �������� ������ �� ����
    push di   
                      
    cld
    call count_max_length_words       
    int 20h    

count_max_length_words proc
    
    push bp        ;��������� ��������       
    mov bp,sp  
                            
	push	AX		; ��������� ��������
	push	CX		
	push	BX		
	push	DX		
	push	SI		
	push	DI   

	xor cx,cx
	xor di,di
	xor ax,ax	
	
	mov di, [bp+4] 	 ; ������	
	mov cx, [di + 1] ; ����� ������ 
	lea si, [di + 2] ; ������ ������ � �������  
 
    
	inc di   ;����� ��������� �� ������
	inc di   ;   
    mov bx,cx 
    
    mov dx,0  ; �������� ��������
    push dx 
       
    mov al, [di]    ; ������ ������ ������
    dec cx          ; ��������� ����� ������
    inc di
    
    cmp al, end    
    je exit 
    cmp al, space       
    je skip_spaces_di  ; ���������� �������      
    jmp skip_tail_di 
                  
 
find:
    inc count 
    push dx 
    cmp al,end      
    je exit 
    jmp skip_spaces_di

skip_tail_di: 
    ;���� �� di �� ������� ������� ������� �����
    mov al, space
    REPNZ scasb   ; REPNZ � ��������� ��������, 
                  ;���� ���� ZF ���������� ��� ����� ��� �� �����.
    inc cx
    dec di
    sub bx,cx   ;�������� �� �������� ������, ������� �������� � EDI, ����� ������ ������(�������� � ESI ),
                ;����� ������� ������� ����� ������ ������ � ������������ ��������              
    pop dx
    cmp dx,bx   ; ����� ����� ����� �� ����� ��� ����
    je find
    cmp bx,dx   ; ���� ���� < ��� ����� 
    jl skip_spaces_di
    ; �����
    mov count,1
    push bx
                              

skip_spaces_di:   
    mov al, space
    REPZ scasb   ;���� �� di �� ������� ��������� �� ������� ����� 
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
              
	POP	DI		;   ��������������� ��������
	POP	SI		; 
	POP	DX		;
	POP	BX		;
	POP	CX		;
	POP	AX		; 
	pop bp
	mov ah, 4ch ; �����
    int 21h    
    
count_max_length_words endp
            
             

ReadString proc
    mov ah, 9h ; ����������� ������������ � ����� ������
    lea dx, mess_input_str
    int 21h
    
    mov ah,0Ah  ; ���� ������
    lea dx,buffer
    int 21h     
 
    xor bx,bx     
    mov bl,[buffer+1]   ; ����� ��������� ������ - � BL 
    mov [buffer+bx+2],'$' ; ��������� ��������� ��������

    mov dl,0ah
    mov ah,2
    int 21h ; ������ - �� ��������� ������  
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
	; ����� �������������?    
    	cmp     	ax,0
    	jl      	negative	; ���� - ��
    	jmp     	positive	; ���� - ���
	; ������� ����� � �������� ����
negative:
    	push    	ax
    	mov     	dl, '-'  
    	mov     	ah, 2  
    	int         21h
    	pop     	ax
    	neg     	ax  

	; �������� 10-����� � ��������� �� � ����,
	; � cx - ���������� ���������� ����
positive:  
    	xor     	dx, dx  
    	idiv    	bx  
    	push    	dx  
    	inc     	cx  
    	cmp     	ax,0     
    	jg     	positive  

	; ������� �� �����, ��������� � ��� ASSII  � �������  
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

    
   