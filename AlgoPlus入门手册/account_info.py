# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

import os

BASE_LOCATION = "."
MD_LOCATION = BASE_LOCATION + os.path.sep + "MarketData"
TD_LOCATION = BASE_LOCATION + os.path.sep + "TradingData"
SD_LOCATION = BASE_LOCATION + os.path.sep + "StrategyData"


class FutureAccountInfo:
    def __init__(self, broker_id, server_dict, reserve_server_dict, investor_id, password, app_id, auth_code, instrument_id_list, md_page_dir=MD_LOCATION, td_page_dir=TD_LOCATION):
        self.broker_id = broker_id  # 期货公司BrokerID
        self.server_dict = server_dict  # 登录的服务器地址
        self.reserve_server_dict = reserve_server_dict  # 备用服务器地址
        self.investor_id = investor_id  # 账户
        self.password = password  # 密码
        self.app_id = app_id  # 认证使用AppID
        self.auth_code = auth_code  # 认证使用授权码
        self.instrument_id_list = instrument_id_list  # 订阅合约列表[]
        self.md_page_dir = md_page_dir  # MdApi流文件存储地址，默认MD_LOCATION
        self.td_page_dir = td_page_dir  # TraderApi流文件存储地址，默认TD_LOCATION


my_future_account_info_dict = {
    # 交易时间测试
    'SimNow': FutureAccountInfo(
        broker_id='9999',  # 期货公司BrokerID
        # TDServer为交易服务器，MDServer为行情服务器。服务器地址格式为"ip:port。"
        server_dict={'TDServer': "180.168.146.187:10100", 'MDServer': '180.168.146.187:10110'},
        # 备用服务器地址
        reserve_server_dict={'电信1': {'TDServer': "180.168.146.187:10100", 'MDServer': '180.168.146.187:10110'},
                             '电信2': {'TDServer': "180.168.146.187:10101", 'MDServer': '180.168.146.187:10111'},

                             '其他1': {'TDServer': "180.168.146.187:10130", 'MDServer': '180.168.146.187:10131'},  # 7*24
                             '其他2': {'TDServer': "218.202.237.33:10102", 'MDServer': '218.202.237.33:10112'},  # 移动
                             },
        investor_id='',  # 账户
        password='',  # 密码
        app_id='simnow_client_test',  # 认证使用AppID
        auth_code='0000000000000000',  # 认证使用授权码
        # 订阅合约列表
        instrument_id_list=[b'rb2001', b'ni2001', b'ag1912', b'j2001', b'TA001'],
    ),

    # 非交易使用测试
    'SimNow24': FutureAccountInfo(
        broker_id='9999',  # 期货公司BrokerID
        # TDServer为交易服务器，MDServer为行情服务器。服务器地址格式为"ip:port。"
        server_dict={'TDServer': "180.168.146.187:10130", 'MDServer': '180.168.146.187:10131'},
        # 备用服务器地址
        reserve_server_dict={},
        investor_id='',  # 账户
        password='',  # 密码
        app_id='simnow_client_test',  # 认证使用AppID
        auth_code='0000000000000000',  # 认证使用授权码
        # 订阅合约列表
        instrument_id_list=[b'ni1912', b'ni2001'],
    ),

}
