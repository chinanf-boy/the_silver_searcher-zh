 Geoff Greer's site: The Silver Searcher: Adding Pthreads                //<!\[CDATA\[ var \_gaq = \_gaq || \[\]; var main\_css; var code\_css; var invert\_text = \[\]; var styles = { light: \["Light", "#fff", "/styles/main-light.css", "/styles/solarized-light.css", "Go dark."\], dark: \["Dark", "#000", "/styles/main-dark.css", "/styles/solarized-dark.css", "Brighten my day."\] }; function set\_style(style) { var date = new Date(); \_gaq.push(\["\_setCustomVar", 1, "Color", style\[0\], 1\]); document.body.style.backgroundColor = style\[1\]; main\_css.attributes.href.value = style\[2\]; code\_css.attributes.href.value = style\[3\]; invert\_text.forEach(function (elem) { elem.textContent = style\[4\]; }); date.setTime(date.getTime() + 30 \* 24 \* 60 \* 60 \* 1000); document.cookie = "main-css=" + main\_css.attributes.href.value + "; expires=" + date.toGMTString() + "; path=/"; return style; } function invert\_colors() { var style = main\_css.attributes.href.value === "/styles/main-light.css" ? set\_style(styles.dark) : set\_style(styles.light); \_gaq.push(\["\_trackEvent", "Color", "Set style", style\[0\]\]); } document.addEventListener("DOMContentLoaded", function () { code\_css = document.getElementById("code-css"); invert\_text = document.querySelectorAll(".invert-colors"); main\_css = document.getElementById("main-css"); if (window.location.hash.slice(1) === "dark") { set\_style(styles.dark); return; } if (window.location.hash.slice(1) === "light") { set\_style(styles.light); return; } document.cookie.split("; ").forEach(function (cookie) { cookie = cookie.split("="); if (cookie\[0\] === "main-css" && cookie\[1\] === "/styles/main-dark.css") { set\_style(styles.dark); } }); }); //\]\]> 

Go dark.

[Geoff.Greer.fm](/)

[Projects](/projects/)

[Ag](/ag/) · [FSEvents](/fsevents/) · [TLS config](/ciphersuite/) · [LS\_COLORS](/lscolors/)

[Photos](/photos/)

[About Me](/about/)

[The Silver Searcher: Adding Pthreads](/2012/09/07/the-silver-searcher-adding-pthreads/)

* * *

07 Sep 2012

