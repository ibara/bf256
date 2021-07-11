bf256
=====
`bf256` is a Brainfuck compiler under 256 bytes in size.

It probably only works on
[OpenBSD](https://www.openbsd.org/)/amd64
as-is.

Write-up
--------
See the
[blog post](https://briancallahan.net/blog/20210710.html).

Building
--------
Just run `make`.

Running
-------
```
$ bf256 < input.bf > output.c
```
Alternatively:
```
$ bf256 < input.bf | cc -x c -
```

Size
----
Compiler alone:
```
$ size bf256.o
text    data    bss     dec     hex
227     0       0       227     e3
```

With overhead:
```
$ size bf256
text    data    bss     dec     hex
251     0       0       251     fb
```

License
-------
ISC License. See `LICENSE` for details.
