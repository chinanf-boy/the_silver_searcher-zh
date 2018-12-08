Geoff Greer 网站:银色搜索者: 基准修订

[The Silver Searcher: Benchmarking Revisions](http:Geoff.Greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)

---

2012 年 8 月 25

随着时间的推移，我对[Ag](https://github.com/ggreer/the_silver_searcher)各个版本的性能感到好奇，所以我写了一个脚本，从一月到现在的每一次修订的基准。

```bash
#!/bin/bash

function benchmark_rev() {
    REV=$1
    git checkout $REV &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Checkout of $REV failed!"
        exit 1
    fi
    ./build.sh &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Build of $REV failed!"
    fi

    # grep to filter out occasional debugging lines I printed out
    TIME1=`./ag --stats blahblahblah ~/code/ 2>&1 | grep seconds | tail -n 1 | awk '{print $1}'`
    TIME2=`./ag --stats blah.*blah ~/code/ 2>&1 | grep seconds | tail -n 1 | awk '{print $1}'`
    TIME3=`./ag --stats -i blahblahblah ~/code/ 2>&1 | grep seconds | tail -n 1 | awk '{print $1}'`
    echo "[\"$REV\", $TIME1, $TIME2, $TIME3],"
}

# 6a38fb74 is the first rev that supports --stats
REV_LIST=`git rev-list 6a38fb74..master`

for rev in $REV_LIST; do
    benchmark_rev $rev
done
```

这个脚本在每个版本上运行三个基准测试:区分大小写的字符串匹配、正则表达式匹配和不区分大小写的字符串匹配。结果使我吃惊。

悬停在线条和注释上，了解每个修订的更多信息。零值是由于错误的行为或失败的构建造成的。对于像 AG 这样的个人项目，我不会花太多的精力来确保 master 分支总是可以部署。当然,标签发布是另一回事。

随着时间的推移，绘制使得性能回退，很明显。一个改变就使基准在执行时间上翻倍，从 2 秒提高到 4 秒。(相比之下,GRIP-R 需要 11 秒,吐出大量无用的火柴。ACK 需要 20 秒。

首先引起我注意的是标记为 B 的钉子。我发现我所有的努力工作提高性能都被一个提交抵消了:[13f1ab69](https://github.com/ggreer/the_silver_searcher/commit/13f1ab693ca056698a370c65b8d139faed782261)。 这个提交称为`fnmatch()`是以前版本的两倍。超过 50%的执行时间已经花费在`fnmatch()`，所以真的很伤性能。D 点的下降是因为我放弃了改变，直到我能写出一些不会减慢速度的东西。

看看其他具体的变化,我也可以看到[43886f9b](https://github.com/ggreer/the_silver_searcher/commit/43886f9b08d0772b54f21a291a0794d060f700f7)(注释 C)改进字符串匹配性能 30%。这不是故意的。我正在清理一些代码并修正了一个错误,这对性能有轻微的影响。它肯定不会造成 30%的差异。在 指责 Git 之后,我发现了，提交了的问题:[01ce38f7](https://github.com/ggreer/the_silver_searcher/commit/01ce38f7f578b6b6141385688ff3c068390635df)(注释 A)。这是一个相当隐秘的性能退化。它是由于我的大脑混合 Python 和 C。在 Python 中`3 or 1`是`3`。 而在 C 中,`3 || 1`则为`1`。 使用`f_len - 1 || 1`填满`skip_lookup`的，总会是 1 的数组，导致`boyer_moore_strnstr()`只跳过 1 个字符，而不是`f_len - 1`字符.

这个错误减少了一半的性能，我三天前就把它修好了。再一次,我被愚笨的计算机所羞辱。好的方面就是，现在我会很快注意到叫性能的退化.

更新:我已经创建了一个页面[关于所有发布版本的更多细节的图](http:Geoff.Greer.fm/ag/speed/).

---
