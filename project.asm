;; COAL PROJECT CALCULATOR
.model small
.stack 100h

.data
design1  db "=====================$"
heading  db "     CALCULATOR      $"
msg1     db "Enter the first number: $"
msg2     db "Enter the second number: $"
msg3     db "Enter the Operator: $"
msg4 db "Invalid input entered$"
operator db ?
storage1 db 4, 0, 4 dup(0)
storage2 db 4, 0, 4 dup(0)
temp     dw 0
result   dw 0
num1     dw 0
num2     dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 09h
    lea dx, design1
    int 21h
    call newline

    mov ah, 09h
    lea dx, heading
    int 21h
    call newline

    mov ah, 09h
    lea dx, design1
    int 21h
    call newline

    ; --- First Number ---
    mov ah, 09h
    lea dx, msg1
    int 21h
    lea dx, storage1
    call take_input
    mov num1, ax

    ; --- Second Number ---
    mov ah, 09h
    lea dx, msg2
    int 21h
    lea dx, storage2
    call take_input
    mov num2, ax

    ; --- Operator ---
    mov ah, 09h
    lea dx, msg3
    int 21h
    mov ah, 01h
    int 21h
    mov operator, al
    call newline

    ; --- Choose Operation ---
    cmp operator, '+'
    je addition
    cmp operator, '-'
    je subtraction
    cmp operator, '*'
    je multiplication
    cmp operator, '/'
    je division
    jmp error_msg


addition:
    mov ax, num1
    add ax, num2
    mov result, ax
    mov ax, result
    call print_num
    call newline
    jmp done_calc

subtraction:
    mov ax, num1
    sub ax, num2
    mov result, ax
    mov ax, result
    call print_num
    call newline
    jmp done_calc

multiplication:
    mov ax, num1        ; ax = num1
    mov bx, num2        ; bx = num2
    mul bx              ; AX = num1 * num2 (use BX not memory!)
    mov result, ax
    mov ax, result
    call print_num
    call newline
    jmp done_calc

division:
    mov ax, num1
    mov dx, 0           ; clear dx before division!
    mov bx, num2        ; divisor in register not memory
    div bx              ; ax = num1 / num2
    mov result, ax
    mov ax, result
    call print_num
    call newline
    jmp done_calc


error_msg:
mov ah,09h
lea dx,msg4
int 21h

done_calc:
    mov ah, 4ch
    int 21h
main endp

; ===========================
newline proc
    mov ah, 02h
    mov dl, 13
    int 21h
    mov ah, 02h
    mov dl, 10
    int 21h
    ret
newline endp

; ===========================
take_input proc
    mov ah, 0ah
    int 21h
    mov bx, dx
    mov si, bx
    add si, 2
    mov bl, [bx+1]
    mov ch, 0
    mov temp, 0

number_convert:
    cmp ch, bl
    je done

    mov ax, temp
    mov dx, ax
    shl ax, 1
    shl dx, 1
    shl dx, 1
    shl dx, 1
    add ax, dx
    mov temp, ax

    mov al, [si]
    sub al, 48
    mov ah, 0
    add temp, ax

    inc si
    inc ch
    jmp number_convert

done:
    mov ax, temp
    push ax
    mov ah, 02h
    mov dl, 13
    int 21h
    mov ah, 02h
    mov dl, 10
    int 21h
    pop ax
    ret
take_input endp

; ===========================
print_num proc
    mov bx, 0
    mov cx, 10

extract_loop:
    mov dx, 0
    div cx
    push dx
    inc bx
    cmp ax, 0
    jne extract_loop

print_loop:
    pop dx
    add dl, 48
    mov ah, 02h
    int 21h
    dec bx
    jnz print_loop

    ret
print_num endp

end main