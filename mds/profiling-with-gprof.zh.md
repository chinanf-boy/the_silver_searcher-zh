Geoff Greer 的网站: 用 Gprof 分析

[Profiling with Gprof](http:Geoff.Greer.fm/2012/02/08/profiling-with-gprof/)

---

2012 年 2 月 8 日

[我 说过，我要发表关于 gprof 的 博文](http:Geoff.Greer.fm/2012/01/23/making-programs-faster-profiling/),所以这里.

Valgrind 和 gprof 是两个非常不同的工具。Valgrind 是一个[插装型 分析器](http://en.wikipedia.org/wiki/Profiling_%28computer_programming%29#Instrumenting_profilers).Gprof 是一个[采样 分析器](http://en.wikipedia.org/wiki/Profiling_%28computer_programming%29#Statistical_profilers)。Gprof 大部分时间都在无所事事。然后,每隔 100,000,000 个时钟周期左右,就会看到[指令指针](http://en.wikipedia.org/wiki/Program_counter)查看您的程序所使用的函数。它会收集足够多次的数据,以便最终了解您的程序花费时间的位置。这种方法的优点是您的程序几乎全速运行。这可以让您更好地了解程序花费多长时间等待磁盘或网络 I/O 等操作。我对 gprof 的典型分析经验如下所示:

```text
(sets CFLAGS=-pg in Makefile.am)
$ make clean && ./build.sh
(snip)
$ time ./ag --literal abcdefghijklmnopqrstuvwxyz ../ | wc -l
271

real    0m1.144s
user    0m0.792s
sys     0m0.340s

$ gprof -bp ag gmon.out
Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total
 time   seconds   seconds    calls  ms/call  ms/call  name
 36.09      0.22     0.22    20953     0.01     0.01  is_binary
 32.81      0.42     0.20    16567     0.01     0.01  boyer_moore_strnstr
 13.12      0.50     0.08       63     1.27     1.27  print_file_matches
 11.48      0.57     0.07                             filename_filter
  3.28      0.59     0.02    26377     0.00     0.00  strlcpy
  1.64      0.60     0.01    52754     0.00     0.00  strlcat
  1.64      0.61     0.01        1    10.01   540.36  search_dir
  0.00      0.61     0.00    40160     0.00     0.00  log_debug
  0.00      0.61     0.00    40160     0.00     0.00  vplog
  0.00      0.61     0.00      213     0.00     0.00  add_ignore_pattern
  0.00      0.61     0.00       63     0.00     0.00  print_path
  0.00      0.61     0.00       16     0.00     0.00  load_ignore_patterns
  0.00      0.61     0.00        1     0.00     0.00  cleanup_ignore_patterns
  0.00      0.61     0.00        1     0.00     0.00  generate_skip_lookup
  0.00      0.61     0.00        1     0.00     0.00  init_options
  0.00      0.61     0.00        1     0.00     0.00  parse_options
  0.00      0.61     0.00        1     0.00     0.00  set_log_level
```

一些注意事项:要使 gprof 正常工作。您需要将 -pg 添加到 CFLAGS 中，所以在 linux 服务器上运行它.[gprof 在 OS X 中坏坏的](http://lists.apple.com/archives/PerfOptimization-dev/2006/Apr/msg00014.html)，如果你想在 OS X 上使用采样分析器,我推荐使用 Instruments.app。

---
