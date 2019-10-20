# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

from time import sleep, perf_counter as timer
from AlgoPlus.CTP.TraderApi import TraderApi
from AlgoPlus.CTP.ApiStruct import *


class LocalOrderInfo(BaseField):
    _fields_ = [
        ('ExchangeID', c_char * 9),  # 交易所代码
        ('InstrumentID', c_char * 31),  # 合约代码
        ('OrderRef', c_char * 13),  # 报单引用
        ('Direction', c_char * 1),  # 买卖方向
        ('OffsetFlag', c_char * 5),  # 组合开平标志
        ('LimitPrice', c_double),  # 报单价格
        ('VolumeTotalOriginal', c_int),  # 数量
        ('VolumeTotal', c_int),  # 剩余数量
        ('OrderStatus', c_char * 1),  # 报单状态
        ('InputTime', c_float),  # 委托时间
    ]


class SpreadTradingBase(TraderApi):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):

        self.server_time = b'00:00:00'  # 服务器时间
        self.md_a = None  # A合约最新行情
        self.md_b = None  # B合约最新行情
        self.position_status = 0  # 策略方向
        self.sig_stage = 0  # 信号触发后，执行状态
        self.position_a = 0  # A合约持仓
        self.position_b = 0  # B合约持仓
        self.with_draw_num = 0  # 撤单次数
        self.local_order_dict = {}  # 所有报单本地信息字典

        self.work_status = -1  # 工作状态

        # 需要初始化的参数
        self.parameter_field = None
        self.order_ref = None
        self.order_ref_range = []

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
        if self.ReqOrderInsert(input_order_field) == 0:
            # 本地订单信息字典
            self.local_order_dict[input_order_field.OrderRef] = LocalOrderInfo(
                ExchangeID=input_order_field.ExchangeID,
                InstrumentID=input_order_field.InstrumentID,
                OrderRef=input_order_field.OrderRef,
                Direction=input_order_field.Direction,
                OffsetFlag=input_order_field.CombOffsetFlag,
                LimitPrice=input_order_field.LimitPrice,
                VolumeTotalOriginal=input_order_field.VolumeTotalOriginal,
                VolumeTotal=input_order_field.VolumeTotalOriginal,
                OrderStatus=b'',
                OrderSysID=b'',
                InputTime=timer(),
            )

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
        录入撤单回报。
        :param pInputOrder: AlgoPlus.CTP.ApiStruct中InputOrderField的实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg
        :param nRequestID: 
        :param bIsLast: 
        :return: 
        """
        if pRspInfo.ErrorID != 0:
            if pInputOrder.InstrumentID == self.parameter_field.AInstrumentID:
                self.on_leg1_insert_fail(pInputOrder)
            elif pInputOrder.InstrumentID == self.parameter_field.BInstrumentID:
                self.on_leg2_insert_fail(pInputOrder)
        self._write_log(f"{pRspInfo}=>{pInputOrder}")
        # # 延时计时开始
        # # 如果需要延时数据，请取消注释
        # self.anchor_time = timer()
        # self.timer_dict["FunctionName"] = "OnRspOrderInsert"
        # self.timer_dict["OrderStatus"] = b""
        # self.timer_dict["AnchorTime"] = self.anchor_time
        # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
        # self.csv_writer.writerow(self.timer_dict)
        # self.csv_file.flush()
        # # 延时计时结束

    # ############################################################################# #
    def is_my_order(self, order_ref):
        """
        以OrderRef标识本策略订单。
        """
        return order_ref.isdigit() and self.order_ref_range[0] < int(order_ref) < self.order_ref_range[1]

    def OnRtnOrder(self, pOrder):
        """
        当收到订单状态变化时，可以在本方法中获得通知。
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
        # self.anchor_time = timer()
        # self.timer_dict["FunctionName"] = "OnRtnOrder"
        # self.timer_dict["OrderStatus"] = pOrder.OrderStatus
        # self.timer_dict["AnchorTime"] = self.anchor_time
        # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
        # self.csv_writer.writerow(self.timer_dict)
        # self.csv_file.flush()
        # # 延时计时结束

        if self.is_my_order(pOrder.OrderRef):
            local_order_info = self.local_order_dict[pOrder.OrderRef]

            if local_order_info.OrderSysID == b'':
                local_order_info.OrderSysID = pOrder.OrderSysID

            # 未成交
            if local_order_info.OrderStatus == b'' and pOrder.OrderStatus == b'3':
                local_order_info.OrderStatus = b'3'  # 未成交状态

            # 全部成交
            elif pOrder.OrderStatus == b'0':
                local_order_info.OrderStatus = b'0'  # 全部成交状态
                if pOrder.InstrumentID == self.parameter_field.AInstrumentID:
                    self.on_leg1_traded(pOrder)
                elif pOrder.InstrumentID == self.parameter_field.BInstrumentID:
                    self.on_leg2_traded(pOrder)

            # 部分成交
            elif pOrder.OrderStatus == b'1':
                local_order_info.OrderStatus = b'1'  # 部分成交状态
                if pOrder.InstrumentID == self.parameter_field.AInstrumentID:
                    self.on_leg1_traded(pOrder)
                elif pOrder.InstrumentID == self.parameter_field.BInstrumentID:
                    self.on_leg2_traded(pOrder)

            # 撤单成功
            elif pOrder.OrderStatus == b'5':
                local_order_info.OrderStatus = b'5'  # 已撤单状态
                if pOrder.InstrumentID == self.parameter_field.AInstrumentID:
                    self.with_draw_num += 1
                    self.on_leg1_action(pOrder)
                elif pOrder.InstrumentID == self.parameter_field.BInstrumentID:
                    self.on_leg2_action(pOrder)

            # 委托失败
            elif pOrder.OrderSubmitStatus == b'4':
                local_order_info.OrderStatus = b'9'  # 委托失败状态
                self.on_insert_order_fail(pOrder)
                if pOrder.InstrumentID == self.parameter_field.AInstrumentID:
                    self.on_leg1_insert_fail(pOrder)
                elif pOrder.InstrumentID == self.parameter_field.BInstrumentID:
                    self.on_leg2_insert_fail(pOrder)

            # 撤单失败
            elif pOrder.OrderSubmitStatus == b'5':
                local_order_info.OrderStatus = b'8'  # 撤单失败状态
                self.on_order_action_fail(pOrder)
                if pOrder.InstrumentID == self.parameter_field.AInstrumentID:
                    self.on_leg1_action_fail(pOrder)
                elif pOrder.InstrumentID == self.parameter_field.BInstrumentID:
                    self.on_leg2_action_fail(pOrder)

    def on_leg1_traded(self, rtn_order_field):
        """
        腿一（不活跃合约）成交时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg2_traded(self, rtn_order_field):
        """
        腿二（活跃合约）成交时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg1_action(self, rtn_order_field):
        """
        腿一（不活跃合约）撤单成功时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg2_action(self, rtn_order_field):
        """
        腿二（活跃合约）撤单成功时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg1_insert_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）订单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField或者InputOrder的实例。注意使用其公共字段。
        :return:
        """
        pass

    def on_leg2_insert_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）报单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField或者InputOrder的实例。注意使用其公共字段。
        :return:
        """
        pass

    def on_leg1_action_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）撤单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField或者InputOrderActionField的实例。注意使用其公共字段。
        :return:
        """
        pass

    def on_leg2_action_fail(self, rtn_order_field):
        """
        腿二（活跃合约）撤单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField或者InputOrderActionField的实例。注意使用其公共字段。
        :return:
        """
        pass

    # ############################################################################# #
    def OnRtnTrade(self, pTrade):
        """
        当报单成交时，可以在本方法中获得通知。
        TradeField包含成交价格，而OrderField则没有。
        如果不需要成交价格，可忽略该通知，使用OrderField。
        :param pTrade: AlgoPlus.CTP.ApiStruct中的TradeField实例。
        :return:
        """
        pass

    # ############################################################################# #
    def OnErrRtnOrderInsert(self, pInputOrder, pRspInfo):
        """
        订单错误通知。
        :param pInputOrder: AlgoPlus.CTP.ApiStruct中的InputOrderField实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg
        :return:
        """
        if pRspInfo.ErrorID != 0:
            if pInputOrder.InstrumentID == self.parameter_field.AInstrumentID:
                self.on_leg1_action_fail(pInputOrder)
            elif pInputOrder.InstrumentID == self.parameter_field.BInstrumentID:
                self.on_leg2_action_fail(pInputOrder)
        self._write_log(f"{pRspInfo}=>{pInputOrder}")
        # # 延时计时开始
        # # 如果需要延时数据，请取消注释
        # self.anchor_time = timer()
        # self.timer_dict["FunctionName"] = "OnErrRtnOrderInsert"
        # self.timer_dict["OrderStatus"] = b""
        # self.timer_dict["AnchorTime"] = self.anchor_time
        # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
        # self.csv_writer.writerow(self.timer_dict)
        # self.csv_file.flush()
        # # 延时计时结束

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
        l_retVal = self.ReqOrderAction(input_order_action_field)

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
        录入撤单回报。
        :param pInputOrderAction: AlgoPlus.CTP.ApiStruct中InputOrderActionField的实例。
        :param pRspInfo: AlgoPlus.CTP.ApiStruct中RspInfoField的实例。包含错误代码ErrorID和错误信息ErrorMsg
        :param nRequestID:
        :param bIsLast:
        :return:
        """
        if pRspInfo.ErrorID != 0:
            if pInputOrderAction.InstrumentID == self.parameter_field.AInstrumentID:
                self.on_leg1_action_fail(pInputOrderAction)
            elif pInputOrderAction.InstrumentID == self.parameter_field.BInstrumentID:
                self.on_leg2_action_fail(pInputOrderAction)

        self._write_log(f"{pRspInfo}=>{pInputOrderAction}")
        # # 延时计时开始
        # # 如果需要延时数据，请取消注释
        # self.anchor_time = timer()
        # self.timer_dict["FunctionName"] = "OnRspOrderAction"
        # self.timer_dict["OrderStatus"] = b""
        # self.timer_dict["AnchorTime"] = self.anchor_time
        # self.timer_dict["DeltaTime"] = self.anchor_time - self.start_time
        # self.csv_writer.writerow(self.timer_dict)
        # self.csv_file.flush()
        # # 延时计时结束

    # ############################################################################# #
    def check_local_orders(self):
        """
        检查所有挂单是否满足撤单条件。
        :return:
        """
        try:
            for order_ref in list(self.local_order_dict):
                local_order_field = self.local_order_dict[order_ref]
                if local_order_field.OrderStatus == b'1' or local_order_field.OrderStatus == b'3':
                    if local_order_field.InstrumentID == self.parameter_field.AInstrumentID:
                        self.with_draw_leg1_order(local_order_field)
                    elif local_order_field.InstrumentID == self.parameter_field.BInstrumentID:
                        self.with_draw_leg2_order(local_order_field)
        except Exception as err:
            pass

    def with_draw_leg1_order(self, local_order_field):
        """
        判断是否满足腿一撤单条件。
        :param local_order_field: 本地订单信息
        :return:
        """
        pass

    def with_draw_leg2_order(self, local_order_field):
        """
        判断是否满足腿二撤单条件。
        :param local_order_field: 本地订单信息
        :return:
        """
        pass

    # ############################################################################# #
    def get_order_price_l1(self, direction, offset_flag):
        """
        获取腿一（不活跃合约）报单价格。
        :param direction: b"0"表示买，其他（b"1"）表示卖，注意是bytes类型
        :param offset_flag: b"0"表示开，其他（b"1"）表示平，注意是bytes类型
        :return: 根据买开、卖平、卖开、卖平类型，判断是否满足交易条件，如果满足，返回订单委托价格。否则，返回None。
        """
        return None

    def get_order_price_l2(self, direction):
        """
        获取腿二（活跃合约）报单价格。与get_order_price_l1不同，要确保get_order_price_l2方法返回具体数值。
        :param direction: b"0"表示买，其他（b"1"）表示卖，注意是bytes类型
        :return: 买入返回卖1价，卖出返回买1价
        """
        if direction == b'0':
            return self.md_b.AskPrice1
        else:
            return self.md_b.BidPrice1

    # ############################################################################# #
    def update_buy_spread_open(self):
        """
        买价差开仓。
        self.position_status标识策略持仓阶段（0表示无持仓，1表示多头开/持仓，2表示平仓）。
        只有无持仓时，或者价差多头持仓时，可买价差开仓。
        self.sig_stage标识信号执行阶段（0表示无信号执行，1表示信号执行中）。
        触发信号后，先对腿一买开仓，再对腿二卖开仓。腿一腿二配平后，self.sig_stage重置为0。
        order_price为None表示不满足交易条件，否则满足交易条件。
        :return:
        """
        if self.sig_stage == 0 and (self.position_status == 0 or self.position_status == 1):
            order_price = self.get_order_price_l1(b'0', b'0')
            if order_price:
                self.position_status = 1
                self.sig_stage = 1

                self.order_ref += 1
                self.buy_open(self.parameter_field.AExchangeID, self.parameter_field.AInstrumentID, order_price, self.parameter_field.Lots, self.order_ref)
                self._write_log(f"买价差开仓信号 => 第一腿开仓！")

    def update_sell_spread_close(self):
        """
        卖价差平仓。
        self.position_status标识策略持仓阶段（0表示无持仓，1表示多头开/持仓，2表示平仓）。
        只有持有价差多头时，可卖价差平仓。
        self.sig_stage标识信号执行阶段（0表示无信号执行，1表示信号执行中）。
        触发信号后，先对腿一买开仓，再对腿二卖开仓。腿一腿二配平后，self.sig_stage重置为0。
        order_price为None表示不满足交易条件，否则满足交易条件。
        :return:
        """
        if self.sig_stage == 0 and (self.position_status == 1 and self.sig_stage == 0):
            order_price = self.get_order_price_l1(b'1', b'1')
            if order_price:
                self.position_status = 2
                self.sig_stage = 1

                self.order_ref += 1
                self.sell_close(self.parameter_field.AExchangeID, self.parameter_field.AInstrumentID, order_price, self.parameter_field.Lots, self.order_ref)
                self._write_log(f"卖价差平仓信号 => 第一腿平仓！")

    def update_sell_spread_open(self):
        """
        卖价差开仓。
        self.position_status标识策略持仓阶段（0表示无持仓，1表示多头开/持仓，2表示平仓）。
        只有无持仓时，或者持有价差空头时，可卖价差开仓。
        self.sig_stage标识信号执行阶段（0表示无信号执行，1表示信号执行中）。
        触发信号后，先对腿一买开仓，再对腿二卖开仓。腿一腿二配平后，self.sig_stage重置为0。
        order_price为None表示不满足交易条件，否则满足交易条件。
        :return:
        """
        if self.sig_stage == 0 and (self.position_status == 0 or self.position_status == -1):
            order_price = self.get_order_price_l1(b'1', b'0')
            if order_price:
                self.position_status = -1
                self.sig_stage = 1

                self.order_ref += 1
                self.sell_open(self.parameter_field.AExchangeID, self.parameter_field.AInstrumentID, order_price, self.parameter_field.Lots, self.order_ref)
                self._write_log(f"卖价差开仓信号 => 第一腿开仓！")

    def update_buy_spread_close(self):
        """
        买价差平仓。
        self.position_status标识策略持仓阶段（0表示无持仓，1表示多头开/持仓，2表示平仓）。
        只有持有价差空头时，可买价差平仓。
        self.sig_stage标识信号执行阶段（0表示无信号执行，1表示信号执行中）。
        触发信号后，先对腿一买开仓，再对腿二卖开仓。腿一腿二配平后，self.sig_stage重置为0。
        order_price为None表示不满足交易条件，否则满足交易条件。
        :return:
        """
        if self.sig_stage == 0 and (self.position_status == -1 and self.sig_stage == 0):
            order_price = self.get_order_price_l1(b'0', b'1')
            if order_price:
                self.position_status = -2
                self.sig_stage = 1

                self.order_ref += 1
                self.buy_close(self.parameter_field.AExchangeID, self.parameter_field.AInstrumentID, order_price, self.parameter_field.Lots, self.order_ref)
                self._write_log(f"买价差平仓信号 => 第一腿平仓！")

    # ############################################################################# #
    def update_open_status(self):
        """
        开仓限制条件，以撤单次数为例。
        :return: 可开仓，返回True。否则返回False。
        """
        return False

    def update_close_status(self):
        """
        开仓限制条件，以撤单次数为例。
        :return: 可平仓，返回True。否则返回False。
        """
        return False

    # ############################################################################# #
    def Join(self):
        while True:
            if self.status == 0 and self.work_status >= 0:
                while not self.md_queue.empty():
                    last_md = self.md_queue.get(block=False)
                    if last_md.InstrumentID == self.parameter_field.AInstrumentID:
                        self.md_a = last_md
                        self.server_time = max(self.server_time, self.md_a.UpdateTime)
                        print(self.md_a)
                    elif last_md.InstrumentID == self.parameter_field.BInstrumentID:
                        self.md_b = last_md
                        self.server_time = max(self.server_time, self.md_a.UpdateTime)
                        print(self.md_b)

                if 0 < self.work_status < 4:
                    self.check_local_orders()
                    if self.update_open_status():
                        self.update_buy_spread_open()
                        self.update_sell_spread_open()
                    elif (self.work_status == 1 or self.work_status == 3) and self.sig_stage == 0:
                        self.work_status = 2 if self.work_status == 1 else 4
                        self._write_log(f"触发暂停开仓条件！")

                    if self.update_close_status():
                        self.update_buy_spread_close()
                        self.update_sell_spread_close()
                    elif (self.work_status == 1 or self.work_status == 2) and self.sig_stage == 0:
                        self.work_status = 3 if self.work_status == 1 else 4
                        self._write_log(f"触发暂停平仓条件！")

                elif self.work_status >= 4:
                    self._write_log(f"开仓与平仓均已暂停！")
                    break
                elif self.md_a is not None and self.md_b is not None and \
                        0 < self.md_a.AskPrice1 < 9999999 and 0 < self.md_a.BidPrice1 < 9999999 and 0 < self.md_b.AskPrice1 < 9999999 and 0 < self.md_b.BidPrice1 < 9999999:
                    self.work_status = 1
            else:
                sleep(1)
