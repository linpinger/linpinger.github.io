
#### 大部分成品都放在 [GitHub][]  或  [百度网盘][pan_baidu]

*****

# 成品:

## 电子书相关:

[foxbook-lua]: https://github.com/linpinger/foxbook-lua
[foxbook-ahk]: https://github.com/linpinger/foxbook-ahk
[foxbook-java]: https://github.com/linpinger/foxbook-java
[foxbook-android]: https://github.com/linpinger/foxbook-android
[txt2ebook]: https://github.com/linpinger/txt2ebook
[txt2ebook-java]: https://github.com/linpinger/txt2ebook-java
[foxramos]: https://github.com/linpinger/foxramos

[GitHub]: https://github.com/linpinger/ "所有项目"
[pan_baidu]: https://pan.baidu.com/s/184nnEZdesT6MUo6lhRvoVA "百度网盘共享"

- **2015-11-02:** [Txt2eBook][] : AutoHotkey版: 将文本转换为mobi,epub,PDF格式

- **2015-01-30:** [txt2ebook-java][] : Java-swing版: 将文本转换为mobi,epub格式

- **2012-12-25:** [AnsiTxt2PDF][pan_baidu] : 将文本(ANSI编码)转换为PDF格式(6寸Kindle电子书)

- **2013-03-31:** [AnsiTxt2Mobi][pan_baidu] : 将文本(任意编码)转换为带目录(正则表达式)Mobi格式(Kindle电子书)

- **2011-08-26:** [QiDianTxt2Mobi][pan_baidu] : 将起点文本转换为Mobi格式，带目录(Kindle电子书)，新增NCX目录

- **2016-01-28:** [FoxBook-Lua][] : Lua版: 狐狸写的小说管理工具，功能: 命令行下快速下载

- **2016-01-28:** [FoxBook-AHK][] : AutoHotkey版: 狐狸写的小说管理工具，功能: 下载，查看，管理，转换(6寸PDF,mobi,epub,chm,umd,txt)

- **2016-01-22:** [FoxBook-java][] : Java-swing版: 狐狸写的小说管理工具，功能: 下载，查看，管理，转换(mobi,epub,umd,txt)

- **2016-02-15:** [FoxBook-Android][] : Android版: 狐狸写的小说管理工具 ，功能: 下载，查看，管理，转换umd,txt


## 系统相关:

- **2014-04-10:** [FoxRamOS][] : RamOS制作工具，内存XP系统(新增导航版，简化制作步骤为两步)

- **2012-10-16:** [FoxDriverBakTool][pan_baidu] : RamOS制作工具，内存XP系统(新增导航版，简化制作步骤为两步)


*****


# 衍生品、小东西、收集:

- **2012-05-18:** [imgsplit][FoxBook-AHK] : 添加了gifsplit的Freeimage.dll, 将大尺寸gif图片切割为小尺寸图片，并尽量不影响图片中文字

- **2011-09-15:** [FoxPDF][pan_baidu] : Delphi写的Dll(For AHK),生成6寸PDF,调用libhpdf.dll,避免AHK版不能生成linkAnnot的问题

- **2011-07-13:** [nod32\_Make\_offline.ahk](bin/tmp/nod32_Make_offline.ahk) : 制作Nod32离线包的辅助脚本

- **2011-03-17:** [Boot.ini.ahk](bin/tmp/Boot.ini.ahk) : 修改boot.ini的小脚本

- **2011-07-15:** [AHK\_Process\_Manager.ahk](bin/tmp/AHK_Process_Manager.ahk) : 例子:管理AHK脚本进程，使用WMI，依赖COM.ahk

- **2009-12-05:** [Fox\_AHKWebRecorder.ahk](bin/tmp/Fox_AHKWebRecorder.ahk) : 偶修改tank的IE元素探测工具，依赖COM.ahk

- **2010-09-08:** [PeekPassword.ahk](bin/tmp/PeekPassword.ahk) : XP下标准密码控件密码查看(就发了一个显示密码的消息,摘自论坛)


*****

## 常用库函数(Lib):

- [COM.ahk](bin/lib/COM.ahk) : [COM 标准库](http://www.autohotkey.com/forum/topic22923.html)　作者: Sean

- [FoxCHM\_Class.ahk](bin/lib/FoxCHM_Class.ahk) : 自写函数，生成CHM文件

- [FoxEpub\_Class.ahk](bin/lib/FoxEpub_Class.ahk) : 自写函数，生成epub,mobi文件

- [FoxNovel.ahk](bin/lib/FoxNovel.ahk) : 自写函数，适合L版，通用小说目录及正文处理

- [FoxPDF\_Class.ahk](bin/lib/FoxPDF_Class.ahk) : 自写函数，生成PDF文件

- [FoxUMD\_Class.ahk](bin/lib/FoxUMD_Class.ahk) : 自写函数，生成UMD文件

- [FreeImage.ahk](bin/lib/FreeImage.ahk) : 自己写的调用FreeImage.dll的函数库，勉强能用，还有一些没用到的没写

- [Gdip.ahk](bin/lib/Gdip.ahk) : [Gdi+函数库](http://www.autohotkey.com/forum/topic32238.html)(图形图像)　作者: tic，论坛上弄下来的，修改了一点错误的地方

- [General.ahk](bin/lib/General.ahk) : 自己写的常用函数(适用于:原版,L版)

- [GeneralA.ahk](bin/lib/GeneralA.ahk) : 自己写的常用函数(适用于:原版)

- [GeneralW.ahk](bin/lib/GeneralW.ahk) : 自己写的常用函数(适用于:L版)

- [Hash.ahk](bin/lib/Hash.ahk) : 获取文件或字串Hash值(SHA1,MD5,CRC)

- [HPDF.ahk](bin/lib/HPDF.ahk) : 操作生成PDF的库函数(适用于:原版,L版)

- [httpQuery.ahk](bin/lib/httpQuery.ahk) : 下载，获取网络文件的函数库

- [HttpQueryInfo.ahk](bin/lib/HttpQueryInfo.ahk) : 下载，获取网络文件信息的函数库

- [IE.ahk](bin/lib/IE.ahk) : 将com操作IE的一些常用功能弄成函数(适用于:原版)

- [json.ahk](bin/lib/json.ahk) : 论坛里找的处理json的函数

- [JSON\_Class.ahk](bin/lib/JSON_Class.ahk) : 论坛里找的处理json的函数

- [K3.ahk](bin/lib/K3.ahk) : 旧的处理mobi,pdf,umd电子书的函数集合(适用于:原版)

- [LV\_Colors\_Class.ahk](bin/lib/LV_Colors_Class.ahk) : 操作ListView中行及cell颜色的类(适用于:L版)

- [qidian.ahk](bin/lib/qidian.ahk) : 处理起点站的函数

- [qreader.ahk](bin/lib/qreader.ahk) : 处理快读的函数

- [socket\_class.ahk](bin/lib/socket_class.ahk) : 论坛里找的socket函数

- [SQLiteDB\_Class.ahk](bin/lib/SQLiteDB_Class.ahk) : 操作SQlite的类(适用于:L版)

- [tcp\_udp\_class.ahk](bin/lib/tcp_udp_class) : 论坛里找的socket函数

- [USBD.ahk](bin/lib/USBD.ahk) : 安全移除U盘盘符函数

- [XXL.ahk](bin/lib/XXL.ahk) : 将com操作IE的一些常用功能弄成函数(适用于:L版)


