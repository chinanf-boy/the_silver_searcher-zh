Geoff Greer 的网站:让 Ag 更快:用 Valgrind 进行分析

[Making Ag Faster: Profiling with Valgrind](http:Geoff.Greer.fm/2012/01/23/making-programs-faster-profiling/)

---

2012 年 1 月 23 日

今时今日，许多软件说它"足够快"。由于要搜索的代码库可能非常大，因此对[The Silver Searcher](https://github.com/ggreer/the_silver_searcher)来说，没有"足够快"的说法。事实上,我想 Ag 的主要目标应该是速度。

提高性能，并不总是那么容易，但很简单:

1.  找到程序中最慢的部分.
2.  让这部分更快.
3.  重复,直到它足够快，或你疯了.

有很多分析工具，会让程序员经常争论哪个是最好的。我用[gprof](http://www.cs.utah.edu/dept/old/texinfo/as/gprof.html),[callgrind](http://valgrind.org/docs/manual/cl-manual.html),和[Instruments.app](http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html)。您使用哪种分析器并不重要，*实际上使用一个*就够了。他们都有自己的优点和缺点,但对于这篇文章,我只会介绍[Valgrind 的](http://valgrind.org/)callgrind。使用 callgrind 不需要特殊编译。只需使用您的程序名称调用它，它将生成 callgrind_annotate 的分析数据以进行分析。

这是 Ag 的典型分析运行:

```text
$ make clean && ./build.sh
(snip)
$ time valgrind --tool=callgrind --dsymutil=yes ./ag --literal abcdefghijklmnopqrstuvwxyz ../
(snip)
real	1m34.709s
user	1m33.206s
sys	0m1.492s
$ callgrind_annotate --auto=yes callgrind.out.10361
--------------------------------------------------------------------------------
Profile data file 'callgrind.out.10361' (creator: callgrind-3.6.1-Debian)
--------------------------------------------------------------------------------
I1 cache:
D1 cache:
LL cache:
Timerange: Basic block 0 - 798409857
Trigger: Program termination
Profiled target:  ./ag --literal abcdefghijklmnopqrstuvwxyz ../ (PID 10361, part 1)
Events recorded:  Ir
Events shown:     Ir
Event sort order: Ir
Thresholds:       99
Include dirs:
User annotated:
Auto-annotation:  on

--------------------------------------------------------------------------------
           Ir
--------------------------------------------------------------------------------
3,068,387,924  PROGRAM TOTALS

--------------------------------------------------------------------------------
           Ir  file:function
--------------------------------------------------------------------------------
1,764,541,095  src/util.c:ag_strnstr [/home/geoff/code/the_silver_searcher/ag]
  386,020,821  /build/buildd/eglibc-2.13/posix/fnmatch_loop.c:internal_fnmatch [/lib/x86_64-linux-gnu/libc-2.13.so]
  226,548,868  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../strcmp.S:__GI_strncmp [/lib/x86_64-linux-gnu/libc-2.13.so]
  181,861,517  src/util.c:is_binary [/home/geoff/code/the_silver_searcher/ag]
  123,211,270  /build/buildd/eglibc-2.13/posix/fnmatch.c:fnmatch@@GLIBC_2.2.5 [/lib/x86_64-linux-gnu/libc-2.13.so]
  104,867,805  src/print.c:print_file_matches [/home/geoff/code/the_silver_searcher/ag]
   77,058,570  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../strlen.S:__GI_strlen [/lib/x86_64-linux-gnu/libc-2.13.so]
   60,030,629  /build/buildd/eglibc-2.13/posix/fnmatch_loop.c:internal_fnmatch'2 [/lib/x86_64-linux-gnu/libc-2.13.so]
   44,019,376  src/ignore.c:filename_filter [/home/geoff/code/the_silver_searcher/ag]
   27,072,821  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/memchr.S:memchr [/lib/x86_64-linux-gnu/libc-2.13.so]
    9,329,984  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../strcmp.S:__GI_strcmp [/lib/x86_64-linux-gnu/libc-2.13.so]
    7,803,075  /build/buildd/eglibc-2.13/malloc/malloc.c:_int_malloc [/lib/x86_64-linux-gnu/libc-2.13.so]
    7,040,644  /build/buildd/eglibc-2.13/posix/../locale/weight.h:internal_fnmatch
    6,062,124  /build/buildd/eglibc-2.13/string/../string/memmove.c:__GI_memmove [/lib/x86_64-linux-gnu/libc-2.13.so]
    4,384,383  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../memcpy.S:__GI_memcpy [/lib/x86_64-linux-gnu/libc-2.13.so]
    3,951,640  /build/buildd/eglibc-2.13/malloc/malloc.c:_int_free [/lib/x86_64-linux-gnu/libc-2.13.so]
    3,779,300  /build/buildd/eglibc-2.13/dirent/../sysdeps/unix/readdir.c:readdir [/lib/x86_64-linux-gnu/libc-2.13.so]
    3,181,118  /build/buildd/eglibc-2.13/malloc/malloc.c:malloc [/lib/x86_64-linux-gnu/libc-2.13.so]
(snip)
```

我剪掉了带注释的源代码。你可以在[这里](http:Geoff.Greer.fm/code/ag_callgrind_slow.txt)看到完整的输出.

这个分析信息告诉我，我将所有时间花在`strnstr()`上。我做了一些关于字符串匹配的研究,并发现了关于[Boyer-Moore 算法](http://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string_search_algorithm)。再[读了更多 ](http://blog.phusion.nl/2010/12/06/efficient-substring-searching/),我决定采用 Boyer-Moore 的简化版本[Boyer-Moore-Horspool](http://en.wikipedia.org/wiki/Boyer%E2%80%93Moore%E2%80%93Horspool_algorithm).

这是我[实现](https://github.com/ggreer/the_silver_searcher/pull/12)Boyer-Moore-Horspool strstr 之后的数据:

```text
$ time valgrind --tool=callgrind ./ag --literal abcdefghijklmnopqrstuvwxyz ../
real	0m32.429s
user	0m31.034s
sys	0m1.324s
$ callgrind_annotate --auto=yes callgrind.out.11921
--------------------------------------------------------------------------------
Profile data file 'callgrind.out.11921' (creator: callgrind-3.6.1-Debian)
--------------------------------------------------------------------------------
I1 cache:
D1 cache:
LL cache:
Timerange: Basic block 0 - 228181262
Trigger: Program termination
Profiled target:  ./ag --literal abcdefghijklmnopqrstuvwxyz ../ (PID 11921, part 1)
Events recorded:  Ir
Events shown:     Ir
Event sort order: Ir
Thresholds:       99
Include dirs:
User annotated:
Auto-annotation:  on

--------------------------------------------------------------------------------
           Ir
--------------------------------------------------------------------------------
1,139,437,344  PROGRAM TOTALS

--------------------------------------------------------------------------------
         Ir  file:function
--------------------------------------------------------------------------------
386,014,011  /build/buildd/eglibc-2.13/posix/fnmatch_loop.c:internal_fnmatch [/lib/x86_64-linux-gnu/libc-2.13.so]
181,870,097  src/util.c:is_binary [/home/geoff/code/the_silver_searcher/ag]
123,209,345  /build/buildd/eglibc-2.13/posix/fnmatch.c:fnmatch@@GLIBC_2.2.5 [/lib/x86_64-linux-gnu/libc-2.13.so]
104,867,805  src/print.c:print_file_matches [/home/geoff/code/the_silver_searcher/ag]
 76,747,163  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../strlen.S:__GI_strlen [/lib/x86_64-linux-gnu/libc-2.13.so]
 63,421,170  src/util.c:boyer_moore_strnstr [/home/geoff/code/the_silver_searcher/ag]
 60,028,609  /build/buildd/eglibc-2.13/posix/fnmatch_loop.c:internal_fnmatch'2 [/lib/x86_64-linux-gnu/libc-2.13.so]
 44,018,667  src/ignore.c:filename_filter [/home/geoff/code/the_silver_searcher/ag]
 27,072,637  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/memchr.S:memchr [/lib/x86_64-linux-gnu/libc-2.13.so]
  8,312,570  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../strcmp.S:__GI_strcmp [/lib/x86_64-linux-gnu/libc-2.13.so]
  7,803,075  /build/buildd/eglibc-2.13/malloc/malloc.c:_int_malloc [/lib/x86_64-linux-gnu/libc-2.13.so]
  7,040,534  /build/buildd/eglibc-2.13/posix/../locale/weight.h:internal_fnmatch
  6,061,868  /build/buildd/eglibc-2.13/string/../string/memmove.c:__GI_memmove [/lib/x86_64-linux-gnu/libc-2.13.so]
  4,384,383  /build/buildd/eglibc-2.13/string/../sysdeps/x86_64/multiarch/../memcpy.S:__GI_memcpy [/lib/x86_64-linux-gnu/libc-2.13.so]
  3,951,640  /build/buildd/eglibc-2.13/malloc/malloc.c:_int_free [/lib/x86_64-linux-gnu/libc-2.13.so]
  3,779,220  /build/buildd/eglibc-2.13/dirent/../sysdeps/unix/readdir.c:readdir [/lib/x86_64-linux-gnu/libc-2.13.so]
  3,181,118  /build/buildd/eglibc-2.13/malloc/malloc.c:malloc [/lib/x86_64-linux-gnu/libc-2.13.so]
  3,089,135  src/main.c:search_dir'2 [/home/geoff/code/the_silver_searcher/ag]
  2,095,514  /build/buildd/eglibc-2.13/malloc/malloc.c:free [/lib/x86_64-linux-gnu/libc-2.13.so]
  2,018,298  /build/buildd/eglibc-2.13/dirent/../sysdeps/wordsize-64/../../dirent/scandir.c:scandir [/lib/x86_64-linux-gnu/libc-2.13.so]
  1,941,992  /build/buildd/eglibc-2.13/string/strcoll_l.c:strcoll_l [/lib/x86_64-linux-gnu/libc-2.13.so]
  1,889,859  /build/buildd/eglibc-2.13/stdlib/msort.c:msort_with_tmp.part.0'2 [/lib/x86_64-linux-gnu/libc-2.13.so]
  1,704,553  /build/buildd/eglibc-2.13/malloc/malloc.c:malloc_consolidate.part.3 [/lib/x86_64-linux-gnu/libc-2.13.so]
  1,644,688  src/ignore.c:ignorefile_filter [/home/geoff/code/the_silver_searcher/ag]
  1,601,628  /build/buildd/eglibc-2.13/dirent/../sysdeps/unix/sysv/linux/getdents.c:__getdents [/lib/x86_64-linux-gnu/libc-2.13.so]
  1,582,620  src/util.c:strlcat [/home/geoff/code/the_silver_searcher/ag]
(snip)
```

对于好奇的童鞋，callgrind_annotate 的完整输出是[在这里](http:Geoff.Greer.fm/code/ag_callgrind.txt).

这是一个 整体 3 倍的加速和 27 倍的字符串匹配加速。令人印象深刻! 现在,Ag 花费大部分时间来确定它是否应该搜索文件。很明显我需要在这里，进行下一步优化。

Valgrind 并不完美。它使程序运行速度比通常慢 25-50 倍，因此您不会注意到是否花费了所有时间等待网络或磁盘 I/O。在 Ag 的情况下,我的基准测试性能提高了 20%.

要获得更多有用的数据，需要从仪器分析器，切换到采样分析器。Instruments.app 和 gprof 都是采样分析器，但这篇文章已经太长了。我会在其他时间报道他们.

---
