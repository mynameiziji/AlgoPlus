# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

# 参考资料：
# 《程序化模型中常用的止损策略》https://7jia.com/1002.html
# 《AlgoPlus量化投资进阶手册(1)盈损风控管理》https://7jia.com/72002.html

from time import sleep, perf_counter as timer
from AlgoPlus.CTP.TraderApi import TraderApi
from AlgoPlus.CTP.ApiStruct import *


class ProfitLossManagerBase(TraderApi):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):

        self.md_dict = {}  # 行情字典
        self.order_ref = None  # 报单引用

        self.local_rtn_trade_list = []  # 成交通知列表
        self.last_rtn_trade_id = 0  # 已处理成交ID
        self.local_position_dict = {}  # {"InstrumentID": {"ActionNum": 0, "LongVolume": 0, "LongPositionList": [], "ShortVolume": 0, "ShortPositionList": []}}
        self.instrument_id_registered = []  # 所有持仓合约，包括已平

        self.order_action_num_dict = {}  # 撤单次数 # {"InstrumentID": 0}

        # 需要初始化的参数
        self.pl_parameter_dict = {}  # 止盈止损参数 # {"InstrumentID": {b"0": []}}

        # 初始化参数
        self.init_parameter()

        # # 延时计时开始
        # # 如果需要延时数据，请取消以下注释
        # self.start_time = 0 # 开始时间
        # self.anchor_time = 0# 锚点时间
        # # 计时器信息
        # self.timer_dict = {"FrontID": 0,
        #                    "SessionID": 0,
        #                    "OrderRef": b"",
        #                    "FunctionName": "",
        #                    "OrderStatus": b"",
        #                    "StartTime": 0.0,
        #                    "AnchorTime": 0.0,
        #                    "DeltaTime": 0.0,
        #                    }
        # self.csv_file = None # csv file对象
        # self.csv_writer = None# csv writer对象
        # # 延时计时开始

        self.Join()

    # ############################################################################# #
    def init_parameter(self):
        """
        初始化策略参数
        :return:
        """
        pass

    # ############################################################################# #
    def buy_open(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        """
        买开仓。与卖平仓为一组完成交易。
        """
        self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'0', b'0')

    def sell_close(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        """
        卖平仓。与买开仓为一组完整交易。
        SHFE与INE区分平今与平昨。
        这里只实现了平今。
        """
        if exchange_id == b'SHFE' or exchange_id == b'INE':
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'1', b'3')
        else:
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'1', b'1')

    def sell_open(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        """
        卖开仓。与买平仓为一组完成交易。
        """
        self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'1', b'0')

    def buy_close(self, exchange_id, instrument_id, order_price, order_vol, order_ref):
        """
        买平仓。与卖开仓为一组完整的交易。
        SHFE与INE区分平今与平昨。
        这里只实现了平今。
        """
        if exchange_id == b'SHFE' or exchange_id == b'INE':
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'0', b'3')
        else:
            self.req_order_insert(exchange_id, instrument_id, order_price, order_vol, order_ref, b'0', b'1')

    def req_order_insert(self, exchange_id, instrument_id, order_price, order_vol, order_ref, direction, offset_flag):
        """
        录入报单请求。将订单结构体参数传递给父类方法ReqOrderInsert执行。
        :param exchange_id:交易所ID。
        :param instrument_id:合约ID。
        :param order_price:报单价格。
        :param order_vol:报单手数。
        :param order_ref:报单引用，用来标识订单来源。
        :param direction:买卖方向。
        (‘买 : 0’,)
        (‘卖 : 1’,)
        :param offset_flag:开平标志，只有SHFE和INE区分平今、平昨。
        (‘开仓 : 0’,)
        (‘平仓 : 1’,)
        (‘强平 : 2’,)
        (‘平今 : 3’,)
        (‘平昨 : 4’,)
        (‘强减 : 5’,)
        (‘本地强平 : 6’,)
        :return:
        """
        input_order_field = InputOrderField(
            BrokerID=self.broker_id,
            InvestorID=self.investor_id,
            ExchangeID=exchange_id,
            InstrumentID=instrument_id,
            UserID=self.investor_id,
            OrderPriceType=b'2',
            Direction=direction,
            CombOffsetFlag=offset_flag,
            CombHedgeFlag=b'1',
            LimitPrice=order_price,
            VolumeTotalOriginal=order_vol,
            TimeCondition=b'3',
            VolumeCondition=b'1',
            MinVolume=1,
            ContingentCondition=b'1',
            StopPrice=0,
            ForceCloseReason=b'0',
            IsAutoSuspend=0,
            OrderRef=str(order_ref),
        )
        self.ReqOrderInsert(input_order_field)

    # def ReqOrderInsert(self, pInputOrder):
    #     """
    #     录入报单请求。已在父类封装。
    #     如果不需要记录延时数据，则无需在此实现。
    #     """
    #     super(SpreadTradingBase, self).ReqOrderInsert(pInputOrder)
    #     # 延时计时开始
    #     # 如果需要延时数据，请取消以下注释
    #     self.anchor_time = timer()
    #     self.timer_dict["OrderRef"] = pInputOrder.OrderRef
    #     self.timer_dict["FunctionName"] = "ReqOrderInsert"
    #     self.timer_dict["OrderStatus"] = b""
    #     self.timer_dict["StartTime"] = self.start_time
    #     self.timer_dict["AnchorTime"] = self.anchor_time
    #     self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
    #     self.csv_writer.writerow(self.timer_dict)
    #     self.csv_file.flush()
    #     # 延时计时结束

    # ############################################################################# #
    def OnRspOrderInsert(self, pInputOrder, pRspInfo, nRequestID, bIsLast):
        """
        录入撤单回报。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        :param pInputOrder: AlgoPlus.CTP.ApiStruct中InputOrderField的实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg
        :param nRequestID:
        :param bIsLast:
        :return:
        """
        if self.is_my_order(pInputOrder.OrderRef):
            if pRspInfo.ErrorID != 0:
                self.on_insert_fail(pInputOrder)
            self._write_log(f"{pRspInfo}=>{pInputOrder}")
            # # 延时计时开始
            # # 如果需要延时数据，请取消注释
            # # 不适宜在回调函数里做比较耗时的操作。
            # self.anchor_time = timer()
            # self.timer_dict["FunctionName"] = "OnRspOrderInsert"
            # self.timer_dict["OrderStatus"] = b""
            # self.timer_dict["AnchorTime"] = self.anchor_time
            # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
            # self.csv_writer.writerow(self.timer_dict)
            # self.csv_file.flush()
            # # 延时计时结束

    # ############################################################################# #
    def OnRtnOrder(self, pOrder):
        """
        当收到订单状态变化时，可以在本方法中获得通知。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        根据pOrder.OrderStatus的取值调用适应的交易算法。
        :param pOrder: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        OrderField的OrderStatus字段枚举值及含义：
        (‘全部成交 : 0’,)
        (‘部分成交还在队列中 : 1’,)
        (‘部分成交不在队列中 : 2’,)
        (‘未成交还在队列中 : 3’,)
        (‘未成交不在队列中 : 4’,)
        (‘撤单 : 5’,)
        (‘未知 : a’,)
        (‘尚未触发 : b’,)
        (‘已触发 : c’,)
        OrderField的OrderSubmitStatus字段枚举值及含义：
        (‘已经提交 : 0’,)
        (‘撤单已经提交 : 1’,)
        (‘修改已经提交 : 2’,)
        (‘已经接受 : 3’,)
        (‘报单已经被拒绝 : 4’,)
        (‘撤单已经被拒绝 : 5’,)
        (‘改单已经被拒绝 : 6’,)
        :return:
        """
        # # 延时计时开始
        # # 如果需要延时数据，请取消以下注释
        # # 不适宜在回调函数里做比较耗时的操作。
        # self.anchor_time = timer()
        # self.timer_dict["FunctionName"] = "OnRtnOrder"
        # self.timer_dict["OrderStatus"] = pOrder.OrderStatus
        # self.timer_dict["AnchorTime"] = self.anchor_time
        # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
        # self.csv_writer.writerow(self.timer_dict)
        # self.csv_file.flush()
        # # 延时计时结束
        if pOrder.OrderStatus == b"5":
            if pOrder.InstrumentID in self.action_num_dict.keys():
                self.action_num_dict[pOrder.InstrumentID] += 1
            else:
                self.action_num_dict[pOrder.InstrumentID] = 1

    # ############################################################################# #
    def OnRtnTrade(self, pTrade):
        """
        当报单成交时，可以在本方法中获得通知。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        TradeField包含成交价格，而OrderField则没有。
        如果不需要成交价格，可忽略该通知，使用OrderField。
        :param pTrade: AlgoPlus.CTP.ApiStruct中的TradeField实例。
        :return:
        """
        self.local_rtn_trade_list.append(pTrade.to_dict_raw())

    def process_rtn_trade(self):
        """
        从上次订单ID位置开始处理订单数据。
        :return:
        """
        last_rtn_trade_id = len(self.local_rtn_trade_list)
        for rtn_trade in self.local_rtn_trade_list[self.last_rtn_trade_id:last_rtn_trade_id]:
            if rtn_trade["InstrumentID"] not in self.instrument_id_registered:
                self.instrument_id_registered.append(rtn_trade["InstrumentID"])

            rtn_trade["IsLock"] = False
            rtn_trade["AnchorTime"] = timer()
            rtn_trade["StopProfitDict"] = {}
            rtn_trade["StopLossDict"] = {}
            if rtn_trade["InstrumentID"] not in self.local_position_dict.keys():
                self.local_position_dict[rtn_trade["InstrumentID"]] = {"LongVolume": 0, "LongPositionList": [], "ShortVolume": 0, "ShortPositionList": []}
            local_position_info = self.local_position_dict[rtn_trade["InstrumentID"]]

            # 开仓
            if rtn_trade["OffsetFlag"] == b'0':
                self.update_stop_price(rtn_trade)
                if rtn_trade["Direction"] == b'0':
                    local_position_info["LongVolume"] += rtn_trade["Volume"]
                    local_position_info["LongPositionList"].append(rtn_trade)
                elif rtn_trade["Direction"] == b'1':
                    local_position_info["ShortVolume"] += rtn_trade["Volume"]
                    local_position_info["ShortPositionList"].append(rtn_trade)
            elif rtn_trade["Direction"] == b'0':
                local_position_info["ShortVolume"] = max(local_position_info["ShortVolume"] - rtn_trade["Volume"], 0)

            elif rtn_trade["Direction"] == b'1':
                local_position_info["LongVolume"] = max(local_position_info["LongVolume"] - rtn_trade["Volume"], 0)

        self.last_rtn_trade_id = last_rtn_trade_id

    # ############################################################################# #
    def OnErrRtnOrderInsert(self, pInputOrder, pRspInfo):
        """
        订单错误通知。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        :param pInputOrder: AlgoPlus.CTP.ApiStruct中的InputOrderField实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg
        :return:
        """
        if self.is_my_order(pInputOrder.OrderRef):
            if pRspInfo.ErrorID != 0:
                self.on_order_insert_fail(pInputOrder)
            self._write_log(f"{pRspInfo}=>{pInputOrder}")
            # # 延时计时开始
            # # 如果需要延时数据，请取消注释
            # # 不适宜在回调函数里做比较耗时的操作。
            # self.anchor_time = timer()
            # self.timer_dict["FunctionName"] = "OnErrRtnOrderInsert"
            # self.timer_dict["OrderStatus"] = b""
            # self.timer_dict["AnchorTime"] = self.anchor_time
            # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
            # self.csv_writer.writerow(self.timer_dict)
            # self.csv_file.flush()
            # # 延时计时结束

    def on_order_insert_fail(self, pInputOrder):
        """
        报单失败处理逻辑。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        :param pInputOrder: AlgoPlus.CTP.ApiStruct中的InputOrderField实例。
        :return:
        """
        pass

    # ############################################################################# #
    def req_order_action(self, exchange_id, instrument_id, order_ref, order_sysid=''):
        """
        撤单请求。将撤单结构体参数传递给父类方法ReqOrderAction执行。
        :param exchange_id:交易所ID
        :param instrument_id:合约ID
        :param order_ref:报单引用，用来标识订单来源。根据该标识撤单。
        :param order_sysid:系统ID，当录入成功时，可在回报/通知中获取该字段。
        :return:
        """
        input_order_action_field = InputOrderActionField(
            BrokerID=self.broker_id,
            InvestorID=self.investor_id,
            UserID=self.investor_id,
            ExchangeID=exchange_id,
            ActionFlag=b'0',
            InstrumentID=instrument_id,
            FrontID=self.front_id,
            SessionID=self.session_id,
            OrderSysID=order_sysid,
            OrderRef=order_ref,
        )
        self.ReqOrderAction(input_order_action_field)

    # ############################################################################# #
    # # 延时计时开始
    # # 如果需要延时数据，请取消以下注释
    # def ReqOrderAction(self, pInputOrderAction):
    #     """
    #     录入撤单请求。已在父类封装。
    #     如果不需要记录延时数据，则无需在此实现。
    #     """
    #     super(SpreadTrading, self).ReqOrderAction(pInputOrderAction)
    #     self.anchor_time = timer()
    #     self.timer_dict["OrderRef"] = pInputOrderAction.OrderRef
    #     self.timer_dict["FunctionName"] = "ReqOrderAction"
    #     self.timer_dict["OrderStatus"] = b""
    #     self.timer_dict["StartTime"] = self.start_time
    #     self.timer_dict["AnchorTime"] = self.anchor_time
    #     self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
    #     self.csv_writer.writerow(self.timer_dict)
    #     self.csv_file.flush()
    #     # 延时计时结束

    # ############################################################################# #
    def OnRspOrderAction(self, pInputOrderAction, pRspInfo, nRequestID, bIsLast):
        """
        录入撤单回报。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        :param pInputOrderAction: AlgoPlus.CTP.ApiStruct中InputOrderActionField的实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg。
        :param nRequestID:
        :param bIsLast:
        :return:
        """
        if self.is_my_order(pInputOrderAction.OrderRef):
            if pRspInfo.ErrorID != 0:
                self.on_order_action_fail(pInputOrderAction)
            self._write_log(f"{pRspInfo}=>{pInputOrderAction}")
            # # 延时计时开始
            # # 如果需要延时数据，请取消注释
            # # 不适宜在回调函数里做比较耗时的操作。
            # self.anchor_time = timer()
            # self.timer_dict["FunctionName"] = "OnRspOrderAction"
            # self.timer_dict["OrderStatus"] = b""
            # self.timer_dict["AnchorTime"] = self.anchor_time
            # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
            # self.csv_writer.writerow(self.timer_dict)
            # self.csv_file.flush()
            # # 延时计时结束

    def on_order_action_fail(self, pInputOrderAction):
        """
        撤单失败处理逻辑。不适宜在回调函数里做比较耗时的操作。可参考OnRtnOrder的做法。
        :param pInputOrderAction: AlgoPlus.CTP.ApiStruct中InputOrderActionField的实例。
        :return:
        """
        pass

    # ############################################################################# #
    def get_stop_profit_price(self, instrument_id, direction):
        """
        获取默认报单价格。
        :param instrument_id: 合约
        :param direction: 持仓方向
        :return: 报单价格
        """
        return self.md_dict[instrument_id]["AskPrice1"] if direction == b"1" else self.md_dict[instrument_id]["BidPrice1"]

    def get_stop_loss_price(self, instrument_id, direction):
        """
        获取默认报单价格。
        :param instrument_id: 合约
        :param direction: 持仓方向
        :return: 报单价格
        """
        return self.md_dict[instrument_id]["AskPrice1"] if direction == b"1" else self.md_dict[instrument_id]["BidPrice1"]

    def get_default_price(self, instrument_id, direction):
        """
        获取默认报单价格。
        :param instrument_id: 合约
        :param direction: 持仓方向
        :return: 报单价格
        """
        return self.md_dict[instrument_id]["AskPrice1"] if direction == b"1" else self.md_dict[instrument_id]["BidPrice1"]

    def check_position(self):
        """
        检查所有持仓是否触发持仓阈值。
        """
        try:
            for instrument_id, position_info in self.local_position_dict.items():
                for long_position in position_info["LongPositionList"]:
                    if not long_position["IsLock"]:
                        trigger = False
                        order_price = None
                        for stop_profit in long_position["StopProfitDict"].values():
                            if self.md_dict[instrument_id]["LastPrice"] > stop_profit:
                                trigger = True
                                order_price = self.get_stop_profit_price(instrument_id, long_position["Direction"])
                                break

                        if not trigger:
                            for stop_loss in long_position["StopLossDict"].values():
                                if self.md_dict[instrument_id]["LastPrice"] < stop_loss:
                                    trigger = True
                                    order_price = self.get_stop_loss_price(instrument_id, long_position["Direction"])
                                    break

                        if trigger and order_price:
                            self.order_ref += 1
                            self.sell_close(long_position["ExchangeID"], instrument_id, order_price, long_position["Volume"], self.order_ref)
                            long_position["IsLock"] = True

                for short_position in position_info["ShortPositionList"]:
                    if not short_position["IsLock"]:
                        trigger = False
                        order_price = None
                        for stop_profit in short_position["StopProfitDict"].values():
                            if self.md_dict[instrument_id]["LastPrice"] < stop_profit:
                                trigger = True
                                order_price = self.get_stop_profit_price(instrument_id, short_position["Direction"])
                                break

                        if not trigger:
                            for stop_loss in short_position["StopLossDict"].values():
                                if self.md_dict[instrument_id]["LastPrice"] > stop_loss:
                                    trigger = True
                                    order_price = self.get_stop_loss_price(instrument_id, short_position["Direction"])
                                    break

                        if trigger and order_price:
                            self.order_ref += 1
                            self.buy_close(short_position["ExchangeID"], instrument_id, order_price, short_position["Volume"], self.order_ref)
                            short_position["IsLock"] = True
        except Exception as err:
            self._write_log(err)

    # ############################################################################# #
    def update_stop_price(self, position_info):
        """
        获取止盈止损阈值。止损类型参考https://7jia.com/1002.html
        :param position_info: 持仓信息
        :return:
        """
        for instrument_id, pl_dict in self.pl_parameter_dict.items():
            if isinstance(pl_dict, dict):
                for pl_type, delta in pl_dict.items():
                    # 固定止盈
                    sgn = 1 if position_info["Direction"] == b'0' else -1
                    if pl_type == b"0":
                        position_info["StopProfitDict"][b"0"] = position_info["Price"] + delta[0] * sgn
                    # 固定止损
                    elif pl_type == b"1":
                        position_info["StopLossDict"][b"1"] = position_info["Price"] - delta[0] * sgn

    # ############################################################################# #
    def Join(self):
        while True:
            if self.status == 0:
                self.process_rtn_trade()

                while not self.md_queue.empty():
                    last_md = self.md_queue.get(block=False)
                    self.md_dict[last_md["InstrumentID"]] = last_md

                self.check_position()
            else:
                sleep(1)
