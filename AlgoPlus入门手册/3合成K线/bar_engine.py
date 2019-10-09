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

        # Bar字段
        bar_field = {"UpdateTime": b"99:99:99",
                     "LastPrice": 0.0,
                     "HighPrice": 0.0,
                     "LowPrice": 0.0,
                     "OpenPrice": 0.0,
                     "BarVolume": 0,
                     "BarTurnover": 0.0,
                     "BarSettlement": 0.0,
                     "BVolume": 0,
                     "SVolume": 0,
                     "FVolume": 0,
                     "DayVolume": 0,
                     "DayTurnover": 0.0,
                     "DaySettlement": 0.0,
                     "OpenInterest": 0.0,
                     "LastVolume": 0,
                     "TradingDay": b"99999999",
                     }

        self.bar_field_dict = {}  # Bar字段 字典
        # 遍历订阅列表
        for instrument_id in self.instrument_id_list:
            # 将str转为byte
            if isinstance(instrument_id, str):
                instrument_id = instrument_id.encode('utf-8')

            # 初始化Bar字段
            self.bar_field_dict[instrument_id] = bar_field.copy()

        self.Join()

    # ///深度行情通知
    def OnRtnDepthMarketData(self, pDepthMarketData):
        last_update_time = self.bar_field_dict[pDepthMarketData.InstrumentID]["UpdateTime"]
        is_new_1minute = (pDepthMarketData.UpdateTime[:-2] != last_update_time[:-2]) and pDepthMarketData.UpdateTime != b'21:00:00'  # 1分钟K线条件
        is_new_5minute = is_new_1minute and int(pDepthMarketData.UpdateTime[-4]) % 5 == 0  # 5分钟K线条件
        is_new_10minute = is_new_1minute and pDepthMarketData.UpdateTime[-4] == b"0"  # 10分钟K线条件
        is_new_10minute = is_new_1minute and int(pDepthMarketData.UpdateTime[-5:-3]) % 15 == 0  # 15分钟K线条件
        is_new_30minute = is_new_1minute and int(pDepthMarketData.UpdateTime[-5:-3]) % 30 == 0  # 30分钟K线条件
        is_new_hour = is_new_1minute and int(pDepthMarketData.UpdateTime[-5:-3]) % 60 == 0  # 60分钟K线条件

        is_new_bar = is_new_1minute

        # 新K线开始
        if is_new_bar:
            print(self.bar_field_dict[pDepthMarketData.InstrumentID])

        # 将Tick池化为Bar
        self.tick_to_bar(pDepthMarketData, is_new_bar)

    def tick_to_bar(self, raw_frame, is_new_bar):
        the_bar = self.bar_field_dict[raw_frame.InstrumentID]

        # 非同一交易日重新初始化
        if raw_frame.TradingDay != the_bar["TradingDay"]:
            the_bar["LastVolume"] = 0  # Bar成交量
            the_bar["DayVolume"] = 0  # Day成交量
            the_bar["DayTurnover"] = 0.0  # Day成交额
            the_bar["TradingDay"] = raw_frame.TradingDay

        tick_volume = raw_frame.Volume - the_bar["LastVolume"]  # Tick成交量
        the_bar["LastVolume"] = raw_frame.Volume
        the_bar["UpdateTime"] = raw_frame.UpdateTime  # 时间戳
        the_bar["OpenInterest"] = raw_frame.OpenInterest  # 持仓量

        # 初始化
        if is_new_bar:
            # "B"为主动买，"S"为主动卖，"F"为模糊状态
            the_bar["BVolume"] = 0
            the_bar["SVolume"] = 0
            the_bar["FVolume"] = 0

            the_bar["BarVolume"] = 0  # Bar成交量
            the_bar["BarTurnover"] = 0.0  # Bar成交额

        # 有成交
        if tick_volume > 0:
            tick_turnover = tick_volume * raw_frame.LastPrice  # Tick成交额

            the_bar["DayVolume"] += tick_volume  # Day成交量
            the_bar["DayTurnover"] += tick_turnover  # Day成交额
            the_bar["DaySettlement"] = the_bar["DayTurnover"] / the_bar["DayVolume"]  # Day均价

            # "B"为主动买，"S"为主动卖，"F"为模糊状态
            if raw_frame.LastPrice >= raw_frame.AskPrice1:
                the_bar["BVolume"] += tick_volume  # Bar主动买成交量
            elif raw_frame.LastPrice <= raw_frame.BidPrice1:
                the_bar["SVolume"] += tick_volume  # Bar主动卖成交量
            else:
                the_bar["FVolume"] += tick_volume  # Bar模糊成交量

            if the_bar["BarVolume"] == 0:
                the_bar["LastPrice"] = raw_frame.LastPrice  # Bar收盘价
                the_bar["HighPrice"] = raw_frame.LastPrice  # Bar最高价
                the_bar["LowPrice"] = raw_frame.LastPrice  # Bar最低价
                the_bar["OpenPrice"] = raw_frame.LastPrice  # Bar开盘价
                the_bar["BarVolume"] = tick_volume  # Bar成交量
                the_bar["BarTurnover"] = tick_turnover  # Bar成交额
                the_bar["BarSettlement"] = raw_frame.LastPrice  # Bar均价
            else:
                the_bar["LastPrice"] = raw_frame.LastPrice  # Bar收盘价
                the_bar["HighPrice"] = max(raw_frame.LastPrice, the_bar["HighPrice"])  # Bar最高价
                the_bar["LowPrice"] = min(raw_frame.LastPrice, the_bar["LowPrice"])  # Bar最低价
                the_bar["BarVolume"] += tick_volume  # Bar成交量
                the_bar["BarTurnover"] += tick_turnover  # Bar成交额
                the_bar["BarSettlement"] = the_bar["BarTurnover"] / the_bar["BarVolume"]  # Bar均价


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
