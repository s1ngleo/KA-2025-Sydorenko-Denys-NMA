.MODEL small
.STACK 100h
.DATA
    buffer db 32768 dup(?)     ; дані/буфер
    startOfLine db 4 dup(?)
    endOfLine db 4 dup(?)
    startOfRules db 4 dup(?)
    endOfRules db 4 dup(?)
    curentRule db 4 dup(?)
   move db 4 dup(?)
    replaceRuleLength db 4 dup(?)
  linePartToReplaceLENGTH db 4 dup(?)
    linePartToReplace db 4 dup(?) 
    fileName db "input.nma", 0 ; файл який будемо читати
    fileHandle dw ?  ; handle    
        
.CODE
main:
    mov ax, @data
    mov ds, ax

    ; відкриваємо файл
    mov ah, 3Dh        
    mov al, 0          ; читати
    lea dx, fileName   ; пихаєм файл
    int 21h
    mov fileHandle, ax ; наш дескриптор

    ; читаємо файл
    mov ah, 3Fh        ; в бх пихаєм дескриптор, дх що читать, сх скільки будемо читати
    mov bx, fileHandle     
    lea dx, buffer
    mov cx, 32768      ; читаемо до 32768 байт
    int 21h
  


;|||||||||||||||||||||||тут буде работа з даними файлу, які лежать у буфері, поки що з цікавого тут просто вивод||||||||||||||||||||||||||
    
    call read4BytesInAx
    add si, ax

    call read4BytesInAx
    mov word ptr startOfLine, si
    add si, ax

    sub si, 3
    mov word ptr endOfLine, si
    add si, 3
    
    call read4BytesInAx
    mov word ptr startOfRules, si
    add si, ax
    dec si
    mov word ptr endOfRules, si
    






    compareBytes:
   
    mov si, word ptr startOfLine    
    xor dx,dx
    mov dx, word ptr startOfRules   
    mov word ptr curentRule , dx    ;there must be adress of current rule 

set_rule:
    mov si, word ptr startOfLine 
    mov word ptr linePartToReplace, si
    mov di, word ptr curentRule  
    call string_length          ;length in dx, di pointer on string

    mov word ptr linePartToReplaceLENGTH, dx
    mov cx, dx

compare_loop:
    
    
    mov al, byte ptr [di]     
    cmp al, byte ptr [si]     ; 
    jne not_equal             ; 
    inc si                    
    inc di                    ; 
    loop compare_loop         ; 

    jmp replace
    replace_end:                
    jmp compareBytes
    

not_equal:

    cmp si, word ptr endOfLine
    je new_rule

    inc si
    mov word ptr linePartToReplace, si

    mov di, word ptr curentRule  ; there must be adress of current rule 
    jne  compare_loop    
new_rule:

    mov di, word ptr curentRule
find_new_rule:    
    inc di
    cmp byte ptr [di],0ah
    jne find_new_rule

    inc di
    cmp byte ptr [di],00h
    mov word ptr curentRule, di
    jne set_rule
    jmp ende ; STDOUT

          



replace:
    mov si, word ptr linePartToReplace
    mov di, word ptr curentRule  

goto_replaceRule:

    inc di
    cmp byte ptr [di], 09h
    jne goto_replaceRule
    inc di
    
    call string_length
    mov word ptr replaceRuleLength, dx
    mov ax, word ptr replaceRuleLength
    cmp ax, word ptr linePartToReplaceLENGTH
    
    jg expand_string
    jl shrink_string
    jmp replace_cycle


shrink_string:


    push si
    push di
    push cx
    push ax
    push dx

    mov di, word ptr linePartToReplace 
    add di, word ptr replaceRuleLength

    mov ax, word ptr linePartToReplaceLENGTH
    sub ax, word ptr replaceRuleLength 


    
 
    


    
  ;  mov word ptr endOfRules, di

shrink_loop:
    mov bx,di
    add bx, ax

    mov dl, byte ptr [bx]
    mov byte ptr [di], dl
    inc di
    
   
    cmp di,  word ptr endOfRules
    jne shrink_loop     

    pop dx
    pop ax
    pop cx
    pop di
    pop si
    
    sub di, word ptr linePartToReplaceLENGTH
    inc di
    
    mov ax, word ptr linePartToReplaceLENGTH
    sub    word ptr startOfRules,  ax      
    jmp  replace_cycle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-----------------------




    expand_string:
    push si
    push di
    push cx
    push ax
    push dx

    mov si, word ptr linePartToReplace
    

    mov ax, word ptr replaceRuleLength
    sub ax, word ptr linePartToReplaceLENGTH ;ax length to move right
    
    mov word ptr move, ax
    



    mov di, word ptr endOfRules ; di end of rules
    dec di
    


    

    add di, word ptr replaceRuleLength
    mov word ptr endOfRules, di

shift_loop:
    mov bx,di
    sub bx, ax

    mov dl, byte ptr [bx]
    mov byte ptr [di], dl
    dec di
    
    cmp di,  word ptr linePartToReplace
    jne shift_loop     

    pop dx
    pop ax
    pop cx
    pop di
    pop si

    add di, word ptr move
    mov ax,word ptr linePartToReplaceLENGTH
    
    mov ax, word ptr move
    add  word ptr startOfRules, ax
    add  word ptr endOfLine, ax
   
    jmp  replace_cycle
 
    

replace_cycle:
    

    mov bh, byte ptr [di]
    mov [si], bh
    
    inc di
    inc si
    cmp byte ptr [di],09h
    
    jne replace_cycle
    mov di, word ptr curentRule 
    
    jmp replace_end



string_length proc   ;start of string in di, end must be 09h. result in dx
    xor dx, dx             
    push di
length_loop:
    cmp byte ptr [di], 09h  
    je length_done       
    inc di                 
    inc dx              
    jmp length_loop        

length_done:
    pop di
    ret                    
string_length endp
   





read4BytesInAx proc
    xor ax, ax   
            
    mov al, byte ptr [si]
       
    inc si                 
    add al, byte ptr [si] 
   
    inc si                
    add al, byte ptr [si] 
    
    inc si   
    add al, byte ptr [si]
      
    inc si      
    ret
    read4BytesInAx endp





printLine proc
    mov si, word ptr startOfLine  
  

print_loop:
    cmp byte ptr [si], 0dh               
    je print_done                 

    mov dl, byte ptr [si]          
    mov ah, 02h                  
    int 21h                     
    inc si                        
    jmp print_loop                

print_done:
    ret                           
printLine endp
    

ende:
call printLine
    mov ah, 4Ch        
    int 21h
END main