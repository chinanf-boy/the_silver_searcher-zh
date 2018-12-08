Geoff Greer 的网站:剖析 Ag.写我自己的 Scandir

[Profiling Ag. Writing My Own Scandir](http:Geoff.Greer.fm/2012/09/03/profiling-ag-writing-my-own-scandir/)

---

2012 年 9 月 3 日

虽然[我 基准了 Ag 的每个版本](http:Geoff.Greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)，我没有把它们全部描述出来。在查看上一篇文章中的图表后我描述了一些性能发生重大变化的修正版本.

[![](https://geoff.greer.fm/images/ag_profile_a87aa8f822d9029243423ef0725ec03ca347141b.png)](https://geoff.greer.fm/images/ag_profile_a87aa8f822d9029243423ef0725ec03ca347141b.png)这是一次 a87aa8f8 修订版;就在我[撤消 性能回退](https://github.com/ggreer/the_silver_searcher/commit/e344ca087099431c1bcf733b3ae28316f6932683)之前。您可以看到它花费了 80%的执行时间在`fnmatch()`身上。

[![](https://geoff.greer.fm/images/ag_profile_0.9.png)](https://geoff.greer.fm/images/ag_profile_0.9.png)这是 0.9 标记版本。速度要快得多,而且`fnmatch()`只花费大约一半的时间。

[![](https://geoff.greer.fm/images/ag_profile_ag_scandir.png)](https://geoff.greer.fm/images/ag_profile_ag_scandir.png)最后,这是合并[pull request #56](https://github.com/ggreer/the_silver_searcher/pull/56)后的运行。这修复了[issue #43](https://github.com/ggreer/the_silver_searcher/issues/43)，并且在许多情况下改进了性能。我为这个拉动请求感到自豪,因为它修复了很多问题。本文的其余部分解释了我为使一切按照我想要的方式工作，而做出的具体改变。

首先,我应该解释 Ag 的旧行为。在我合并拉取请求之前,Ag 会在在每个目录上调用[`scandir()`](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/scandir.3.html)。然后`scandir()`中，在目录中的每个条目都会执行[`filename_filter()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.c#L204)。要确定是否应忽略文件,`filename_filter()`又会为全局`char *ignore_patterns[]`变量的每个值执行一次`fnmatch()`。这些步骤思路有几个问题:

1.  `scandir()`没能让我，传递任何有用的状态给`filename_filter()`。过滤器只能根据`dirent`和一些全局变量，为自身作出决定。
2.  `ignore_patterns`只是一个字符串数组。它无法跟踪子目录中，忽略文件的层次结构。这使得一些忽略条目行为不正确(问题#43)。这也损害了性能。

修复这些问题需要重新调整一些事情。第一,[重写自己的 `scandir()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/scandir.c#L7)。最重要的区别是我的版本允许您传递指向过滤器功能的指针。这个指针可以说是一个包含忽略模式层次结构的结构。

令人惊讶的是,我接下来要做的就是做出[一个忽略模式的结构](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.h#L11):

```c
struct ignores {
    char **names; /* Non-regex ignore lines. Sorted so we can binary search them. */
    size_t names_len;
    char **regexes; /* For patterns that need fnmatch */
    size_t regexes_len;
    struct ignores *parent;
};
```

这是一种不寻常的结构。父母没有指示他们的孩子，但他们也并不需要。我只是分配 ignore 结构，搜索目录，然后释放结构。这是在[search.c 第 340 行](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/search.c#L341)周围完成的。搜索是递归的,所以孩子们在父母前就被释放.

最后的改变是[重写 `filename_filter()`](https://github.com/ggreer/the_silver_searcher/blob/3deff34b45fa7e41bb9d7219029d8126c201bda5/src/ignore.c#L204)。它会在传递给它的 ignore 结构中的每个条目上，调用`fnmatch()`。如果这些都不匹配和`ig->parent`不为`NULL`，它会使用父忽略结构，重复该过程，直到它到达顶部。

总而言之,不是一个糟糕的变革。我解决了很多我想要修复一段时间的事情。我还设法清理了相当多的代码。如果不是我的重新实现了`scandir()`, 提交请求可能会删除比添加更多的行。

最后一件事:我想赞美一件软件，并批评另一件软件.我小心翼翼地说[Instruments.app](http://developer.apple.com/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html)。我发现它对于找到许多内存泄漏和性能问题的原因非常有用。但是我对 git 摇了摇头。Git 允许`.gitignore`文件在任何目录中，它允许这些文件为正则表达式。更糟糕的是,这些正则表达式可以引用子目录。例如,`foo/*/bar`是一种有效的忽略模式。正则表达式加上目录层次结构，会转换为复杂的实现和混乱的用户行为。这让任何想参与的，变得没那么有趣。

---

[ →The Silver Searcher: Adding Pthreads](the-silver-searcher-adding-pthreads.zh.md)

---
