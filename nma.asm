.MODEL tiny  
.CODE
org 100h
main:


;taking filename from commandline
mov si, 80h         
    xor cx, cx
    mov cl, [si]       

    inc si            
    lea di, fileName    
    mov bx, di         

copy_filename:
    mov al, [si]        
    cmp al, 0Dh         
    je end_copy
    cmp al, 20h         
    je skip_space
    mov [di], al         
    inc di
skip_space:
    inc si
    loop copy_filename

end_copy:
    mov byte ptr [di], 0 


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
  

    lea si, buffer
    ;START FOR COM
    call read4BytesInAx
    add si, ax

    call read4BytesInAx
    mov word ptr startOfLine, si
    add si, ax
    dec si
    
    mov word ptr endOfLine, si
 
  
    inc si
    call read4BytesInAx
    mov word ptr startOfRules, si
    add si, ax
    dec si
    mov word ptr endOfRules, si
    



    lea si, fileName     
    lea di, checkName  
    mov cx, 8          
    repe cmpsb        
    jne not_match         
    call printLine


not_match:


    compareBytes:
   xor bx,bx
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
    cmp al, byte ptr [si]  

    jne not_equal             ; 
    inc si                    
    inc di               
    inc bx     ; 
    loop compare_loop         ; 

    jmp replace
    replace_end:                
    jmp compareBytes
    

decSi  proc 
    decSi:
    cmp bx,0
    je endSI
    dec bx
    dec si
    jne decSi
endSI:
    ret
decSi endp

not_equal:
call decSi
   cmp si, word ptr endOfLine  
    je new_rule

    


    inc si
    mov word ptr linePartToReplace, si

    mov di, word ptr curentRule  ; there must be adress of current rule 
    
    mov cx, word ptr linePartToReplaceLENGTH
    jne  compare_loop    
new_rule:
    
    mov di, word ptr curentRule
find_new_rule:    
    inc di
    cmp byte ptr [di],0ah
    jne find_new_rule

    inc di
    cmp byte ptr [di],09h
    je placeRuleToStart
    cmp byte ptr [di],00h
    mov word ptr curentRule, di
    jne set_rule
    call printLine ; STDOUT

        

replace:
    mov si, word ptr linePartToReplace
    mov di, word ptr curentRule  

goto_replaceRule:

    inc di
    cmp byte ptr [di], 09h
    jne goto_replaceRule
    inc di
    
    cmp byte ptr [di], 09h
    je zeroReplaceRule

    
    call string_length
    mov word ptr replaceRuleLength, dx
    mov ax, word ptr replaceRuleLength
    cmp ax, word ptr linePartToReplaceLENGTH
    
    jg expand_string
    jl shrink_string
    jmp above_replace_cycle


placeRuleToStart:
mov si, word ptr startOfLine
push di
    
    mov di, word ptr startOfLine
    mov word ptr linePartToReplace, di 
    pop di
    inc di
    call string_length
    mov word ptr replaceRuleLength, dx
    mov word ptr linePartToReplaceLENGTH, 0
    jmp expand_string

zeroReplaceRule:
 mov word ptr replaceRuleLength, 0



shrink_string:


    push si
    push di
    push cx
    push ax
    push dx

    mov di, word ptr linePartToReplace 
    add di, word ptr replaceRuleLength  ; where to

    mov ax, word ptr linePartToReplaceLENGTH  ;move
    sub ax, word ptr replaceRuleLength 
    

    mov word ptr move, ax


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
    
    
    mov ax, word ptr move
    sub di, ax
    sub  word ptr startOfRules, ax
    sub word ptr endOfLine, ax
    cmp word ptr replaceRuleLength,0
    je zeroReplace

    
      
    jne  above_replace_cycle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;-----------------------

zeroReplace:    
    jmp replace_end

endDot:
call printLine

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
    cmp word ptr linePartToReplaceLENGTH, 0
    je NODEC
    dec di
   NODEC: 

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
;;;;;;;;;;;;;;;;;;;;;;;;;;
  cmp word ptr linePartToReplaceLENGTH, 0

    add di, word ptr move
   
    mov ax,word ptr linePartToReplaceLENGTH
    
    mov ax, word ptr move
    add  word ptr startOfRules, ax
    add  word ptr endOfLine, ax
   
    jmp  above_replace_cycle

above_replace_cycle:

    cmp byte ptr [di],'.'  
    jne nextCheck
    mov byte ptr isEnd, 1

nextCheck:
    mov ax,di
    add ax, word  ptr replaceRuleLength
    dec ax
    
    push di
    mov di,ax
    cmp byte ptr [di],'.'  
    pop di
    jne replace_cycle
    mov byte ptr isEnd, 1


replace_cycle:

    mov bh, byte ptr [di]
    mov [si], bh
    
    inc di
    inc si
    cmp byte ptr [di],09h
    
    jne replace_cycle
    mov di, word ptr curentRule 
    
    cmp byte ptr isEnd, 1
    je endDotnear
    jmp replace_end


endDotnear:
    call printLine

string_length proc   ;start of string in di, end must be 09h. result in dx
    xor dx, dx             
    push di

length_loop:
    cmp byte ptr [di], 09h  
    je length_done    
    

    inc dx   
    inc di             
    jmp length_loop        

length_done:
    pop di
    ret                    
string_length endp
   

read4BytesInAx proc
    xor ax, ax          


    mov al, byte ptr [si]   
    inc si                 

    mov bl, byte ptr [si]   
    shl bx, 8              
    or ax, bx              

    inc si                 
    inc si
    inc si

    ret
read4BytesInAx endp





printLine proc
    mov si, word ptr startOfLine  
    mov bx, word ptr endOfLine 
    inc bx

mov di, word ptr linePartToReplace
cmp byte ptr [di], '.'
    jne nextCheckPrint

    mov word ptr skipDot, di

    nextCheckPrint:
    cmp word ptr skipDot, di
    je print_loop

    mov di, word ptr linePartToReplace
    add di, word ptr replaceRuleLength
    dec di
    cmp byte ptr [di], '.'
    jne print_loop
    
    mov word ptr skipDot, di
    jmp print_loop
    
incSI:
    inc si
    jmp incSIreturn

print_loop:
    cmp si, bx      
    je print_done                 
    cmp si, word ptr skipDot
    je incSI
incSIreturn:
    mov dl, byte ptr [si]          
    mov ah, 02h                  
    int 21h                     
    inc si                        
    jmp print_loop                

print_done:
    mov ah, 4Ch        
    int 21h
                               
printLine endp
;END FOR COM


    buffer db 32768 dup(?) 
      ; зробити 32768, при кращих часах) 221
    startOfLine db 4 dup(?)
    endOfLine db 4 dup(?)
    startOfRules db 4 dup(?)
    endOfRules db 4 dup(?)
    curentRule db 4 dup(?)
isEnd db 1 dup(0)
   move db 4 dup(?)
       skipDot db 4 dup(?)
    replaceRuleLength db 4 dup(?)
  linePartToReplaceLENGTH db 4 dup(?)
    linePartToReplace db 4 dup(?) 
    fileName db 21 dup(?) ; файл який будемо читати
    fileHandle dw ?  ; handle  
    checkName db 'CUST1238', 0
   
END main     