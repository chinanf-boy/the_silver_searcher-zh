 Geoff Greer's site: Profiling with Gprof                //<!\[CDATA\[ var \_gaq = \_gaq || \[\]; var main\_css; var code\_css; var invert\_text = \[\]; var styles = { light: \["Light", "#fff", "/styles/main-light.css", "/styles/solarized-light.css", "Go dark."\], dark: \["Dark", "#000", "/styles/main-dark.css", "/styles/solarized-dark.css", "Brighten my day."\] }; function set\_style(style) { var date = new Date(); \_gaq.push(\["\_setCustomVar", 1, "Color", style\[0\], 1\]); document.body.style.backgroundColor = style\[1\]; main\_css.attributes.href.value = style\[2\]; code\_css.attributes.href.value = style\[3\]; invert\_text.forEach(function (elem) { elem.textContent = style\[4\]; }); date.setTime(date.getTime() + 30 \* 24 \* 60 \* 60 \* 1000); document.cookie = "main-css=" + main\_css.attributes.href.value + "; expires=" + date.toGMTString() + "; path=/"; return style; } function invert\_colors() { var style = main\_css.attributes.href.value === "/styles/main-light.css" ? set\_style(styles.dark) : set\_style(styles.light); \_gaq.push(\["\_trackEvent", "Color", "Set style", style\[0\]\]); } document.addEventListener("DOMContentLoaded", function () { code\_css = document.getElementById("code-css"); invert\_text = document.querySelectorAll(".invert-colors"); main\_css = document.getElementById("main-css"); if (window.location.hash.slice(1) === "dark") { set\_style(styles.dark); return; } if (window.location.hash.slice(1) === "light") { set\_style(styles.light); return; } document.cookie.split("; ").forEach(function (cookie) { cookie = cookie.split("="); if (cookie\[0\] === "main-css" && cookie\[1\] === "/styles/main-dark.css") { set\_style(styles.dark); } }); }); //\]\]> 

Go dark.

[Geoff.Greer.fm](/)

[Projects](/projects/)

[Ag](/ag/) · [FSEvents](/fsevents/) · [TLS config](/ciphersuite/) · [LS\_COLORS](/lscolors/)

[Photos](/photos/)

[About Me](/about/)

[Profiling with Gprof](/2012/02/08/profiling-with-gprof/)

* * *

08 Feb 2012

[I said I’d post about gprof](/2012/01/23/making-programs-faster-profiling/), so here goes.

Valgrind and gprof are two very different tools. Valgrind is an [instrumenting profiler](http://en.wikipedia.org/wiki/Profiling_%28computer_programming%29#Instrumenting_profilers). Gprof is a [sampling profiler](http://en.wikipedia.org/wiki/Profiling_%28computer_programming%29#Statistical_profilers). Gprof spends most of its time doing nothing. Then every 100,000,000 clock cycles or so, it looks at the [instruction pointer](http://en.wikipedia.org/wiki/Program_counter) to see what function your program is in. It collects that data enough times to end up with a good idea of where your program is spending its time. The advantage of this approach is that your program runs almost at full speed. This gives you a better idea of how much time your program spends waiting for things like disk or network I/O.

My typical profiling experience with gprof looks like this:

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

Some caveats: for gprof to work, you need to add -pg to your CFLAGS. Also, [gprof is broken on OS X](http://lists.apple.com/archives/PerfOptimization-dev/2006/Apr/msg00014.html), so run it on a linux server. If you want a sampling profiler on OS X, I recommend Instruments.app.

* * *

[← My Twisted Hack Day Project: Why is the Reactor Pausing?](/2012/02/04/my-twisted-hack-day-project-why-is-the-reactor-pausing/) [ →From Wordpress to Jekyll](/2012/02/21/from-wordpress-to-jekyll/)

* * *

When commenting, remember: Is it true? Is it necessary? Is it kind?

/\* \* \* CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE \* \* \*/ var disqus\_shortname = 'ggreer'; // required: replace example with your forum shortname /\* \* \* DON'T EDIT BELOW THIS LINE \* \* \*/ (function() { var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true; dsq.src = '//' + disqus\_shortname + '.disqus.com/embed.js'; (document.getElementsByTagName('head')\[0\] || document.getElementsByTagName('body')\[0\]).appendChild(dsq); })();

* * *

Go dark.

\_gaq.push(\['\_setAccount', 'UA-16016300-1'\]); \_gaq.push(\['\_trackPageview'\]); (function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')\[0\]; s.parentNode.insertBefore(ga, s); })();