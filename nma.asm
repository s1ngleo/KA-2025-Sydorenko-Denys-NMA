.MODEL small
.STACK 100h
.DATA
    buffer db 32768 dup(?)     ; дані/буфер
    fileName db "input.nma", 0 ; файл який будемо читати
    fileHandle dw ?            ; handle
    
    bytesRead dw ?             ; скільки прочитали
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
    mov bytesRead, ax  ; скільки прочитали

    ; закриваємо файл
    mov ah, 3Eh        ; закрить файл
    mov bx, fileHandle
    int 21h
;|||||||||||||||||||||||тут буде работа з даними файлу, які лежать у буфері, поки що з цікавого тут просто вивод||||||||||||||||||||||||||







stdout:
    mov ah, 40h
    mov bx, 1
    mov cx, bytesRead ; скільки байт вивести
    lea dx, buffer ; виводимо буфер
    int 21h

ende:
    mov ah, 4Ch        
    int 21h
END main