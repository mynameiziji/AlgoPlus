# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

from ctypes import *
from multiprocessing import Process, Queue
from time import perf_counter as timer
from spread_trading_base import SpreadTradingBase
from AlgoPlus.utils.base_field import BaseField
from tick_engine import TickEngine


class SpreadTradingFields(BaseField):
    _fields_ = [
        ('StrategyName', c_char * 100),
        ('StrategyID', c_int),

        ('AInstrumentID', c_char * 31),  # A合约代码
        ('APriceTick', c_double),  # A最小变动价位
        ('AExchangeID', c_char * 9),  # A交易所代码

        ('BInstrumentID', c_char * 31),  # B合约代码
        ('BPriceTick', c_double),  # B最小变动价位
        ('BExchangeID', c_char * 9),  # B交易所代码

        ('BuyOpenSpread', c_double),  # 买开仓价差
        ('SellCloseSpread', c_double),  # 卖平仓价差
        ('SellOpenSpread', c_double),  # 卖开仓价差
        ('BuyCloseSpread', c_double),  # 买平仓价差

        ('Lots', c_int),  # 下单手数
        ('MaxActionNum', c_int),  # 最大撤单次数
        ('MaxPosition', c_int),  # 最大持仓手数

        ('AWaitSeconds', c_float),  # B合约撤单前等待秒
        ('BWaitSeconds', c_float),  # B合约撤单前等待秒
    ]


class MySpreadTrading(SpreadTradingBase):
    # ############################################################################# #
    def init_parameter(self):
        """
        初始化策略参数
        :return:
        """
        self.parameter_field = self.md_queue.get(block=False)  # 策略参数结构体
        self.order_ref = self.parameter_field.StrategyID * 10000  # 报单引用
        self.order_ref_range = [self.order_ref, self.order_ref + 10000]  # 报单引用区间

        self.work_status = 0
        self._write_log(f"策略参数初始化完成！=>{self.parameter_field}")

    # ############################################################################# #
    def on_leg1_traded(self, rtn_order_field):
        """
        腿一（不活跃合约）成交时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderFireq_order_inserteld的实例。
        :return:
        """
        local_order_info = self.local_order_dict[rtn_order_field.OrderRef]  # 本地订单信息
        volume_traded = local_order_info.VolumeTotal - rtn_order_field.VolumeTotal  # 腿一成交数量
        if volume_traded > 0:
            local_order_info.VolumeTotal = rtn_order_field.VolumeTotal  # 腿一剩余数量
            self.position_a += volume_traded  # 腿一总持仓
            self.order_ref += 1
            if rtn_order_field.Direction == b'0':
                order_price = self.get_order_price_l2(b'1')  # 腿二报单价格
                self.sell_open(self.parameter_field.BExchangeID, self.parameter_field.BInstrumentID, order_price, volume_traded, self.order_ref)
            else:
                order_price = self.get_order_price_l2(b'0')  # 腿二报单价格
                self.buy_open(self.parameter_field.BExchangeID, self.parameter_field.BInstrumentID, order_price, volume_traded, self.order_ref)

    def on_leg2_traded(self, rtn_order_field):
        """
        腿二（活跃合约）成交时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        local_order_info = self.local_order_dict[rtn_order_field.OrderRef]  # 本地订单信息
        volume_traded = local_order_info.VolumeTotal - rtn_order_field.VolumeTotal  # 腿二成交数量
        if volume_traded > 0:
            local_order_info.VolumeTotal = rtn_order_field.VolumeTotal  # 腿二成交数量
            self.position_b += volume_traded  # 腿二总持仓
            if rtn_order_field.VolumeTotal == 0:
                self.sig_stage = 0
                self.local_order_dict.clear()
                self._write_log(f"腿一与腿二配对完成！目前持仓情况，腿一：{self.position_a}，腿二：{self.position_b}")

    def on_leg1_action(self, rtn_order_field):
        """
        腿一（不活跃合约）撤单成功时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        self.sig_stage = 0
        if self.position_a == 0:
            self.position_status = 0

    def on_leg2_action(self, rtn_order_field):
        """
        腿二（活跃合约）撤单成功时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        self.order_ref += 1
        order_price = self.get_order_price_l2(rtn_order_field.Direction)  # 腿二报单价格
        self.req_order_insert(rtn_order_field.ExchangeID, rtn_order_field.InstrumentID, order_price, rtn_order_field.VolumeTotal, self.order_ref, rtn_order_field.Direction, rtn_order_field.CombOffsetFlag)

    def on_leg1_insert_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）订单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg2_insert_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）报单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg1_action_fail(self, rtn_order_field):
        """
        腿一（不活跃合约）撤单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    def on_leg2_action_fail(self, rtn_order_field):
        """
        腿二（活跃合约）撤单失败时需要执行的交易逻辑。
        :param rtn_order_field: AlgoPlus.CTP.ApiStruct中OrderField的实例。
        :return:
        """
        pass

    # ############################################################################# #
    def with_draw_leg1_order(self, local_order_field):
        """
        判断是否满足腿一撤单条件。
        :param local_order_field: 本地订单信息
        :return:
        """
        anchor_time = timer()
        if anchor_time - local_order_field.InputTime > self.parameter_field.AWaitSeconds:
            self.req_order_action(self.parameter_field.AExchangeID, self.parameter_field.AInstrumentID, local_order_field.OrderRef)
            local_order_field.OrderStatus = b'7'  # 修改本地订单状态，避免重复撤单
            self._write_log(f"撤销腿一挂单！OrderRef={local_order_field.OrderRef}")

    def with_draw_leg2_order(self, local_order_field):
        """
        判断是否满足腿二撤单条件。
        :param local_order_field: 本地订单信息
        :return:
        """
        anchor_time = timer()
        if anchor_time - local_order_field.InputTime > self.parameter_field.BWaitSeconds:
            self.req_order_action(self.parameter_field.BExchangeID, self.parameter_field.BInstrumentID, local_order_field.OrderRef)
            local_order_field.OrderStatus = b'7'  # 修改本地订单状态，避免重复撤单
            self._write_log(f"撤销腿二挂单！OrderRef={local_order_field.OrderRef}")

    # ############################################################################# #
    def get_order_price_l1(self, direction, offset_flag):
        """
        获取腿一（不活跃合约）报单价格。
        :param direction: b"0"表示买，其他（b"1"）表示卖，注意是bytes类型
        :param offset_flag: b"0"表示开，其他（b"1"）表示平，注意是bytes类型
        :return: 根据买开、卖平、卖开、卖平类型，判断是否满足交易条件，如果满足，返回订单委托价格。否则，返回None。
        """
        order_price = None
        try:
            if direction == b'0':
                if self.md_a.BidPrice1 - self.md_b.BidPrice1 < self.parameter_field.BuyOpenSpread if offset_flag == b'0' else self.parameter_field.BuyCloseSpread:
                    order_price = self.md_a.BidPrice1 + self.parameter_field.APriceTick
            else:
                if self.md_a.AskPrice1 - self.md_b.AskPrice1 > self.parameter_field.SellOpenSpread if offset_flag == b'0' else self.parameter_field.SellCloseSpread:
                    order_price = self.md_a.AskPrice1 - self.parameter_field.APriceTick
        finally:
            return order_price

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
    def update_open_status(self):
        """
        开仓限制条件，以撤单次数为例。
        :return: 可开仓，返回True。否则返回False。
        """
        if self.with_draw_num < self.parameter_field.MaxActionNum and self.position_a < self.parameter_field.MaxPosition:
            return True
        return False

    def update_close_status(self):
        """
        平仓限制条件。
        :return: 可平仓，返回True。否则返回False。
        """
        return True


