### Hello World!
开源这件事就像表白。迟迟没有行动，可能有很多原因。是自己还不够优秀？是还没等到合适的契机？亦或是担心付出的爱得不到等价的回报？

终于，我们还是行动了。

在交易所的技术支持下，我们设计并开发了初代使用Python语言的交易框架。该框架的延时测试结果对我们的技术和努力给予了肯定。

一切都像是被安排好的，随后我们就接到了几个定制项目，分别踩了策略的坑、风控的坑、UI的坑、CS架构的坑、MMAP的坑，框架设计在一次又一次的迭代升级中被完善。

接着，朋友建议我们开源：先进的技术只有被更广泛的应用才能体现其价值！

开源之后我们能获得什么？自己用不好吗？如果付出不能得到对等的回报，岂不是徒为他人作嫁衣裳。我反复的问自己，踟蹰不前。

你为什么喜欢交易？需要理由吗？不需要吗？我听到了内心的声音，虽然我仍是一个没有能力以交易为生的交易者，但是我也必定要将交易进行到底。我有了选择，愿为交易作嫁！

多好的孩子呀，起个名字吧！

AlgoPlus!（美式发音请戳：[百度翻译](https://fanyi.baidu.com/?/#en/en/AlgoPlus)）

Hello World.



### 简介
忠实于CTP官方API特性、低延时、易使用是AlgoPlus的立身之本。

AlgoPlus从以下三个不同的维度实现低延时：
* 利用Cython技术释放了GIL；
* 同时支持接入多路行情源，降低轮询等待时间；
* 利用CTP的线程特性，以接口回调直接驱动策略运行，无需主事件引擎，真正实现去中心化。

关于低延时技术详细说明请参考<http://7jia.com/71008.html>

我们对AlgoPlus进行过严格的延时测试：上海电信300M宽带，**非交易时间**使用Simnow的7*24服务器以对价方式进行无逻辑报单（收到成交回报之后立即再次报单）测试，平均每秒可以完成105笔成交。
也就是说，AlgoPlus从发出委托到收到成交回报（这个过程是从本地发出，经过互联网，到达期货公司交易前置，再到交易所，完成撮合成交之后，发回期货公司交易前置，再经过互联网，最终回到客户本地），平均需要9.5毫秒（1s=1000ms）。
关于交易时间simnow常规服务器的测试数据，及其他延时测试参考结果，请参考<https://7jia.com/71006.html>。

![](./img/AlgoPlus秒内交易测试.jpg)

为了提高AlgoPlus的易用性，一方面我们力求所有的设计都忠实于CTP官方功能，只要理解CTP官方API的工作流程，就可能直接上手使用，无需学习额外的知识；另一方面，我们会制作系统化的教程，将大家在使用过程中踩坑的几率降到最低。



### 教程安排
制作关于量化投资的系统化、专业化、通用化教程，不限于文字形式，也将会是我们重要的工作之一。

对量化投资技术的推广是我们最终的追求，所以教程不会只局限在AlgoPlus框架内。我们希望其他商业/开源平台的用户也能够通过我们的工作获得帮助。我们会为此倍感荣幸！

#### 《CTP量化投资API手册》
本教程对CTP方法及相关参数进行了汇总归类，方便大家理解CTP的工作逻辑，也方便在需要时查阅。

1. 《CTP量化投资API手册(0)概述》 <http://7jia.com/70000.html>
2. 《CTP量化投资API手册(1)MdApi》 <http://7jia.com/70001.html>
3. 《CTP量化投资API手册(2)TraderApi初始化与登录》 <http://7jia.com/70002.html>
4. 《CTP量化投资API手册(3)TraderApi基础交易》 <http://7jia.com/70003.html>
5. 《CTP量化投资API手册(4)TraderApi扩展交易》 <http://7jia.com/70004.html>
6. 《CTP量化投资API手册(5)TraderApi查资金与持仓》 <http://7jia.com/70005.html>
7. 《CTP量化投资API手册(6)TraderApi查保证金与手续费》 <http://7jia.com/70006.html>
8. 《CTP量化投资API手册(7)TraderApi期权交易》 <http://7jia.com/70007.html>
9. 《CTP量化投资API手册(8)TraderApi银行相关》 <http://7jia.com/70008.html>
10. 《CTP量化投资API手册(9)TraderApi查合约》 <http://7jia.com/70009.html>
11. 《CTP量化投资API手册(10)TraderApi查其他》 <http://7jia.com/70010.html>
12. 《CTP量化投资API手册(11)错误信息》 <http://7jia.com/70011.html>

#### 《AlgoPlus入门手册》
本教程主要教大家如果使用AlgoPlus实现量化交易。

1. 准备工作
    * 安装Anaconda（<http://7jia.com/71001.html>）
    * 安装AlgoPlus（已完成）
    * 安装PyCharm（已完成）
    * 配置account_info（已完成）
    * Python基本语法
    * 线程与进程
2. 创建MdApi（<http://7jia.com/71004.html>）
3. 合成K线（<http://7jia.com/71004.html>）
4. 计算指标
5. 创建TraderApi（已完成）
6. 报单（买卖开平）及回报（已完成）
7. 撤单及回报（已完成）
8. 客户端认证（已完成）
9. 多进程间共享数据
    * Queue（已完成）
    * MMAP
10. 序列化
    * CSV（<http://7jia.com/71004.html>）
    * MySQL
    * hdf5
    * MMAP
11. 性能分析
    * 期货公司行情速度测评
    * 行情分发性能测评
    * 交易延迟测评（<http://7jia.com/71006.html>）
    * 序列化性能测评

#### 《AdvacedCookbook——即AlgoPlus进阶手册》
1. 价差交易模板（已完成）


### 开源地址
1. 码云：<https://gitee.com/AlgoPlus/>
2. GitHub：<https://github.com/CTPPlus/AlgoPlus>

### 参与贡献
@CTPPlus

### 版权说明
MIT

### QQ群与微信公众号
 * QQ群：**866469866**
 
![](./img/QQ群866469866.png)

 * 微信公众号：**AlgoPlus**
 
![](./img/微信公众号AlgoPlus.jpg)

欢迎发现我们，关注我们。
