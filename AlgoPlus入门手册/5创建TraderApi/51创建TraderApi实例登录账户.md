# TraderApi工作流程
第一步，用CreateFtdcTraderApi创建CThostFtdcTraderApi实例，例如_api。

第二步，创建CThostFtdcTraderSpi实例，例如_spi，用RegisterSpi将_spi注册到_api中。

第三步，用SubscribePrivateTopic订阅私有流，用SubscribePublicTopic订阅公有流。

第四步，用RegisterFront将交易前置地址注册到_api中。

第五步，用Init()初始化_api，初始化的过程就是与服务建立连接的过程。

第六步，与服务器成功建立连接时，回调函数OnFrontConnect会收到通知，此时用ReqUserAuthMethod认证客户端。

第七步，客户端认证成功时，回调函数OnRspUserAuthMethod会收到通知，此时用ReqUserLogin登录账户。

第八步，账户登录成功，回调函数OnRspUserLogin会收到通知，此时标记状态。此后，TraderApi就可以正常工作了。

第九步，TraderApi正常工作时，交易者根据需要用Req开头的请求函数进行（买卖开平撤）报单及查询，对应的以On开头的回调函数会收到结果通知。

第十步，TraderApi的本质也是个子线程，所以也需要调用Join方法，让主线程等待，才能正常运行。

![TraderApi工作流程图](http://ctp.plus/uploads/article/20191002/b6cae00af43b68b78f6b72726c88f3c0.png)

TraderApi更多接口方法说明，请参考：

- 《 [TraderApi环境初始化与账户登录相关接口说明](http://ctp.plus/?/article/3) 》
- 《 [TraderApi基础交易接口说明](http://ctp.plus/?/article/4) 》
- 《 [TraderApi扩展交易接口说明](http://ctp.plus/?/article/5) 》
- 《 [TraderApi资金与持仓查询接口说明](http://ctp.plus/?/article/6) 》
- 《 [TraderApi保证金与手续费查询接口说明](http://ctp.plus/?/article/7) 》
- 《 [TraderApi期权交易接口说明](http://ctp.plus/?/article/8) 》
- 《 [TraderApi银行相关接口说明](http://ctp.plus/?/article/9) 》
- 《 [TraderApi合约信息查询接口说明](http://ctp.plus/?/article/10) 》
- 《 [TraderApi其他查询接口说明](http://ctp.plus/?/article/11) 》


# trader_engine.py

1. 使用前请在exemplification目录下的account_info.py文件中配置账户参数。
2. 第19行的trader_engine是TraderEngine类（继承自AlgoPlus的TraderApi类）的实例。AlgoPlus对TraderApi工作流程进行了封装。
各位老爷们只需要关心后续买卖撤查相关的操作就可以了。
