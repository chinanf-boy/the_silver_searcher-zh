Geoff Greer网站:银色搜索者:添加p螺纹

[The Silver Searcher: Adding Pthreads](http:Geoff.Greer.fm/2012/09/07/the-silver-searcher-adding-pthreads/)

* * *

07 Sep 2012

在我的追求中改进[Ag](https://github.com/ggreer/the_silver_searcher/)的速度,我花了一些时间使它多线程.这意味着学习[Pthreads](http://en.wikipedia.org/wiki/POSIX_Threads).

尽管Pthreads API并不太难掌握,但是其他架构决策需要付出更多的努力才能得到正确的结果.我第一次尝试多线程搜索是相当天真的.计划很简单:对于每个文件,创建一个新线程,搜索文件,然后退出线程.它不需要对代码进行大的更改,但我不确定会得到什么样的性能好处.典型的运行Ag会搜索很多文件,为每个文件生成一个线程可能会导致一些显著的开销.不过,我认为这是值得一试的.不久我就开始工作了,但最初的结果令人沮丧:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  2.18s user 20.91s system 152% cpu 15.134 total
%
```

15秒.这比没有螺纹的AG慢7倍!我发布了剖析器.

[![](https://geoff.greer.fm/images/ag_profile_thread_per_file.png)](https://geoff.greer.fm/images/ag_profile_thread_per_file.png)

创建一个新线程不是免费的.我知道有开销,但现在我知道了多少.显然,通过创建和销毁60000个线程来搜索60000个文件不是很有效.

接下来,我尝试了一种不同的并发模式:[Worker threads](http://en.wikipedia.org/wiki/Thread_pool_pattern). 我变了`search_dir()`因此,而不是呼叫`search_file()`在路径上,它添加到工作队列的路径.同时,工作线程从队列中获取路径并调用.`search_file()`在他们身上.我不得不用一对[mutexes](http://en.wikipedia.org/wiki/Lock_%28computer_science%29)为了避免一些比赛条件,但令人惊讶的是很容易得到正确的行为.

一旦我准备好了,我就重新运行我的基准:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  1.47s user 2.54s system 231% cpu 1.731 total
%
```

好得多,但比无螺纹AG快0.3秒.搜索文件是[embarrassingly parallel](http://en.wikipedia.org/wiki/Embarrassingly_parallel). 我希望能提高15%的性能.

所以我开始调整事情.大多数更改都无济于事,但是性能受到工作线程数量的显著影响.我假设3-4个工人是理想的,但我运行基准有多达32个线程,以确保.我绘制了结果图.相比之下:非线程Ag在MacBook Air上花费2.0秒,在我的Ubuntu服务器上花费2.2秒.

这张图中有两条外卖.

首先,操作系统X*烂透了*在这个基准上.有16名工人,表现很可怜.我不得不从图中移除32个工作线程的结果,因为它们使得用更少的线程很难看到性能上的差异.搜索32名工人在OS X上花了8.5秒.这太可耻了.另一方面,Linux内核似乎把事情搞定了.即使有32名工人,也花了2.2秒.

再一次,我拔出了轮廓仪.有32名员工,AG看起来像OSX:

[![](https://geoff.greer.fm/images/ag_profile_os_x_32_threads.png)](https://geoff.greer.fm/images/ag_profile_os_x_32_threads.png)

内核中肯定有一些愚蠢的东西.

无论如何,回到上面的图表:我学到的第二件事情是工作线程的最佳数量与CPU内核不相关.即使是在四核CPU上,两个工人的表现也是最好的.我想弄清楚为什么会出现这种情况,但现在我只想接受它,并调整Ag的性能.我的猜测是瓶颈不再是CPU了.新的限制因素可能是内存带宽或延迟.

在调整工作线程数之后,我想我正在接近最大可能的搜索速度.看一下当前的分析信息:

[![](https://geoff.greer.fm/images/ag_profile_thread_workers.png)](https://geoff.greer.fm/images/ag_profile_thread_workers.png)

没有明显的瓶颈.所有的时间都花在做一些必须做的事情上:打开文件、读取数据、匹配、关闭文件.另一个迹象表明,我不能使事情变得更快.

```text
% time du -sh ~/code
5.8G	/Users/ggreer/code
du -sh ~/code  0.09s user 1.42s system 95% cpu 1.572 total
%
```

没错,我的基准数据集是5.8千兆字节.AG实际上并不是在1.4秒内搜索整个5.8千兆字节.搜索的数据总量约为400 MB.不过,我很惊讶AG比`du`.

看起来这个项目开始结束了.现在我已经完成了性能,大多数更改应该是特征请求和bug修复.也就是说,这是一个有趣的旅程.我学到了很多关于很多事情的东西.

/加载可视化API和PyScar包.谷歌.加载(可视化),"1",{包":\["核心图"]()在谷歌可视化API加载时设置回调运行.setOnLoadCallback(drawChart);//Callback,用于创建和填充数据表,//实例化饼图,传入数据并//绘制它.函数拖拽(){//创建数据表.var data=new google.visualization.DataTable();data.addColumn("string",".rthreads");data.addColumn("number","OS X 10.8,Corei7366U@2.0Ghz");data.addColumn("number","Ubuntu 12.04,Core 2 Duo E3200@3.2Ghz");data.addRows(data.addRows).\[ \["1",1.536,1.419],\["2",1.392,1.358],\["3",1.471,1.848],\["4",1.767,1.894],\["8",2.677,2.025],\["16",4.713,2.066] ]///设置图表选项var选项,设置图表选项var选项={{tit':'Ag工作者线程基准'''Ag工作者线程'''fontSize': 20, 'backgrogrogrogrogrogrogrogroundColor20''''''fontSize': 20''fontSize': 20, 'fontSize': 20, 'backgrogrogrogrogrogrogrogrogrogrogrogrogrogrogrogrogrogrogrogroundColorColorColorColorColorColorColorColorColorColorColor.': {'.'''''\\\\656565#eef'''''''''''''{{{{{363636363636363636363616f'''''''''}{{{{{轴心': {'网格线:{计数}:6 },"Min值":0,"title":"秒"},"颜色":\["43D","396"]"宽度":"100%","高度":500 };/ /实例化并绘制我们的图表,通过一些选项.var.=new google.visualization.ChartWrapper({'chartType': 'ColumnChart','containerId': '.\_div','.':., 'dataTable':data});...();}

* * *

[← Profiling Ag. Writing My Own Scandir](http:Geoff.Greer.fm/2012/09/03/profiling-ag-writing-my-own-scandir/) [ →A Responsible Product Sunset Pledge](http:Geoff.Greer.fm/2012/09/19/a-responsible-product-sunset-pledge/)

* * *

评论时,请记住:这是真的吗?有必要吗?这样好吗?

* * *
