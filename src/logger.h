#ifndef LOGGER_H
#define LOGGER_H


void put_char(char c) {
    asm volatile (
        "movb %0, %%al\n"
        "movb $0x0E, %%ah\n"
        "int $0x10\n"
        :
        : "r" (c)
        : "%al", "%ah"
    );
}

void klog(char* str){
    while(*str=='\0'){
        put_char(*str);
        str++;
    }
}

#endif // LOGGER_H