bf300
=====
`bf300` is a Brainfuck compiler under 300 bytes.

It probably only works on
[OpenBSD](https://www.openbsd.org/)/amd64
as-is.

Write-up
--------
See the
[blog post](https://briancallahan.net/blog/20210710).

(Blog post forthcoming.)

Building
--------
Just run `make`.

Running
-------
```
$ bf300 < input.bf > output.c
```
Alternatively:
```
$ bf300 < input.bf | cc -x c -
```

Size
----
```
$ size bf300.o
text    data    bss     dec     hex
242     0       0       242     f2
```

License
-------
ISC License. See `LICENSE` for details.
