# 注册Simnow模拟账号

1、Simnow是上海期货交易所旗下技术公司维护的一套模拟交易系统，只需注册账号即可免费使用：http://www.simnow.com.cn/

2、在常用下载页面下载客户端，方便实时查看模拟交易情况：http://www.simnow.com.cn/static/softwareDownload.action

3、记录个人主页中的InvestrorID，以及产品与服务页面中的服务器地址。配置账户参数时需要使用这些信息。

另外，如果偶遇simnow官网无法登录的情况，在AlgoPlus公众号回复simnow，可获取服务器相关参数。

# 配置账户参数

**存放目录：**

    \AlgoPlus\exemplification\6报单（买卖开平）及回报\account_info.py

**说明：**

1、FutureAccountInfo类定义了期货账户的所有属性；

2、my_future_account_info_dict是所有账户类的字典。使用时根据键值获取对应账户类属性。

3、MdApi实例会生成DialogRsp.con、QueryRsp.con、TradingDay.con三个流文件，存储在MD_LOCATION目录中，默认是当前目录下的MarketData文件夹。TraderApi实例会生成DialogRsp.con、Private.con、Public.con、QueryRsp.con、TradingDay.con五个流文件，存储在TD_LOCATION目录中，默认是当前目录下的TradingData文件夹。

4、实盘账户参数可从期货公司获取。

5、关于看穿式监管认证，我们会未来给大家讲解。

6、范例配置的是Simnow模拟账户。在补充账户investor_id、密码password和服务器地址server_dict（交易时间选择电信1/电信2/其他2，非交易时间选择其他1。7*24服务器在注册3个交易日后才能使用。）之后，就可以进行下一步了。

7、账户参数还可以被存储为其他形式。如果大家感兴趣，我们未来会写一个用json文件保存账户参数的例子。