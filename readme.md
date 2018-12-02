# ggreer/the_silver_searcher [![explain]][source] [![translate-svg]][translate-list]

<!-- [![size-img]][size] -->

[explain]: http://llever.com/explain.svg
[source]: https://github.com/chinanf-boy/Source-Explain
[translate-svg]: http://llever.com/translate.svg
[translate-list]: https://github.com/chinanf-boy/chinese-translate-list
[size-img]: https://packagephobia.now.sh/badge?p=Name
[size]: https://packagephobia.now.sh/result?p=Name

「 desc 」

[中文](./readme.md) | [english](https://github.com/ggreer/the_silver_searcher)

---

## 校对 🀄️

<!-- doc-templite START generated -->
<!-- repo = 'ggreer/the_silver_searcher' -->
<!-- commit = '1b06a9fd8d9ad0aaf235b4a752e605dfd4bb7ced' -->
<!-- time = '2018-11-27' -->

| 翻译的原文 | 与日期        | 最新更新 | 更多                       |
| ---------- | ------------- | -------- | -------------------------- |
| [commit]   | ⏰ 2018-11-27 | ![last]  | [中文翻译][translate-list] |

[last]: https://img.shields.io/github/last-commit/ggreer/the_silver_searcher.svg
[commit]: https://github.com/ggreer/the_silver_searcher/tree/1b06a9fd8d9ad0aaf235b4a752e605dfd4bb7ced

<!-- doc-templite END generated -->

### 贡献

欢迎 👏 勘误/校对/更新贡献 😊 [具体贡献请看](https://github.com/chinanf-boy/chinese-translate-list#贡献)

## 生活

[help me live , live need money 💰](https://github.com/chinanf-boy/live-need-money)

---

### 目录

<!-- START doctoc -->
<!-- END doctoc -->

# 银色搜索者(The Silver Searcher)

类似`ack`的代码搜索工具,专注于速度.

[![Build Status](https://travis-ci.org/ggreer/the_silver_searcher.svg?branch=master)](https://travis-ci.org/ggreer/the_silver_searcher)

[![Floobits Status](https://floobits.com/ggreer/ag.svg)](https://floobits.com/ggreer/ag/redirect)

[![#ag on Freenode](https://img.shields.io/badge/Freenode-%23ag-brightgreen.svg)](https://webchat.freenode.net/?channels=ag)

你知道 C 吗?想改善 ag?[我邀请你和我配对](http://geoff.greer.fm/2014/10/13/help-me-get-to-ag-10/).

## Ag 的优点是什么?

- 它比一个快一个数量级`ack`.
- 它忽略了你的文件模式`.gitignore`和`.hgignore`.
- 如果源仓库中有文件您不想搜索,只需将其模式添加到 a`.ignore`文件.(\*咳嗽\* `*.min.js` \*咳嗽\*)
- 命令名称缩短了 33%`ack`,所有钥匙都在主页上!

Ag 现在相当稳定.大多数更改都是新功能,小错误修复或性能改进.在我的基准测试中它比 Ack 快得多:

```
ack test_blah ~/code/  104.66s user 4.82s system 99% cpu 1:50.03 total

ag test_blah ~/code/  4.67s user 4.58s system 286% cpu 3.227 total
```

Ack 和 Ag 发现了相同的结果,但 Ag 的速度提高了 34 倍(3.2 秒对 110 秒).我的`~/code`目录大约是 8GB.感谢 git / hg / ignore,Ag 只搜索了 700MB.

还有[各版本的性能图表](http://geoff.greer.fm/ag/speed/).

## 怎么这么快?

- Ag 使用[并行线程](https://en.wikipedia.org/wiki/POSIX_Threads)利用多个 CPU 核心并并行搜索文件.
- 文件是`mmap()`而不是读入缓冲区.
- 文字字符串搜索使用[Boyer-Moore strstr](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string_search_algorithm).
- 正则表达式搜索使用[PCRE 的 JIT 编译器](http://sljit.sourceforge.net/pcre.html)(如果 Ag 是用 PCRE> = 8.21 构建的).
- 银电话`pcre_study()`在每个文件上执行相同的正则表达式之前.
- 而不是打电话`fnmatch()`在忽略文件中的每个模式上,非正则表达式模式被加载到数组中并进行二进制搜索.

我写了几篇博文,展示了我如何提高性能.这些包括我[添加了 pthreads](http://geoff.greer.fm/2012/09/07/the-silver-searcher-adding-pthreads/),[写了我自己的`scandir()`](http://geoff.greer.fm/2012/09/03/profiling-ag-writing-my-own-scandir/),[对每个修订进行基准测试以找出性能回归](http://geoff.greer.fm/2012/08/25/the-silver-searcher-benchmarking-revisions/)和配置文件[gprof 的](http://geoff.greer.fm/2012/02/08/profiling-with-gprof/)和[Valgrind 的](http://geoff.greer.fm/2012/01/23/making-programs-faster-profiling/).

## 安装

### 苹果系统

```
brew install the_silver_searcher
```

要么

```
port install the_silver_searcher
```

### Linux 的

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

- Gentoo 的

  ```
    emerge -a sys-apps/the_silver_searcher
  ```

- 拱

  ```
    pacman -S the_silver_searcher
  ```

- Slackware 的

  ```
    sbopkg -i the_silver_searcher
  ```

- openSUSE 的:

  ```
    zypper install the_silver_searcher
  ```

- CentOS 的:

  ```
    yum install the_silver_searcher
  ```

- SUSE Linux Enterprise:关注[这些简单的说明](https://software.opensuse.org/download.html?project=utilities&package=the_silver_searcher).

### BSD

- FreeBSD 的

  ```
    pkg install the_silver_searcher
  ```

- OpenBSD 系统/ NetBSD 的

  ```
    pkg_add the_silver_searcher
  ```

### 视窗

- 的 Win32 / 64

  非官方的日常构建是[可得到](https://github.com/k-takata/the_silver_searcher-win32).

- 巧克力味

  ```
    choco install ag
  ```

- MSYS2

  ```
    pacman -S mingw-w64-{i686,x86_64}-ag
  ```

- Cygwin 的

  运行相关的[`setup-*.exe`](https://cygwin.com/install.html),并选择"\_银\_搜索者"在"Utils"类别中.

## 从源头构建

### 建筑大师

1.  安装依赖项(Automake,pkg-config,PCRE,LZMA):

    - 苹果系统:

      ```
        brew install automake pkg-config pcre xz
      ```

      要么

      ```
        port install automake pkgconfig pcre xz
      ```

    - Ubuntu 的/ Debian 的:

      ```
        apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev
      ```

    - Fedora 的:

      ```
        yum -y install pkgconfig automake gcc zlib-devel pcre-devel xz-devel
      ```

    - CentOS 的:

      ```
        yum -y groupinstall "Development Tools"
        yum -y install pcre-devel xz-devel zlib-devel
      ```

    - openSUSE 的:

      ```
        zypper source-install --build-deps-only the_silver_searcher
      ```

    - Windows:这很复杂.看到[这个维基页面](https://github.com/ggreer/the_silver_searcher/wiki/Windows).

2.  运行构建脚本(只运行 aclocal,automake 等):

    ```
     ./build.sh
    ```

    在 Windows 上(在 msys / MinGW shell 中):

    ```
     make -f Makefile.w32
    ```

3.  安装:

    ```
    sudo make install
    ```

### 构建一个发布 tarball

可以使用 GPG 签名的版本[这里](http://geoff.greer.fm/ag).

构建发行版 tar 包需要相同的依赖项,但 automake 和 pkg-config 除外.一旦安装了依赖项,就运行:

```
./configure
make
make install
```

您可能需要使用`sudo`或以 root 身份运行 make install.

## 编辑器集成

### Vim

你可以使用 Ag[ack.vim](https://github.com/mileszs/ack.vim)将以下行添加到您的`.vimrc`:

```
let g:ackprg = 'ag --nogroup --nocolor --column'
```

要么:

```
let g:ackprg = 'ag --vimgrep'
```

哪个具有相同的效果,但会报告该线上的每个匹配.

### Emacs 的

您可以使用[ag.el][]作为 Ag 的 Emacs 前端.也可以看看:[掌舵股份公司-].

[ag.el]: https://github.com/Wilfred/ag.el
[helm-ag]: https://github.com/syohex/emacs-helm-ag

### TextMate 的

TextMate 用户可以使用 Ag[我的叉子](https://github.com/ggreer/AckMate)流行的 AckMate 插件,它允许您使用 Ack 和 Ag 进行搜索.如果您已经拥有 AckMate,您只想用 A 替换 Ack,移动或删除`"~/Library/Application Support/TextMate/PlugIns/AckMate.tmplugin/Contents/Resources/ackmate_ack"`并运行`ln -s /usr/local/bin/ag "~/Library/Application Support/TextMate/PlugIns/AckMate.tmplugin/Contents/Resources/ackmate_ack"`

## 你可能会喜欢的其他东西

- [确认](https://github.com/petdance/ack2)- 比 grep 更好.没有 Ack,Ag 就不存在了.
- [ack.vim](https://github.com/mileszs/ack.vim)
- [旺盛的 Ctags](http://ctags.sourceforge.net/)- 比 Ag 快,但它预先建立一个索引.好的*真*大代码库.
- [Git 的-的 grep](http://git-scm.com/docs/git-grep)- 和 Ag 一样快但只适用于 git repos.
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [袋](https://github.com/sampson-chen/sack)- 包裹 Ack 和 Ag 的实用程序.它消除了搜索和打开匹配文件的大量重复.
