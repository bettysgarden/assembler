.MODEL large
org 100h
.data  
   Arr                  db  -2,3,3,22
   size                 db  4   
   Msg_yes              db  "All negative values go before positive$"
   Msg_no               db  "Negative values are not before positive$"
   Msg_all_negative     db  "There are all negative numbers in the array$"
.code
    Start:
        mov si, 0                           
        mov al, Arr[si]                    
        cmp al, 0    ; if negative            
        jl  Next_while_not_found_first_positive
        jmp Check_if_all_positive
        
    Next_while_not_found_first_positive:                      
        dec size
        cmp size, 0  
        je Print_all_negative
        inc si
        mov al, Arr[si]
        cmp al, 0 ; if positive
        jg Check_if_all_positive
        jmp Next_while_not_found_first_positive
        
    Check_if_all_positive:
        dec size
        cmp size, 0
        je Print_yes_message
        inc si
        mov al, Arr[si]
        cmp al, 0    ; if positive
        jg Check_if_all_positive
        jmp Print_no_message                                   
             
    Finish:
        ret
          
    Print_yes_message:
        mov dx, offset Msg_yes
        mov ah, 09h 
        int 21h  
        ret       
        
    Print_no_message:
        mov dx, offset Msg_no
        mov ah, 09h 
        int 21h   
        ret 
        
    Print_all_negative:
        mov dx, offset Msg_all_negative
        mov ah, 09h 
        int 21h  
        ret