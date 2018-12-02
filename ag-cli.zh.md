```
Usage: ag [FILE-TYPE] [选项] PATTERN [PATH]

  递归搜索PATH,中的PATTERN匹配。
  像grep或ack，但速度更快。

例子:
  ag -i foo /bar/

输出 选项:
     --ackmate            打印为 AckMate-parseable 解析格式

  -A --after [LINES]      匹配后, 打印的行数 (Default: 2)

  -B --before [LINES]     匹配前, 打印的行数 (Default: 2)

     --[no]break          在不同文件匹配项之间，打印 新行

                          (默认启用)

  -c --count              只 打印 每个文件匹配项的数量

                          (常用来知晓，匹配行数的不同)

     --[no]color          结果染色的打印  (默认启用)

     --color-line-number  行数，染色(Default: 1;33)

     --color-match        匹配结果数，染色 (Default: 30;43)

     --color-path         路径名，染色 path names (Default: 1;32)

     --column             结果行数字，打印 column numbers in results

     --[no]filename       文件名，打印 file names (Enabled unless searching a single file)

  -H --[no]heading        在每个有匹配项的文件之前，打印 文件名

                          (默认启用)

  -C --context [LINES]    在匹配前后，打印 行  (Default: 2)

     --[no]group          与 --[no]break --[no]heading 相似

  -g --filename-pattern PATTERN

                          打印 匹配 PATTERN 模式的文件名

  -l --files-with-matches 仅 打印 包括匹配项的文件名

                          (不 打印 匹配项)

  -L --files-without-matches

                          仅 打印 不包括匹配项的文件名

     --print-all-files    为所有文件打印标题，即便其没有匹配项

     --[no]numbers        打印 行数字. 默认为跟随查找路线上的行数

  -o --only-matching      只打印，匹配此参数的行

     --print-long-lines   可打印 匹配在很长字符串 (Default: >2k characters)

     --passthrough        跟着查找流向, 打印 所有行(不管有没有匹配)

     --silent             禁止所有日志消息，包括错误

     --stats              打印统计数据（扫描的文件，拍摄的时间等）

     --stats-only         打印统计数据，没有别的。

                          （与搜索单个文件时的--count相同）

     --vimgrep            打印结果像, vim的 :vimgrep / pattern/g 会

                          （报告线上的每个匹配）

  -0 --null --print0      用 null 分文件名（给'xargs -0'）



Search 选项:

  -a --all-types          搜索所有文件（不包括隐藏文件，或来自忽略文件的模式）

  -D --debug              可笑的调试（可能没用）

     --depth NUM          最多可搜索NUM个目录（默认值：25）

  -f --follow             按照符号链接

  -F --fixed-strings      别名为--literal，与grep兼容

  -G --file-search-regex  PATTERN限制搜索到匹配PATTERN的文件名

     --hidden             搜索隐藏文件（服从。*忽略文件）

  -i --ignore-case        不区分大小写

     --ignore PATTERN     忽略与PATTERN匹配的文件/目录(也允许使用文字文件/目录名称）

     --ignore-dir NAME    --ignore的别名，与ack的兼容性。

  -m --max-count NUM      NUM个匹配后，跳过文件的其余部分（默认值：10,000）

     --one-device         不要关注其他设备的链接。

  -p --path-to-ignore STRING

                          使用 STRING 路径的.ignore文件

  -Q --literal            不要将PATTERN，解析为正则表达式

  -s --case-sensitive     敏感(区分大小写)地匹配案例

  -S --smart-case         除非PATTERN包含大写，否则不区分大小写(默认启用）

     --search-binary      搜索二进制文件以查找匹配

  -t --all-text           搜索所有文本文件（不包括隐藏文件）

  -u --unrestricted       搜索所有文件（忽略.ignore，.gitignore等，搜索二进制文件和隐藏文件）

  -U --skip-vcs-ignores   忽略VCS忽略文件

                          （.gitignore，.hgignore;仍遵循.ignore）

  -v --invert-match

  -w --word-regexp        仅匹配，完全相同单词

  -W --width NUM          在NUM字符数后，缩短 match 的行

  -z --search-zip         查找压缩 (e.g., gzip) 文件中的内容

文件 类型:
搜索可以限于某些类型的文件. 例子:
  ag --html needle
  - 查找 后缀 .htm, .html, .shtml 或 .xhtml 的文件中的'needle'.

对要支持的文件类型列表，可以使用:
  ag --list-file-types

ag 源由 Geoff Greer 编写. 更多 信息 (与最新版本)
可在 http://geoff.greer.fm/ag 找到
```
