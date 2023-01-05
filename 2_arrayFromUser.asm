.model tiny

.data
    array                     DW 100 dup(0)     
    array_length              DW 0
    array_max_length          DW 100
    
    string_newline            DB 13, 10, '$'
    string_input_array_length DB 'Input array length', 13, 10, '$'
    string_big_array_length   DB 'Array length over 100', 13, 10, '$'
    string_input_array_elems  DB 'Input array elements', 13, 10, '$'
    string_your_array         DB 'Your array', 13, 10, '$'
    
    check_result              DW 0
    Msg_yes                   DB 'All negative values go before positive', 13, 10, '$'
    Msg_no                    DB 'Negative values are not before positive', 13, 10, '$'
    Msg_all_negative          DB 'There are no negative numbers in the array', 13, 10, '$'

.code
start:
    LEA  BX, string_newline   ; MOV ????, offset ????????
    PUSH BX
    LEA  BX, string_input_array_length
    PUSH BX
    LEA  BX, string_big_array_length
    PUSH BX
    MOV  BX, array_max_length
    PUSH BX
    LEA  BX, array_length
    PUSH BX
    
    CALL read_array_length
    
    POP  BX
    POP  BX
    POP  BX
    POP  BX
    POP  BX
    
    
    LEA  BX, string_newline
    PUSH BX
    LEA  BX, string_input_array_elems
    PUSH BX
    MOV  BX, array_length
    PUSH BX
    LEA  BX, array
    PUSH BX
    
    CALL read_array
    
    POP  BX
    POP  BX
    POP  BX
    POP  BX
    
    
    LEA  BX, string_newline
    PUSH BX
    LEA  BX, string_your_array
    PUSH BX
    MOV  BX, array_length
    PUSH BX
    LEA  BX, array
    PUSH BX
    
    CALL write_array
    
    POP  BX
    POP  BX
    POP  BX
    POP  BX
    
    
    LEA  BX, check_result
    PUSH BX
    MOV  BX, array_length
    PUSH BX
    LEA  BX, array
    PUSH BX
    
    CALL check_neg_before_positive
    
    POP  BX
    POP  BX
    POP  BX
    
    
    LEA  BX, Msg_yes
    PUSH BX
    LEA  BX, Msg_no
    PUSH BX
    LEA  BX, Msg_all_negative
    PUSH BX
    MOV  BX, check_result
    PUSH BX
    
    CALL result
    
    POP  BX
    POP  BX
    POP  BX
    POP  BX
    
    
    MOV  AX, 4c00h
    INT  21h

result PROC
        PUSH BP
        MOV  BP, SP
        PUSH AX
        PUSH DX
        
        MOV  AH, 9
        CMP  [BP + 4], 0      ; check_result
        JE   result_all_negative_elems
        CMP  [BP + 4], 1      ; check_result
        JE   result_sorted
        MOV  DX, [BP + 8]     ; Msg_no "Negative values are not before positive$"
        JMP  print
        
    result_all_negative_elems: 
        MOV  DX, [BP + 6]     ; Msg_all_negative "There are all negative numbers in the array$"
        JMP  print
        
    result_sorted:
        MOV  DX, [BP + 10]    ; Msg_yes 'All negative values go before positive$'
        
    print:
        INT  21h
        
        POP  DX
        POP  AX
        POP  BP
        RET
result ENDP

check_neg_before_positive PROC
        PUSH BP
        MOV  BP, SP
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DI
        
        MOV  DI, [BP + 4]     ; array
        MOV  CX, [BP + 6]     ; array_length
        MOV  BX, 1
        XOR  AX, AX   
   
    check_neg_before_pos:
        CMP  [DI], 0 ; if pos
        jg Check_if_all_positive
        MOV  AX, 1
        ADD  DI, 2
        LOOP check_neg_before_pos
        jmp check_result_neg_before_pos  ; alright  
            
    Check_if_all_positive:
        ADD  DI, 2
        CMP  [DI], 0
        jl sort_ruined
        loop Check_if_all_positive
        JMP  check_result_neg_before_pos ; alright  

    sort_ruined:
        mov ax, 2
            
    check_result_neg_before_pos:
        MOV  DI, [BP + 8]     ; check_result
        MOV  [DI], AX
        
        POP  DI
        POP  CX
        POP  BX
        POP  AX
        POP  BP
        RET        
