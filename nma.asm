.MODEL small
.STACK 100h
.DATA
    buffer db 32768 dup(?)     ; дані/буфер
    startOfLine db 4 dup(?)
    endOfLine db 4 dup(?)
    startOfRules db 4 dup(?)
    endOfRules db 4 dup(?)
    fileName db "input.nma", 0 ; файл який будемо читати
    fileHandle dw ?            ; handle
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
    mov word ptr endOfRules, si
    



    compareBytes proc
   
    mov si, word ptr startOfLine      
    mov di, word ptr startOfRules     ;;there must be adress of current rule 

    mov cx, 2 ;   move length of rule
compare_loop:
    mov al, byte ptr [di]     
    cmp al, byte ptr [si]     ; С
    jne not_equal             ; 
    inc si                    
    inc di                    ; 
    loop compare_loop         ; 

  
       ;;;;;; replace, move to next rule
    ret

not_equal:
    cmp si, word ptr endOfRules
    cmp byte ptr [di], 9

    inc si
    mov di, word ptr startOfRules ; there must be adress of current rule 

    jne  compare_loop              ;
    ret
compareBytes endp

 

                
          
         

       



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



ende:
    mov ah, 4Ch        
    int 21h
END main