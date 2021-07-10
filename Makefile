# bf300 Makefile

all:
	as -g -o rt.o rt.s
	as -g -o bf300.o bf300.s
	ld -e main -nostdlib -nopie -o bf300 rt.o bf300.o
	strip bf300
	strip -R .bss bf300
	strip -R .comment bf300
	strip -R .data bf300

clean:
	rm -rf bf300 bf300.o rt.o bf300.core
