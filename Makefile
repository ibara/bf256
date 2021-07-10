# bf256 Makefile

all:
	gas -g -o rt.o rt.s
	gas -g -o bf256.o bf256.s
	ld -e main -nostdlib -nopie -o bf256 rt.o bf256.o
	strip bf256
	strip -R .bss bf256
	strip -R .comment bf256
	strip -R .data bf256

clean:
	rm -rf bf256 bf256.o rt.o bf256.core