if __name__ == "__main__":

    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow24']

    # 共享队列
    share_queue = Queue(maxsize=100)
    my_strategy_parameter_field = SpreadTradingFields(
        StrategyName=b'AlgoPlus Spread Trading Exemplification',
        StrategyID=1,

        AInstrumentID=b'ni2001',
        APriceTick=10,
        AExchangeID=b'SHFE',

        BInstrumentID=b'ni1912',  # B合约代码
        BPriceTick=10,  # B最小变动价位
        BExchangeID=b'SHFE',  # B交易所代码

        BuyOpenSpread=30000,  # 买开仓价差
        SellCloseSpread=0,  # 卖平仓价差
        SellOpenSpread=50000,  # 卖开仓价差
        BuyCloseSpread=40000,  # 买平仓价差

        Lots=1,  # 下单手数
        MaxActionNum=100,  # 最大撤单次数
        MaxPosition=10,  # 最大持仓手数

        AWaitSeconds=1,  # B合约撤单前等待秒
        BWaitSeconds=1,  # B合约撤单前等待秒
    )
    share_queue.put(my_strategy_parameter_field)

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
    trader_process = Process(target=MySpreadTrading, args=(future_account.server_dict['TDServer']
                                                           , future_account.broker_id
                                                           , future_account.investor_id
                                                           , future_account.password
                                                           , future_account.app_id
                                                           , future_account.auth_code
                                                           , share_queue
                                                           , future_account.td_page_dir)
                             )
    #

    md_process.start()
    trader_process.start()

    md_process.join()
    trader_process.join()
