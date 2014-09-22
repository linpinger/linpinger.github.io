## 日志

- **公告2:** 2014-04-10 : 以后就在[GitHub][]更新了，Autohotkey网站停止更新，[程序百度网盘下载点][pan_baidu]

- **公告1:** 若生成电子书提示错误，可以将错误截图，以及txt文件发到 <mailto:linpinger@gmail.com> 便于作者改进程序，多谢

- **成品:** [Txt2eBook][] | [Txt2eBook-java][] | [FoxRamOS][] | [FoxADBGUI][] | [FoxBook-AHK][] | [FoxBook-Java][] | [FoxBook-Android][] | [AnsiTxt2Mobi][pan_baidu] | [QiDianTxt2Mobi][pan_baidu] | [AnsiTxt2PDF.exe][pan_baidu] | [...][pan_baidu]

- **2014-09-22:** [txt2ebook-java][]: 发布Java-Swing版的txt2ebook，和之前的AHK版本用法类似，可以跨平台使用，只依赖JRE和kindlegen程序

- **2014-09-11:** [FoxBook-AHK][]: 合并搜索引擎搜索和zssq搜索到新搜索工具中，支持更多特殊搜索

- **2014-08-29:** [FoxBook-Android][]: 修改章节列表界面按钮显示，添加 SD卡数据库和内部存储数据库之间的切换及导入导出(默认使用SD卡上的数据库)

- **2014-08-28:** [FoxBook-Android][]: 调整弹出菜单顺序，添加搜索起点，并整理起点相关函数到site_qidian.java中

- **2014-08-25:** [FoxBook-Android][]: 修改打开数据库方式，修改为将整个数据库文件读入内存以加快速度(可设置取消)，添加txt转epub功能

- **2014-08-25:** [Txt2eBook][]: 添加: 封面图片的添加，没相应设备测试效果，应该有用，不行的话可能要在一个专门的页面中显示图片了，那样又要加一个网页和其他一些引用

- **2014-08-22:** [FoxBook-Java][] : 惊喜发布java-swing版，界面类似AHK版，共用FoxBook.db3，目前添加，搜索，更新，制作mobi/epub/txt功能都已具备，关键跨平台界面看起来还一样，哈哈

- **2014-07-28:** [FoxBook-AHK][] / [FoxBook-Android][]: 修改切换数据库功能，默认FoxBook.db3，可切换到SD卡跟目录下的其他db3文件 修改多线程更新所有，使用join等待所有线程完毕

- **2014-07-23:** [FoxBook-Android][]: 修正: 链接提取中的一个小问题

- **2014-07-21:** [FoxBook-AHK][] / [FoxBook-Android][]: 将比较新章节放入函数中，条理清晰些，修改tocHref函数中，过滤调包含javascript:的链接

- **2014-07-09:** [FoxBook-AHK][] / [FoxBook-Android][]: 添加: 快读(qreader)搜索，更新支持

- **2014-07-04:** [FoxBook-AHK][] / [FoxBook-Android][]: 添加: DelList中包含 起止=-5,5 功能，目的减小数据库大小

- **2014-06-06:** [FoxBook-AHK][] / [FoxBook-Android][]: 修正: zssq新增User-Agent验证造成的不能使用，在线查看的bug

- **2014-05-31:** [FoxBook-Android][]: 修正: zssq和qidian的顺序可能造成的空指针，以及获取数据库cell内容空指针问题

- **2014-05-30:** [FoxBook-Android][]: 修正: zhuishushenqi page url 地址转义造成的地址错误

- **2014-05-29:** [FoxBook-AHK][]: 删除: easou(该站更新太慢，错误太多)，将通用函数放到库中，整理多余代码

- **2014-05-22:** [FoxBook-Android][]: 添加: 自动更新，七牛可能是因为缓存问题，准备测试用github.io做更新服务器

- **2014-05-19:** [FoxBook-Android][]: 添加: 9线程多任务下载空白章节(当数量大于25时) 修正: 一些小问题

- **2014-05-15:** [FoxBook-AHK][]: 添加: 书架(biquge,paitxt,dajiadu)中最新章节菜单，避免目录页缓存问题 

- **2014-05-13:** [FoxBook-AHK][] / [FoxBook-Android][]: 添加easou在线预览，zhuishushenqi在线预览及下载，修正起点章节下载地址算法 Author N = 1 + bookid % 8

- **2014-05-04:** [FoxADBGUI][]: 添加: 移动菜单以及F2修改文件名的功能，都是调用mv命令

- **2014-05-02:** [FoxBook-AHK][]: 小修改

- **2014-04-30:** [Txt2eBook][]: 修正: 默认优先以文件名做书名，如果为数字，选一行为书名，若为空，为FoxBook

- **2014-04-21:** [FoxADBGUI][]: Android 通过 ADB 传输中文名文件的GUI，方便不能很好支持4.x系统的XP系统

- **2014-04-17:** [FoxBook-Android][]: 添加: 在搜索界面的菜单中添加快速搜索功能，以后可以加入更多搜索引擎

- **2014-04-13:** [FoxBook-Android][]: 添加生成txt功能，路径 /sdcard/fox.txt

- **2014-03-27:** [FoxBook-Android][]: 发布Android测试版，和FoxBook共用同一数据库文件，放在sdcard根目录

- **2014-03-12:** [FoxBook-AHK][]: 修正在wine下某些网站处理目录的bug

- **2014-03-09:** [FoxBook-AHK][]: 新增批量精简dellist功能,wine下生成epub不再两次生成，生成epub可能不符合规范，但实际应该影响不大

- **2014-03-09:** [Txt2eBook][]: 添加: 选择文件按钮，便于在无法拖动的场合选择文件,多谢atuo

- **2014-02-27:** [Txt2eBook][]: 修正: 提示行修正,多谢Andy Wu

- **2014-02-25:** [FoxBook-AHK][]: 新增书籍界面修改，添加搜索引擎搜索书籍功能(调用SearchEngine.exe)

- **2014-02-22:** [FoxBook-AHK][]: 巨大更新，支持任意小说网站的目录页与内容页，无需规则支持，默认开启gzip下载

- **2014-02-18:** [Txt2eBook][]: 修正: Mac下解析br标签错误，替换为br闭合标签,多谢Shawn Wu

<a href="#" onclick='$("#content").load("etc/foxchangelog2013.html")'>更早日志</a>


[foxbook-ahk]: https://github.com/linpinger/foxbook-ahk
[foxbook-java]: https://github.com/linpinger/foxbook-java
[foxbook-android]: https://github.com/linpinger/foxbook-android
[txt2ebook]: https://github.com/linpinger/txt2ebook
[txt2ebook-java]: https://github.com/linpinger/txt2ebook-java
[foxramos]: https://github.com/linpinger/foxramos
[foxadbgui]: https://github.com/linpinger/foxadbgui

[GitHub]: https://github.com/linpinger/ "所有项目"
[pan_baidu]: http://pan.baidu.com/s/1bnqxdjL "百度网盘共享"