In my quest to improve [Ag](https://github.com/ggreer/the_silver_searcher/)’s speed, I spent some time making it multi-threaded. This meant learning [Pthreads](http://en.wikipedia.org/wiki/POSIX_Threads).

Although the Pthreads API wasn’t too hard to pick up, other architectural decisions took more effort to get right. My first attempt at multithreaded search was rather naïve. The plan was simple: For each file, create a new thread, search the file, then exit the thread. It didn’t require a huge change in the code, but I wasn’t sure what kind of performance benefit I’d get. A typical run of Ag searches a lot of files, and spawning a thread for each file could incur some significant overhead. Still, I figured it was worth a shot. It wasn’t long before I had things working, but my initial results were discouraging:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  2.18s user 20.91s system 152% cpu 15.134 total
%
```

15 seconds. That’s 7x slower than non-threaded Ag! I broke out the profiler.

[![](/images/ag_profile_thread_per_file.png)](/images/ag_profile_thread_per_file.png)

Creating a new thread isn’t free. I knew there was overhead, but now I knew how much. Apparently, it’s not very efficient to search 60,000 files by creating and destroying 60,000 threads.

Next, I tried a different concurrency pattern: [Worker threads](http://en.wikipedia.org/wiki/Thread_pool_pattern). I changed `search_dir()` so that instead of calling `search_file()` on a path, it added paths to a work queue. At the same time, worker threads grabbed paths off the queue and called `search_file()` on them. I had to use a couple of [mutexes](http://en.wikipedia.org/wiki/Lock_%28computer_science%29) to avoid some race conditions, but it was surprisingly easy to get correct behavior.

Once I was ready, I re-ran my benchmark:

```text
% time ./ag blahblahblah ~/code
...
./ag blahblahblah ~/code  1.47s user 2.54s system 231% cpu 1.731 total
%
```

Much better, but it was only 0.3 seconds faster than non-threaded Ag. Searching files is [embarrassingly parallel](http://en.wikipedia.org/wiki/Embarrassingly_parallel). I expected more than a 15% performance improvement.

So I started tweaking things. Most changes didn’t help, but performance was significantly affected by the number of worker threads. I assumed 3-4 workers would be ideal, but I ran benchmarks with up to 32 threads just to make sure. I graphed the results. For comparison: non-threaded Ag takes 2.0 seconds on my MacBook Air and 2.2 seconds on my Ubuntu server.

There are a couple of takeaways from this graph.

First, OS X _sucks_ at this benchmark. With 16 workers, performance is pitiful. I had to remove the 32-worker results from the graph, as they made it hard to see the difference in performance with fewer threads. Searching with 32 workers took 8.5 seconds on OS X. That’s just shameful. On the other hand, the Linux kernel seems to get things right. Even with 32 workers, it took 2.2 seconds.

Again, I pulled out the profiler. With 32 workers, Ag looks like this on OS X:

[![](/images/ag_profile_os_x_32_threads.png)](/images/ag_profile_os_x_32_threads.png)

There’s definitely some silliness going on in the kernel.

Anyway, getting back to the graph up above: The second thing I learned was that the optimal number of worker threads doesn’t correlate with CPU cores. Even on a quad-core CPU, performance was best with two workers. I want to figure out why this is the case, but for now I’m simply going to accept it and tweak Ag for performance. My guess is that the bottleneck is no longer the CPU. The new limiting factor could be memory bandwidth or latency.

After tweaking the worker thread count, I think I’m getting pretty close to the maximum possible searching speed. Take a look at the current profiling info:

[![](/images/ag_profile_thread_workers.png)](/images/ag_profile_thread_workers.png)

There’s no obvious bottleneck. All the time is spent doing things that simply must be done: open files, read data, match, close files. Another indication that I can’t make things much faster is this:

```text
% time du -sh ~/code
5.8G	/Users/ggreer/code
du -sh ~/code  0.09s user 1.42s system 95% cpu 1.572 total
%
```

That’s right, my benchmark data set is 5.8 gigabytes. Ag doesn’t actually search through the whole 5.8 gigabytes in 1.4 seconds. The total amount of data searched is around 400MB. Still, I’m surprised Ag is faster than `du`.

It looks like this project is starting to wrap up. Now that I’ve maxed-out performance, most changes should be feature requests and bug fixes. That said, it’s been a fun journey. I learned a lot of things about a lot of things.

// Load the Visualization API and the piechart package. google.load('visualization', '1.0', {'packages':\['corechart'\]}); // Set a callback to run when the Google Visualization API is loaded. google.setOnLoadCallback(drawChart); // Callback that creates and populates a data table, // instantiates the pie chart, passes in the data and // draws it. function drawChart() { // Create the data table. var data = new google.visualization.DataTable(); data.addColumn("string", "Worker threads"); data.addColumn("number", "OS X 10.8, Core i7 3667U@2.0Ghz"); data.addColumn("number", "Ubuntu 12.04, Core 2 Duo E3200@3.2Ghz"); data.addRows(\[ \["1", 1.536, 1.419\], \["2", 1.392, 1.358\], \["3", 1.471, 1.848\], \["4", 1.767, 1.894\], \["8", 2.677, 2.025\], \["16", 4.713, 2.066\] \]); // Set chart options var options = { 'title':'Ag worker thread benchmark', 'fontSize': 20, 'backgroundColor': { 'fill': '#eef' }, 'chartArea': { 'left': '10%', 'width': '85%' }, 'legend': { 'position': 'top', 'textStyle': { 'fontSize': 14 } }, 'hAxis': { 'title': 'Worker threads' }, 'vAxis': { 'gridlines': { 'count': 6 }, 'minValue': 0, 'title': 'Seconds' }, 'colors': \[ '#43d', '#396' \], 'width': "100%", 'height': 500 }; // Instantiate and draw our chart, passing in some options. var chart = new google.visualization.ChartWrapper({ 'chartType': 'ColumnChart', 'containerId': 'chart\_div', 'options': options, 'dataTable': data }); chart.draw(); }

* * *

[← Profiling Ag. Writing My Own Scandir](/2012/09/03/profiling-ag-writing-my-own-scandir/) [ →A Responsible Product Sunset Pledge](/2012/09/19/a-responsible-product-sunset-pledge/)

* * *

When commenting, remember: Is it true? Is it necessary? Is it kind?

/\* \* \* CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE \* \* \*/ var disqus\_shortname = 'ggreer'; // required: replace example with your forum shortname /\* \* \* DON'T EDIT BELOW THIS LINE \* \* \*/ (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus\_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')\[0\] || document.getElementsByTagName('body')\[0\]).appendChild(dsq); })();

* * *

Go dark.

\_gaq.push(\['\_setAccount', 'UA-16016300-1'\]); \_gaq.push(\['\_trackPageview'\]); (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')\[0\]; s.parentNode.insertBefore(ga, s); })();