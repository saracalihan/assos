FLAGS=-g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: clear bootloader kernel align_os monitor
bootloader:
	nasm -f bin ./src/bootloader/bootloader.nasm -o ./bin/bootloader.bin 

kernel:
	nasm -f elf64 -g ./src/kernel.nasm -o ./build/kernel.nasm.o
	gcc $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o
	ld -g -relocatable ./build/*.o -o ./build/completeKernel.o
	gcc $(FLAGS) -T ./linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/completeKernel.o

align_os:
	dd if=./bin/bootloader.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=8 >> ./bin/os.bin

monitor:
	qemu-system-x86_64 -hda ./bin/os.bin

clear:
	rm -rf build/* bin/*