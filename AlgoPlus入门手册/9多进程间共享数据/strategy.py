# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

import time
from datetime import datetime, timedelta
from multiprocessing import Process, Queue
from AlgoPlus.CTP.TraderApi import TraderApi
from AlgoPlus.CTP.ApiStruct import *
from tick_engine import TickEngine


class TraderEngine(TraderApi):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):
        self.order_ref = 0  # 报单引用
        self.order_time = None  # 报单时间
        self.order_status = b""  # 订单状态
        self.Join()

    # 撤单
    def req_order_action(self, exchange_id, instrument_id, order_ref, order_sysid=''):
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
    def buy_open(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '0', '0')

    # 卖开仓
    def sell_open(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '1', '0')

    # 买平仓
    def buy_close(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        if exchange_id == b"SHFE" or exchange_id == b"INE":
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '0', '3')
        else:
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '0', '1')

    # 卖平仓
    def sell_close(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        if exchange_id == b"SHFE" or exchange_id == b"INE":
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '1', '3')
        else:
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, '1', '1')

    def OnRtnOrder(self, pOrder):
        self.order_status = pOrder.OrderStatus
        if pOrder.OrderStatus == b"a":
            status_msg = "未知状态！"
        elif pOrder.OrderStatus == b"0":
            if pOrder.Direction == b"0":
                if pOrder.CombOffsetFlag == b"0":
                    status_msg = "买开仓已全部成交！"
                else:
                    status_msg = "买平仓已全部成交！"
            else:
                if pOrder.CombOffsetFlag == b"0":
                    status_msg = "卖开仓已全部成交！"
                else:
                    status_msg = "卖平仓已全部成交！"
        elif pOrder.OrderStatus == b"1":
            status_msg = "部分成交！"
        elif pOrder.OrderStatus == b"3":
            status_msg = "未成交！"
        elif pOrder.OrderStatus == b"5":
            status_msg = "已撤！"
        else:
            status_msg = "其他！"

        self._write_log(f"{status_msg}=>{pOrder}")

    def Join(self):
        while True:
            if self.status == 0:
                last_md = None
                last_md_test = None
                while not self.md_queue.empty():
                    last_md = self.md_queue.get(block=False)
                    if last_md.InstrumentID == test_instrument_id:
                        last_md_test = last_md

                if last_md_test:
                    # ############################################################################# #
                    if self.order_ref == 0:
                        # 涨停买开仓
                        self.order_ref += 1
                        self.buy_open(test_exchange_id, test_instrument_id, last_md_test.BidPrice1, test_vol, self.order_ref)
                        self.order_time = datetime.now()
                        self._write_log(f"=>买开仓请求！")

                    if self.order_ref == 1 and self.order_status == b"3" and datetime.now() - self.order_time > timedelta(seconds=3):
                        self.order_status = b""
                        self.req_order_action(test_exchange_id, test_instrument_id, self.order_ref)
                        self._write_log(f"=>发出撤单请求！")

                    if self.order_ref == 1 and self.order_status == b"0":
                        self.order_ref += 1
                        self.order_status = b""
                        self.sell_close(test_exchange_id, test_instrument_id, last_md_test.BidPrice1, test_vol, self.order_ref)
                        self.order_time = datetime.now()
                        self._write_log(f"=>买开仓已全部成交，发出卖平仓请求！")

                    # ############################################################################# #
                    if self.order_ref == 1:
                        if self.order_status == b"5":
                            print("老爷，买开仓单超过3秒未成交，已撤销，这里的测试工作已经按照您的吩咐全部完成！")
                            break
                        elif datetime.now() - self.order_time > timedelta(seconds=3):
                            print("买开仓执行等待中！")
                    elif self.order_ref == 2:
                        if self.order_status == b"0":
                            print("老爷，卖平仓单已成交，这里的测试工作已经按照您的吩咐全部完成！")
                            break
                        elif datetime.now() - self.order_time > timedelta(seconds=3):
                            print("卖平仓执行等待中！")
            else:
                time.sleep(1)


# ############################################################################# #
# 请在这里填写需要测试的合约数据
# 警告：该例子只支持上期所品种平今仓测试
test_exchange_id = b'SHFE'  # 交易所
test_instrument_id = b'ag1912'  # 合约代码
test_vol = 1  # 报单手数

share_queue = Queue(maxsize=100)  # 共享队列

if __name__ == "__main__":
    import sys

    sys.path.append("..")
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow24']

    # 行情进程
    md_process = Process(target=TickEngine, args=(future_account.server_dict['MDServer']
                                                  , future_account.broker_id
                                                  , future_account.investor_id
                                                  , future_account.password
                                                  , future_account.app_id
                                                  , future_account.auth_code
                                                  , future_account.instrument_id_list
                                                  , [share_queue]
                                                  , future_account.md_page_dir)
                         )

    # 交易进程
    trader_process = Process(target=TraderEngine, args=(future_account.server_dict['TDServer']
                                                        , future_account.broker_id
                                                        , future_account.investor_id
                                                        , future_account.password
                                                        , future_account.app_id
                                                        , future_account.auth_code
                                                        , share_queue
                                                        , future_account.td_page_dir)
                             )

    md_process.start()
    trader_process.start()

    md_process.join()
    trader_process.join()
