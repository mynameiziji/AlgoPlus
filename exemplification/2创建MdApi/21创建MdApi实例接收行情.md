# MdApi工作流程
第一步，用CreateFtdcMdApi创建CThostFtdcMdApi实例，例如_api。

第二步，创建CThostFtdcMdSpi实例，例如_spi，用RegisterSpi将_spi注册到_api中。

第三步，用RegisterFront将行情前置地址注册到_api中。

第四步，用Init()初始化_api，初始化的过程就是与服务建立连接的过程。

第五步，与服务器成功建立连接时，回调函数OnFrontConnect会收到通知，此时用ReqUserLogin登录账户。

第六步，账户登录成功时，回调函数OnRspUserLogin会收到通知，此时用SubscribeMarketData订阅行情，用SubscribeForQuoteRsp订阅询价。此后，MdApi就可以正常工作了。

第七步，MdApi正常工作时，交易者需要在回调函数OnRtnDepthMarketData/OnRtnForQuoteRsp会收到最新行情通知时进行数据处理或者分发。

第八步，MdApi的本质是个子线程，所以需要调用Join方法，让主线程等待，才能正常运行。如果遇到连接成功后立即触发OnFrontDisconnected，错误代码8193，就可能是没有调用Join方法。

![MdApi工作流程图](http://ctp.plus/uploads/article/20191002/ba07bd8947901b8b9c28d6ee1ce35fbf.png)

MdApi接口函数说明，请参考《[2.MdApi环境初始化与账户登录相关接口说明](http://ctp.plus/?/article/2)》

# tick_engine.py

1. 使用前请在exemplification目录下的account_info.py文件中配置账户参数。
请注意订阅列表中的合约是否仍为活跃的主力，否则订阅当前主力合约。
2. TickEngine继承自AlgoTrader.CTP的MdApi类，做了两点改变：

    - [ ] 在父类构造方法执行完成之后调用了Join方法。
    - [ ] 重写了父类的OnRtnDepthMarketData方法（父类该方法未做任何事情），将收到的行情打印出来。
    实际应用中，接到行情之后会进行数据处理、分发、保存等操作。

3. 第27行的tick_engine是从TickEngine类创建的实例。AlgoPlus已经对MdApi工作流程中的前六步进行了封装。
就是说，各位老爷们只需要关心如何在OnRtnDepthMarketData方法中处理、分发行情数据。

>“tick_engine创建之后如何实时订阅行情？” \
>“如何分发行情延迟最低？” \
>“如果保存行情效率最高？” \
>“怎么合成K线数据？” \
>“怎么计算指标？”
>……

什么？这风太大了，网线不好，看~不~见~啦~，喂，喂……

青山不改，绿水长流，咱们来日方长！