# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

import time
from AlgoPlus.CTP.TraderApi import TraderApi
from AlgoPlus.CTP.ApiStruct import *


class TraderEngine(TraderApi):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):

        self.order_ref = 0

        #
        self.Join()

    # 撤单
    def req_order_action(self, exchange_id, instrument_id, order_ref='', order_sysid=''):
        input_order_action_field = InputOrderActionField(
            BrokerID=self.broker_id,
            InvestorID=self.investor_id,
            UserID=self.investor_id,
            ExchangeID=exchange_id,
            ActionFlag="0",
            InstrumentID=instrument_id,
            FrontID=self.front_id,
            SessionID=self.session_id,
            OrderSysID=order_sysid,
            OrderRef=str(order_ref),
        )
        l_retVal = self.ReqOrderAction(input_order_action_field)

    # 报单
    def req_order_insert(self, exchange_id, instrument_id, order_price, order_vol, order_ref, direction, offset_flag):
        input_order_field = InputOrderField(
            BrokerID=self.broker_id,
            InvestorID=self.investor_id,
            ExchangeID=exchange_id,
            InstrumentID=instrument_id,
            UserID=self.investor_id,
            OrderPriceType="2",
            Direction=direction,
            CombOffsetFlag=offset_flag,
            CombHedgeFlag="1",
            LimitPrice=order_price,
            VolumeTotalOriginal=order_vol,
            TimeCondition="3",
            VolumeCondition="1",
            MinVolume=1,
            ContingentCondition="1",
            StopPrice=0,
            ForceCloseReason="0",
            IsAutoSuspend=0,
            OrderRef=str(order_ref),
        )
        l_retVal = self.ReqOrderInsert(input_order_field)

    # 买开仓
    def buy_open(self, exchange_ID, instrument_id, order_price, order_vol, order_ref):
        self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '0', '0')

    # 卖开仓
    def sell_open(self, exchange_ID, instrument_id, order_price, order_vol, order_ref):
        self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '1', '0')

    # 买平仓
    def buy_close(self, exchange_ID, instrument_id, order_price, order_vol, order_ref):
        if exchange_ID == "SHFE" or exchange_ID == "INE":
            self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '0', '3')
        else:
            self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '0', '1')

    # 卖平仓
    def sell_close(self, exchange_ID, instrument_id, order_price, order_vol, order_ref):
        if exchange_ID == "SHFE" or exchange_ID == "INE":
            self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '1', '3')
        else:
            self.req_order_insert(exchange_ID, instrument_id, order_price, order_vol, order_ref, '1', '1')

    # 成交通知
    def OnRtnTrade(self, pTrade):
        pass

    # # 录入报单回报
    def OnRspOrderInsert(self, pInputOrder, pRspInfo, nRequestID, bIsLast):
        pass

    # 订单状态通知
    def OnRtnOrder(self, pOrder):
        if pOrder.OrderStatus == b"0":
            if self.order_ref < 270:
                self.order_ref += 1
                self.buy_open(test_exchange_id, test_instrument_id, test_raise_limited, test_vol, self.order_ref)
            else:
                # ############################################################################# #
                print("老爷，这里的测试工作已经按照您的吩咐全部完成！")

    def Join(self):
        while True:
            if self.status == 0:
                # ############################################################################# #
                # 涨停买开仓
                if self.order_ref == 0:
                    self.order_ref += 1
                    self.buy_open(test_exchange_id, test_instrument_id, test_raise_limited, test_vol, self.order_ref)

            time.sleep(1)


# ############################################################################# #
# 请在这里填写需要测试的合约数据
# 警告：该例子只支持上期所品种平今仓测试
test_exchange_id = 'SHFE'  # 交易所
test_instrument_id = 'rb2001'  # 合约代码
test_raise_limited = 3616  # 涨停板
test_fall_limited = 3207  # 跌停板
test_vol = 1  # 报单手数

if __name__ == "__main__":
    import sys

    sys.path.append("..")
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow24']
    ctp_trader = TraderEngine(future_account.server_dict['TDServer']
                              , future_account.broker_id
                              , future_account.investor_id
                              , future_account.password
                              , future_account.app_id
                              , future_account.auth_code
                              , None
                              , future_account.td_page_dir)