check_neg_before_positive ENDP    


write_array PROC
        PUSH BP
        MOV  BP, SP
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DI
        
        MOV  AH, 9
        MOV  DX, [BP + 8]     ; string_your_array
        INT  21h
        
        MOV  CX, [BP + 6]     ; array_length
        MOV  DI, [BP + 4]     ; array
        
    write_array_element:
        MOV  AX, [DI]
        CALL write_int
        ADD  DI, 2
        MOV  AH, 9
        MOV  DX, [BP + 10]     ; string_newline
        INT  21h
        LOOP write_array_element
        
        POP  DI
        POP  DX
        POP  CX
        POP  AX
        POP  BP
        RET
write_array ENDP

write_int PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        XOR  CX, CX
        MOV  BX, 10
        CMP  AX, 0
        JGE  write_int_separate_nums
        
    write_int_minus:
        PUSH AX
        MOV  DL, '-'
        MOV  AH, 2
        INT  21h
        POP  AX
        NEG  AX
        
    write_int_separate_nums:
        XOR  DX, DX
        IDIV BX
        PUSH DX
        INC  CX
        CMP  AX, 0
        JG   write_int_separate_nums
        
    write_int_digit:
        POP AX
        ADD AL, '0'
        CALL write_char
        LOOP write_int_digit
        
        POP DX
        POP CX
        POP BX
        POP AX
        RET
write_int ENDP

write_char PROC
        PUSH AX
        PUSH DX
        
        MOV  DL, AL
        MOV  AH, 2
        INT  21h
        
        POP  DX
        POP  AX
        RET
write_char ENDP

read_array PROC
        PUSH BP
        MOV  BP, SP
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DI
        
        MOV  AH, 9
        MOV  DX, [BP + 8]     ; string_input_array_elems
        INT  21h
        
        MOV  CX, [BP + 6]     ; array_length
        MOV  DI, [BP + 4]     ; array
        
    read_array_element:
        CALL read_int
        MOV  [DI], AX
        ADD  DI, 2
        MOV  AH, 9
        MOV  DX, [BP + 10]     ; string_newline
        INT  21h
        LOOP read_array_element
        
        POP  DI
        POP  DX
        POP  CX
        POP  AX
        POP  BP
        RET
read_array ENDP

read_array_length PROC
        PUSH BP
        MOV  BP, SP
        PUSH AX
        PUSH DX
        PUSH DI
        
        MOV  AH, 9
        MOV  DX, [BP + 10]     ; string_input_array_length
        INT  21h
        
    read_al_try:
        CALL read_int
        CMP  AX, [BP + 6]     ; array_max_length
        JLE  read_al_done
        
    read_al_fail:
        MOV  AH, 9
        MOV  DX, [BP + 12]    ; string_newline
        INT  21h
        MOV  DX, [BP + 8]     ; string_big_array_length
        INT  21h
        JMP  read_al_try
        
    read_al_done:
        MOV  DI, [BP + 4]     ; array_length
        MOV  [DI], AX
        MOV  AH, 9
        MOV  DX, [BP + 12]    ; string_newline
        INT  21h
        
        POP  DI
        POP  DX
        POP  AX
        POP  BP
        RET
read_array_length ENDP

read_int PROC
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        
        XOR  DI, DI
        XOR  CX, CX
        MOV  BX, 10
        CALL read_char
        CMP  AL, '-'
        JNE  read_int_positive
        
    read_int_negative:
        MOV  DI, 1
        
    read_int_digit:
        CALL read_char
        
    read_int_positive:
        CMP  AL, 13
        JE   read_int_done
        SUB  AL, '0'
        XOR  AH, AH
        XOR  DX, DX
        XCHG CX, AX
        MUL  BX
        ADD  AX, CX
        XCHG AX, CX
        JMP  read_int_digit
        
    read_int_done:
        XCHG AX, CX
        CMP  DI, 0
        JE   read_int_skip_neg
        NEG  AX
        
    read_int_skip_neg:
        POP  DI
        POP  DX
        POP  CX
        POP  BX
        RET
read_int ENDP

read_char PROC
        MOV  AH, 1
        INT  21h
        RET
read_char ENDP