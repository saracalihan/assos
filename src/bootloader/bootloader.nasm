[BITS 16]        ; Set the code to 16-bit mode
[ORG 0x7c00]     ; Set the origin (starting address) to 0x7c00, typical for boot loaders


CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x100000



start:
    mov si, init_msg
    call print
    cli           ; Clear interrupts, disabling all maskable interrupts
    mov ax, 0x00  ; Load immediate value 0x00 into register AX
    mov ds, ax    ; Set data segment (DS) to 0x00
    mov es, ax    ; Set extra segment (ES) to 0x00
    mov ss, ax    ; Set stack segment (SS) to 0x00
    mov sp, 0x7c00; Set stack pointer (SP) to 0x7c00, top of the bootloader segment
    sti           ; Enable interrupts, allowing them to occur again


    ;Load kernel
    mov si, kernel_load_msg
    call print

    mov bx, KERNEL_LOAD_SEG
    mov dh, 0x00
    mov dl, 0x80
    mov cl, 0x02
    mov ch, 0x00
    mov ah, 0x02
    mov al, 8
    int 0x13

    jc disk_read_error


    load_PM:
        cli
        lgdt[gdt_descriptor]
        mov eax, cr0
        or al, 1
        mov cr0, eax
        jmp CODE_OFFSET:PModeMain


    disk_read_error:
        mov si, disk_read_error_msg
        call print
        hlt

    ;GDT Implemetation

    gdt_start:
        dd 0x0
        dd 0x0

        ; Code segment descriptor
        dw 0xFFFF       ; Limte
        dw 0x0000       ; Base
        db 0x00         ; Base
        db 10011010b    ; Access byte
        db 11001111b    ; Flags
        db 0x00         ; Base

        ; Data segment descriptor
        dw 0xFFFF       ; Limte
        dw 0x0000       ; Base
        db 0x00         ; Base
        db 10010010b    ; Access byte
        db 11001111b    ; Flags
        db 0x00         ; Base

    gdt_end:

    gdt_descriptor:
        dw gdt_end - gdt_start - 1 ; Size of GDT -1
        dd gdt_start 


    [BITS 32]
    PModeMain:
        ; mov si, pm_starting_msg
        ; call print
        mov ax, DATA_OFFSET
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov ss, ax
        mov gs, ax
        mov ebp, 0x9C00
        mov esp, ebp

        in al, 0x92
        or al, 2
        out 0x92, al

        ; mov si, kernel_starting_msg
        ; call print
        jmp CODE_OFFSET:KERNEL_START_ADDR




    print:
        lodsb                 ; Load byte at DS:SI into AL register and increment SI
        ; null
        cmp al, 0             ; Compare the value in AL with 0 (null terminator)
        je print_done         ; Jump to 'print_done' if AL is zero (end of string)

        mov ah, 0x0E          ; Set AH register to 0x0E (BIOS teletype output function)
        int 0x10              ; Call BIOS interrupt 0x10 to print the character in AL
        jmp print             ; Jump back to 'print' to process next character

    print_done:
        ret                   ; Return to the caller

no_kernel:
    mov si, no_kernel_msg  ; Kernel yoksa bir mesaj
    call print
    hlt                     ; Hızla dur

init_msg: db 'Bootstrap starting...', 10, 0
kernel_load_msg: db 'Kernel loading...',  10, 0
kernel_starting_msg: db 'Kernel starting...',  10, 0
pm_starting_msg: db 'Protected Mode starting...',  10, 0
disk_read_error_msg: db '[ERROR] DISK READ ERROR!',  10, 0
no_kernel_msg: db '[ERROR] Kernel not found!',  10, 0
halt_msg: db '[HALT] HALT!', 0


times 510 - ($ - $$) db 0   ; Fill the rest of the boot sector with zeros up to 510 bytes

dw 0xAA55   ; Boot sector signature, required to make the disk bootable
