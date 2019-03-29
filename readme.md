# ggreer/the_silver_searcher [![explain]][source] [![translate-svg]][translate-list]

<!-- [![size-img]][size] -->

[explain]: http://llever.com/explain.svg
[source]: https://github.com/chinanf-boy/Source-Explain
[translate-svg]: http://llever.com/translate.svg
[translate-list]: https://github.com/chinanf-boy/chinese-translate-list
[size-img]: https://packagephobia.now.sh/badge?p=Name
[size]: https://packagephobia.now.sh/result?p=Name

「 类似`ack`的代码搜索工具,专注于速度. 」

[中文](./readme.md) | [english](https://github.com/ggreer/the_silver_searcher)

---

## 校对 ✅

<!-- doc-templite START generated -->
<!-- repo = 'ggreer/the_silver_searcher' -->
<!-- commit = '1b06a9fd8d9ad0aaf235b4a752e605dfd4bb7ced' -->
<!-- time = '2018-11-27' -->
翻译的原文 | 与日期 | 最新更新 | 更多
---|---|---|---
[commit] | ⏰ 2018-11-27 | ![last] | [中文翻译][translate-list]

[last]: https://img.shields.io/github/last-commit/ggreer/the_silver_searcher.svg
[commit]: https://github.com/ggreer/the_silver_searcher/tree/1b06a9fd8d9ad0aaf235b4a752e605dfd4bb7ced

<!-- doc-templite END generated -->

- [x] readme
- [x] [命令行工具参数](./ag-cli.zh.md)
- [x] [添加 pthreads](./mds/the-silver-searcher-adding-pthreads.zh.md)
- [x] [分析，让工具更快](./mds/making-programs-faster-profiling.zh.md)
- [x] [分析，并编写我的`scandir`](./mds/profiling-ag-writing-my-own-scandir.zh.md)
- [x] [使用 gprof 分析](./mds/profiling-with-gprof.zh.md)
- [x] [版本基准](./mds/the-silver-searcher-benchmarking-revisions.zh.md)

### 贡献

欢迎 👏 勘误/校对/更新贡献 😊 [具体贡献请看](https://github.com/chinanf-boy/chinese-translate-list#贡献)

## 生活

[If help, **buy** me coffee —— 营养跟不上了，给我来瓶营养快线吧! 💰](https://github.com/chinanf-boy/live-need-money)

---

# 银色搜索者(The Silver Searcher)

类似`ack`的代码搜索工具,专注于速度.

[![Build Status](https://travis-ci.org/ggreer/the_silver_searcher.svg?branch=master)](https://travis-ci.org/ggreer/the_silver_searcher)

[![Floobits Status](https://floobits.com/ggreer/ag.svg)](https://floobits.com/ggreer/ag/redirect)

[![#ag on Freenode](https://img.shields.io/badge/Freenode-%23ag-brightgreen.svg)](https://webchat.freenode.net/?channels=ag)

你知道 C 吗?想改善 ag?[我邀请你和我一起合作](http://geoff.greer.fm/2014/10/13/help-me-get-to-ag-10/).

## Ag 的优点是什么?

- 它比`ack`快一个数量级.
- 它忽略了你的文件，匹配`.gitignore`和`.hgignore`中模式.
- 如果源仓库中有文件您不想搜索,只需将其模式添加到一个`.ignore`文件.(咳哼 `*.min.js` 之类)
- 命令参数名称比`ack`缩短了 33%,所有关键都整齐摆在首排!

Ag 现在相当稳定。大多数更改都是新功能,小错误修复或性能改进。在我的基准测试中它比 Ack 快得多:

```
ack test_blah ~/code/  104.66s user 4.82s system 99% cpu 1:50.03 total

ag test_blah ~/code/  4.67s user 4.58s system 286% cpu 3.227 total
```

Ack 和 Ag 发现了相同的结果,但 Ag 的速度提高了 34 倍(3.2 秒对 110 秒)。我的`~/code`目录大约是 8GB。感谢 git/hg/ignore, Ag 只搜索了 700MB.

还有[各版本的性能图表](http://geoff.greer.fm/ag/speed/).

## 怎么这么快?

- Ag 使用[Pthreads-并行线程](https://en.wikipedia.org/wiki/POSIX_Threads)，利用多个 CPU 核心并行搜索文件.
- 文件是`mmap()`，而不是读入 buffer(缓冲区).
- 文字字符串搜索使用[Boyer-Moore strstr](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string_search_algorithm).
- 正则表达式搜索使用[PCRE 的 JIT 编译器](http://sljit.sourceforge.net/pcre.html)(如果 Ag 是用 PCRE >=8.21 构建的).
- Ag 在每个文件上执行相同的正则表达式之前，调用`pcre_study()`.
- 换成在忽略文件中的每个模式上，调用`fnmatch()`，而非正则表达式模式被加载到数组中，并进行二进制搜索.

我写了几篇博文,展示了我如何提高性能。这些包括我[添加了 pthreads](http://geoff.greer.fm/2012/09/07/the-silver-searcher-adding-pthreads/),[写了我自己的`scandir()`](http://geoff.greer.fm/2012/09/03/profiling-ag-writing-my-own-scandir/),[对每个修订版本进行基准测试，以辨识性能回退](http://geoff.greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)和[gprof ](http://geoff.greer.fm/2012/02/08/profiling-with-gprof/)和[Valgrind ](http://geoff.greer.fm/2012/01/23/making-programs-faster-profiling/)配置文件.

## 安装

### macOS

```
brew install the_silver_searcher
```

要么

```
port install the_silver_searcher
```

### Linux

- Ubuntu> = 13.10(Saucy)或 Debian> = 8(Jessie)

```
  apt-get install silversearcher-ag
```

- Fedora 21 及更低版本

```
  yum install the_silver_searcher
```

- Fedora 22+

```
  dnf install the_silver_searcher
```

- RHEL7 +

```
  yum install epel-release.noarch the_silver_searcher
```

- Gentoo

```
  emerge -a sys-apps/the_silver_searcher
```

- 拱

```
  pacman -S the_silver_searcher
```

- Slackware

```
  sbopkg -i the_silver_searcher
```

- openSUSE:

```
  zypper install the_silver_searcher
```

- CentOS:

```
  yum install the_silver_searcher
```

- SUSE Linux Enterprise: 请关注[这些简单的说明](https://software.opensuse.org/download.html?project=utilities&package=the_silver_searcher).

### BSD

- FreeBSD

```
  pkg install the_silver_searcher
```

- OpenBSD 系统/ NetBSD

```
  pkg_add the_silver_searcher
```

### Windows

- Win32/64

  非官方的日常构建是[可得到](https://github.com/k-takata/the_silver_searcher-win32).

- Chocolatey

```
  choco install ag
```

- MSYS2

```
  pacman -S mingw-w64-{i686,x86_64}-ag
```

- Cygwin

  运行相关的[`setup-*.exe`](https://cygwin.com/install.html),并选择"\_银\_搜索者"在"Utils"类别中.

## 从源头构建

### 构建主分支

1.  安装依赖项(Automake,pkg-config,PCRE,LZMA):

- macOS:

```
brew install automake pkg-config pcre xz
```

要么

```
port install automake pkgconfig pcre xz
```

- Ubuntu/ Debian:

```
apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
```

- Fedora:

```
yum -y install pkgconfig automake gcc zlib-devel pcre-devel xz-devel
```

- CentOS:

```
yum -y groupinstall "Development Tools"
yum -y install pcre-devel xz-devel zlib-devel
```

- openSUSE:

```
zypper source-install --build-deps-only the_silver_searcher
```

- Windows: 这很复杂。看到[这个维基页面](https://github.com/ggreer/the_silver_searcher/wiki/Windows).

2.  运行构建脚本(只运行 aclocal,automake 等):

```
./build.sh
```

在 Windows 上(在 msys/MinGW shell 中):

```
make -f Makefile.w32
```

3.  安装:

```
sudo make install
```

### 构建一个发布的压缩(二进制)文件

可以使用 GPG 签名的版本，在[这里](http://geoff.greer.fm/ag).

构建发行版 tar 包需要相同的依赖项,但 automake 和 pkg-config 除外。一旦安装了依赖项,就运行:

```
./configure
make
make install
```

您可能需要使用`sudo`或以 root 身份运行 make install.

## 编辑器集成

### Vim

你可以使用 Ag 的[ack.vim](https://github.com/mileszs/ack.vim)，将以下行添加到您的`.vimrc`:

```
let g:ackprg = 'ag --nogroup --nocolor --column'
```

要么:

```
let g:ackprg = 'ag --vimgrep'
```

哪个具有相同的效果,但会报告该代码行上的每个匹配.

### Emacs

您可以使用[ag.el]作为 Ag 的 Emacs 前端。也可以看看:[helm-ag].

[ag.el]: https://github.com/Wilfred/ag.el
[helm-ag]: https://github.com/syohex/emacs-helm-ag

### TextMate

TextMate 用户可以通过[我的叉子](https://github.com/ggreer/AckMate)-流行的 AckMate 插件使用 Ag，它允许您使用 Ack 和 Ag 进行搜索。如果您已经拥有 AckMate,您只想用 Ag 替换 Ack，移动或删除`"~/Library/Application Support/TextMate/PlugIns/AckMate.tmplugin/Contents/Resources/ackmate_ack"`，并运行`ln -s /usr/local/bin/ag "~/Library/Application Support/TextMate/PlugIns/AckMate.tmplugin/Contents/Resources/ackmate_ack"`

## 你可能会喜欢的其他东西

- [Ack](https://github.com/petdance/ack2)- 比 grep 更好.没有 Ack,Ag 就不存在了.
- [ack.vim](https://github.com/mileszs/ack.vim)
- [Exuberant Ctags](http://ctags.sourceforge.net/)- 比 Ag 快,但它预先建立一个索引。对*非常*大的代码库来说更好。
- [Git-grep](http://git-scm.com/docs/git-grep)- 和 Ag 一样快，但只适用于 git repos.
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [Sack](https://github.com/sampson-chen/sack)- 包裹 Ack 和 Ag 的实用程序。它消除了搜索和打开匹配文件的大量重复.
