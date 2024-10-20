# Assos
*Assos* is a historical place in Turkey and also a tiny OS example for X86_64

## Build
This project use bare metal build system. `make all` command compile `bootloader`, `kernel loader` and
all `kernel` files and link all kernel files into one elf file. Then merge all binaries into `milos.bin` file.

We run it on to the `qemu-system-x86_64` program.

```bash
make all
```

## License

This project is under the [GPLv2 license](./LICENSE).

