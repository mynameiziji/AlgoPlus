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
        # 将行情放入共享队列
        for md_queue in self.md_queue_list:
            md_queue.put(pDepthMarketData.to_dict_raw())
