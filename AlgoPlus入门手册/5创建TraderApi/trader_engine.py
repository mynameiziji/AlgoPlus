# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

from AlgoPlus.CTP.TraderApi import TraderApi


class TraderEngine(TraderApi):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):
        self.Join()


if __name__ == "__main__":
    import sys

    sys.path.append("..")
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow']
    
    ctp_trader = TraderEngine(future_account.server_dict['TDServer']
                              , future_account.broker_id
                              , future_account.investor_id
                              , future_account.password
                              , future_account.app_id
                              , future_account.auth_code
                              , None
                              , future_account.td_page_dir)
