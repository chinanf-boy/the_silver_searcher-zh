Geoff Greer 网站:银色搜索者:添加 Pthreads

[The Silver Searcher: Adding Pthreads](http:Geoff.Greer.fm/2012/09/07/the-silver-searcher-adding-pthreads/)

---

07 Sep 2012

我的追求的是,提升[Ag](https://github.com/ggreer/the_silver_searcher/)的速度,我花了一些时间使它能多线程运行。这意味着要学习[Pthreads](http://en.wikipedia.org/wiki/POSIX_Threads)。

尽管 Pthreads API 并不太难掌握，但其他架构决策需要付出更多的努力才能得到正确的结果。我第一次的多线程搜索尝试是很想当然的。计划很简单:对于每个文件,创建一个新线程,搜索文件,然后退出线程。它不需要对代码进行大的更改,但我不确定会得到什么样的性能好处。运行 Ag 的典型例子是会搜索很多文件，为每个文件生成一个线程，可能会导致一些显著的开销。不过,我认为这是值得一试的。不久后，我就开始工作了，但刚开始的结果令人沮丧:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  2.18s user 20.91s system 152% cpu 15.134 total
%
```

15 秒。这比没有多线程的 AG 慢 7 倍! 下面是剖析器.

[![](https://geoff.greer.fm/images/ag_profile_thread_per_file.png)](https://geoff.greer.fm/images/ag_profile_thread_per_file.png)

创建一个新线程不是免费的。我知道会有开销，但现在我知道是多少啦。显然,通过创建和销毁 60000 个线程来搜索 60000 个文件，不是有效的。

接下来,我尝试了一种不同的并发模式:[Worker threads](http://en.wikipedia.org/wiki/Thread_pool_pattern)。 我改变了`search_dir()`，让它不再是在一条路径上执行`search_file()`，而是将它(路径)添加到工作队列。同时,工作线程，从队列中获取路径和通过`search_file()`调用。我不得不用一对[mutexes](http://en.wikipedia.org/wiki/Lock_%28computer_science%29)为了避免一些竞态条件,但令人惊讶的是，很容易就得到正确的行为。

一旦我准备好了,我就重新运行我的基准:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  1.47s user 2.54s system 231% cpu 1.731 total
%
```

好得多,但只比无多线程的 AG 快 0.3 秒。搜索文件其实[过多的并发](http://en.wikipedia.org/wiki/Embarrassingly_parallel)了。 我的希望是能提高 15%的性能.

所以我开始调整事情。大多数更改都无济于事，但是性能会大大受到工作线程数量的影响。我假设 3-4 个'工人'是理想的，但我运行基准，会确保有多达 32 个线程。我绘制了结果图。相比之下:非线程 Ag 在 MacBook Air 上花费 2.0 秒,而在我的 Ubuntu 服务器上花费 2.2 秒.

一张图中有两条路线。

首先,OS X*在这个基准上烂透了*。有 16 名工人,表现很可怜。我不得不从图中移除 32 个工作线程的结果，因为它们这么少的线程，使得很难看到性能上的差异。搜索 32 名'工人'在 OS X 上花了 8.5 秒。感到可耻吧。另一方面,Linux 内核似乎把事情搞定了。即使有 32 名'工人'，也只花了 2.2 秒.

再一次,我拔出了剖析仪。有 32 名'工人'，OSX 系统的 Ag 看起来像 :

[![](https://geoff.greer.fm/images/ag_profile_os_x_32_threads.png)](https://geoff.greer.fm/images/ag_profile_os_x_32_threads.png)

内核中肯定有一些愚蠢的东西。

无论如何，回到上面的图表: 我学到的第二件事情是工作线程的最佳数量与 CPU 内核不相关。即使是在四核 CPU 上,两个工人的表现也是最好的。我想弄清楚为什么会出现这种情况，但现在我只想接受它,并调整 Ag 的性能。我的猜测是，瓶颈不再是 CPU 了。新的限制因素可能是内存带宽或延迟.

在调整工作线程数之后,我想我正在接近最大可能的搜索速度。看一下当前的分析信息:

[![](https://geoff.greer.fm/images/ag_profile_thread_workers.png)](https://geoff.greer.fm/images/ag_profile_thread_workers.png)

没有明显的瓶颈。所有的时间都花在做一些必须做的事情上:打开文件、读取数据、匹配、关闭文件。另一个迹象表明,我不能使事情变得更快.

```text
% time du -sh ~/code
5.8G	/Users/ggreer/code
du -sh ~/code  0.09s user 1.42s system 95% cpu 1.572 total
%
```

没错,我的基准数据集是 5.8 GB。AG 实际上并不是在 1.4 秒内搜索整个 5.8 GB。搜索的数据总量其实约为 400 MB。不过,我很惊讶 AG 比`du`快了。

看来这个项目开始迈入结尾了。现在我已经完成了性能,大多数更改应该是特征请求和 bug 修复。总的来说，这是一个有趣的旅程.我学到了很多事，与很多的东西。

---

[← 剖析 Ag. 编写 我的 Scandir](profiling-ag-writing-my-own-scandir.zh.md)

---

评论时,请记住:这是真的吗?有必要吗?这样好吗?

---
