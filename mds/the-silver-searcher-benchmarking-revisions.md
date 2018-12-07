Geoff Greer's site: The Silver Searcher: Benchmarking Revisions

[The Silver Searcher: Benchmarking Revisions](http:Geoff.Greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)

---

25 Aug 2012

I was curious about the performance of versions of [Ag](https://github.com/ggreer/the_silver_searcher) over time, so I wrote a script to benchmark every revision from January to present.

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

This script runs three benchmarks on each revision: Case-sensitive string matching, regular expression matching, and case-insensitive string matching. The results surprised me.

Hover over the lines and annotations for more information about each revision. Zero values are due to incorrect behavior or failed builds. For personal projects like Ag, I don’t spend much effort making sure master is always deployable. Tagged releases are another matter, of course.

Graphing the performance over time makes regressions obvious. One change made the benchmarks double in execution time, from 2 seconds to 4. (For comparison, grep -r takes 11 seconds and spits out tons of useless matches. Ack takes 20 seconds.)

The first thing that caught my eye was the spike labelled B. I found that all my hard work improving performance was negated by a single commit: [13f1ab69](https://github.com/ggreer/the_silver_searcher/commit/13f1ab693ca056698a370c65b8d139faed782261). This commit called `fnmatch()` twice as much as previous versions. Over 50% of execution time was already spent in `fnmatch()`, so it really hurt performance. The drop at D is from me backing-out the change until I can write something that doesn’t slow things down.

Looking at other specific changes, I can also see that [43886f9b](https://github.com/ggreer/the_silver_searcher/commit/43886f9b08d0772b54f21a291a0794d060f700f7) (annotation C) improved string-matching performance by 30%. This was not intended. I was cleaning up some code and fixed an off-by-one error that slightly impacted performance. It certainly wasn’t going to cause a 30% difference. After git-blaming, I found the commit that introduced the problem: [01ce38f7](https://github.com/ggreer/the_silver_searcher/commit/01ce38f7f578b6b6141385688ff3c068390635df) (annotation A). This was quite a stealthy performance regression. It was caused by my brain mixing up Python and C. In Python, `3 or 1` is `3`. In C, `3 || 1` evaluates to `1`. Using `f_len - 1 || 1` filled the `skip_lookup` array with 1’s, causing `boyer_moore_strnstr()` to only skip 1 character instead of up to `f_len - 1` characters.

This mistake cut performance in half, and I fixed it three days ago without intending to. Once again, I am humbled by the mindless computer. On the bright side, now I’ll quickly notice performance regressions.

Update: I’ve created a page with [more detailed graphs for all releases](http:Geoff.Greer.fm/ag/speed/).

---

[← Character encoding bugs are 𝒜wesome!](http:Geoff.Greer.fm/2012/08/12/character-encoding-bugs-are-%F0%9D%92%9Cwesome/) [ →S3 Logging and Analytics](http:Geoff.Greer.fm/2012/08/28/s3-logging-and-analytics/)

---

When commenting, remember: Is it true? Is it necessary? Is it kind?

---
