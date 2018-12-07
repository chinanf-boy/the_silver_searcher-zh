Geoff Greer的网站:剖析Ag.写我自己的Scandir

[Profiling Ag. Writing My Own Scandir](http:Geoff.Greer.fm/2012/09/03/profiling-ag-writing-my-own-scandir/)

* * *

2012年9月3日

虽然[I benchmarked every revision of Ag](http:Geoff.Greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/),我没有把它们全部描述出来.在查看上一篇文章中的图表后,我描述了一些性能发生重大变化的修订版.

[![](https://geoff.greer.fm/images/ag_profile_a87aa8f822d9029243423ef0725ec03ca347141b.png)](https://geoff.greer.fm/images/ag_profile_a87aa8f822d9029243423ef0725ec03ca347141b.png)这是一次修订版a87aa8f8;就在我之前[reverted the performance regression](https://github.com/ggreer/the_silver_searcher/commit/e344ca087099431c1bcf733b3ae28316f6932683).您可以看到它花费了80%的执行时间`fnmatch()`.

[![](https://geoff.greer.fm/images/ag_profile_0.9.png)](https://geoff.greer.fm/images/ag_profile_0.9.png)这是标记版本0.9.速度要快得多,而且只花费大约一半的时间`fnmatch()`.

[![](https://geoff.greer.fm/images/ag_profile_ag_scandir.png)](https://geoff.greer.fm/images/ag_profile_ag_scandir.png)最后,这是合并后的运行[pull request #56](https://github.com/ggreer/the_silver_searcher/pull/56).这固定了[issue #43](https://github.com/ggreer/the_silver_searcher/issues/43)并且在许多情况下改进了性能.我为拉动请求感到自豪,因为它修复了很多问题.本文的其余部分解释了我为使一切按照我想要的方式工作而做出的具体改变.

首先,我应该解释Ag的旧行为.在我合并拉取请求之前,Ag打电话给[`scandir()`](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/scandir.3.html)在每个目录上.然后`scandir()`叫[`filename_filter()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.c#L204)在目录中的每个条目上.要确定是否应忽略文件,`filename_filter()`叫`fnmatch()`在全球的每个条目`char *ignore_patterns[]`.这个设置有几个问题:

1.  `scandir()`没让我通过任何有用的状态`filename_filter()`.过滤器只能根据它做出决定`dirent`和任何全局变量.
2.  `ignore_patterns`只是一个字符串数组.它无法跟踪子目录中忽略文件的层次结构.这使得一些忽略条目行为不正确(问题#43).这也损害了性能.

修复这些问题需要重新调整一些事情.第一,[I wrote my own `scandir()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/scandir.c#L7).最重要的区别是我的版本允许您传递指向过滤器功能的指针.这个指针可以说是一个包含忽略模式层次结构的结构.

令人惊讶的是,我接下来要做的就是make[a struct for ignore patterns](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.h#L11):

```c
struct ignores {
    char **names; /* Non-regex ignore lines. Sorted so we can binary search them. */
    size_t names_len;
    char **regexes; /* For patterns that need fnmatch */
    size_t regexes_len;
    struct ignores *parent;
};
```

这是一种不寻常的结构.父母没有指示他们的孩子,但他们不需要.我只是分配ignore结构,搜索目录,然后释放结构.这是在周围完成的[line 340 of search.c](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/search.c#L341).搜索是递归的,所以孩子们在父母面前被释放.

最后的改变是[rewrite `filename_filter()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.c#L204).它叫`fnmatch()`在传递给它的ignore结构中的每个条目上.如果这些都不匹配`ig->parent`不`NULL`,它使用父忽略结构重复该过程,等等直到它到达顶部.

总而言之,不是一个糟糕的变革集.我解决了很多我想要修复一段时间的事情.我还设法清理了相当多的代码.如果不是我的重新执行`scandir()`,pull请求会删除比添加的更多的行.

最后一件事:我想赞美一件软件并批评另一件软件.我小心翼翼地说[Instruments.app](http://developer.apple.com/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html).我发现它对于找到许多内存泄漏和性能问题的原因非常有用.但是我对git摇了摇头.Git允许`.gitignore`任何目录中的文件,它允许这些文件包含正则表达式.更糟糕的是,这些正则表达式可以引用子目录.例如,`foo/*/bar`是一种有效的忽略模式.正则表达式加上目录层次结构转换为复杂的实现和用户的混乱行为.任何参与者都没有乐趣.

* * *

[← S3 Logging and Analytics](http:Geoff.Greer.fm/2012/08/28/s3-logging-and-analytics/) [ →The Silver Searcher: Adding Pthreads](http:Geoff.Greer.fm/2012/09/07/the-silver-searcher-adding-pthreads/)

* * *

评论时,请记住:这是真的吗?有必要吗?好吗?

* * *
