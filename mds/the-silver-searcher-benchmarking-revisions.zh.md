Geoff Greer网站:银色搜索者:标杆修订

[The Silver Searcher: Benchmarking Revisions](http:Geoff.Greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)

* * *

25八月2012

我对版本的性能感到好奇.[Ag](https://github.com/ggreer/the_silver_searcher)随着时间的推移,我写了一个脚本来标示从一月到现在的每一次修订.

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

这个脚本在每个版本上运行三个基准测试:区分大小写的字符串匹配、正则表达式匹配和不区分大小写的字符串匹配.结果使我吃惊.

悬停在线条和注释上,了解每个修订的更多信息.零值是由于错误的行为或失败的构建造成的.对于像AG这样的个人项目,我不会花太多的精力来确保师父总是可以部署.当然,标签发布是另一回事.

随着时间的推移绘制性能使得回归明显.一个改变使基准在执行时间上翻倍,从2秒提高到4秒.(相比之下,GRIP-R需要11秒,吐出大量无用的火柴.ACK需要20秒.

首先引起我注意的是标记为B的钉子.我发现我所有的努力工作提高性能都被一个承诺抵消了:[13f1ab69](https://github.com/ggreer/the_silver_searcher/commit/13f1ab693ca056698a370c65b8d139faed782261). 这个提交称为`fnmatch()`是以前版本的两倍.超过50%的执行时间已经花费在`fnmatch()`所以真的很伤性能.D点的下降是因为我放弃了改变,直到我能写出一些不会减慢速度的东西.

看看其他具体的变化,我也可以看到[43886f9b](https://github.com/ggreer/the_silver_searcher/commit/43886f9b08d0772b54f21a291a0794d060f700f7)(注释C)改进字符串匹配性能30%.这不是故意的.我正在清理一些代码并修正了一个错误,这对性能有轻微的影响.它肯定不会造成30%的差异.在Git指责之后,我发现了提交问题的提交:[01ce38f7](https://github.com/ggreer/the_silver_searcher/commit/01ce38f7f578b6b6141385688ff3c068390635df)(注释A).这是一个相当隐秘的性能回归.它是由我的大脑在Python中混合Python和C.`3 or 1`是`3`. 在C中,`3 || 1`评估为`1`. 使用`f_len - 1 || 1`填满`skip_lookup`1的数组,导致`boyer_moore_strnstr()`只跳过1个字符而不是`f_len - 1`字符.

这个错误减少了一半的性能,我三天前就把它修好了.再一次,我被愚笨的计算机所羞辱.从好的方面来看,现在我会很快注意到绩效回归.

更新:我已经创建了一个页面[more detailed graphs for all releases](http:Geoff.Greer.fm/ag/speed/).

* * *

[← Character encoding bugs are 𝒜wesome!](http:Geoff.Greer.fm/2012/08/12/character-encoding-bugs-are-%F0%9D%92%9Cwesome/) [ →S3 Logging and Analytics](http:Geoff.Greer.fm/2012/08/28/s3-logging-and-analytics/)

* * *

评论时,请记住:这是真的吗?有必要吗?这样好吗?

* * *
