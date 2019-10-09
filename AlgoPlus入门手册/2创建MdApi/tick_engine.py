# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

from AlgoPlus.CTP.MdApi import MdApi


class TickEngine(MdApi):
    def __init__(self, md_server, broker_id, investor_id, password, app_id, auth_code
                 , instrument_id_list, md_queue_list=None
                 , page_dir='', using_udp=False, multicast=False):
        self.Join()

    # ///深度行情通知
    def OnRtnDepthMarketData(self, pDepthMarketData):
        print(pDepthMarketData)


if __name__ == '__main__':
    import sys
    sys.path.append("..")

    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow']
    tick_engine = TickEngine(future_account.server_dict['MDServer']
                             , future_account.broker_id
                             , future_account.investor_id
                             , future_account.password
                             , future_account.app_id
                             , future_account.auth_code
                             , future_account.instrument_id_list
                             , None
                             , future_account.md_page_dir)
