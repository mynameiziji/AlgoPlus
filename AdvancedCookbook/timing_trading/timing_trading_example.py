# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com


from time import sleep
from multiprocessing import Process, Queue
from profit_loss_manager_base import ProfitLossManagerBase
from tick_engine import TickEngine


class MyProfitLossManager(ProfitLossManagerBase):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):

        super(MyProfitLossManager, self).__init__(td_server, broker_id, investor_id, password, app_id, auth_code, md_queue
                                                  , page_dir, private_resume_type, public_resume_type)

        self.trading_schedule = []
        self.anchor_time_list = []
        self.server_time_dict = {}

        # 初始化参数
        self.init_parameter()

        # 等待子线程结束
        self.Join()

    # ############################################################################# #
    def init_parameter(self):
        """
        初始化策略参数
        :return:
        """
        parameter_dict = self.md_queue.get(block=False)  # 策略参数结构体
        self.pl_parameter_dict = parameter_dict[b"ProfitLossParameterDict"]
        self.order_ref = parameter_dict[b"ID"] * 10000
        self.order_ref_range = [self.order_ref, self.order_ref + 10000]
        self.trading_schedule = parameter_dict[b"TradingScheduleDict"]

        self.anchor_time_list = parameter_dict[b"AnchorTimeList"]
        for instrument_id in self.trading_schedule.keys():
            if instrument_id not in self.instrument_id_registered:
                self.instrument_id_registered.append(instrument_id)

        self._write_log(f"策略参数初始化完成！ID=>{parameter_dict[b'ID']}")

    def is_my_order(self, order_ref):
        """
        以OrderRef标识本策略订单。
        """
        return order_ref.isdigit() and self.order_ref_range[0] < int(order_ref) < self.order_ref_range[1]

    def update_time_trigger(self, server_time, instrument_id):
        """
        如果触发时间条件则发出开仓委托。
        :param server_time: 服务器时间列表。server_time[0]表示最新时间，server_time[1]表示前一刻的时间
        :param instrument_id: 合约
        :return:
        """
        for anchor_time in self.anchor_time_list:
            if server_time[1] < anchor_time <= server_time[0]:
                self.order_ref += 1
                exchange_id = self.trading_schedule[instrument_id][b"ExchangeID"]
                volume = self.trading_schedule[instrument_id][b"Volume"]
                direction = self.trading_schedule[instrument_id][b"Direction"]
                order_price = self.get_default_price(instrument_id, direction)
                self.req_order_insert(exchange_id, instrument_id, order_price, volume, self.order_ref, direction, b"0")
                self._write_log(f"服务器时间{server_time[0]}触发{anchor_time}{'买' if direction == b'0' else '卖'}开仓{instrument_id}，价格:{order_price}，手数:{volume}")

    # ############################################################################# #
    def Join(self):
        while True:
            if self.status == 0:
                self.process_rtn_trade()

                while not self.md_queue.empty():
                    last_md = self.md_queue.get(block=False)
                    instrument_id = last_md["InstrumentID"]
                    if instrument_id in self.instrument_id_registered:
                        if instrument_id not in self.server_time_dict.keys():
                            self.server_time_dict[instrument_id] = [b"00:00:00", b"00:00:00"]
                        update_time = last_md["UpdateTime"]
                        self.server_time_dict[instrument_id][0] = update_time
                        self.md_dict[instrument_id] = last_md
                        if self.server_time_dict[instrument_id][1] != b"00:00:00":
                            self.update_time_trigger(self.server_time_dict[instrument_id], instrument_id)
                        self.server_time_dict[instrument_id][1] = update_time

                self.check_position()
            else:
                sleep(1)


if __name__ == "__main__":
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow']

    # 共享队列
    share_queue = Queue(maxsize=100)
    pl_parameter = {b"ID": 9,
                    # 开仓时间点
                    b"AnchorTimeList": [b"01:05:00", b"01:05:30", b"01:06:00", b"01:06:30", b"01:07:00", b"01:07:30", b"01:08:00", b"01:08:30"],
                    # 计划交易的合约及参数
                    b"TradingScheduleDict": {b"rb2001": {b"ExchangeID": b"SHFE", b"Direction": 1, b"Volume": 1},
                                             b"ag1912": {b"ExchangeID": b"SHFE", b"Direction": 1, b"Volume": 1},
                                             },
                    # 止损参数
                    b"ProfitLossParameterDict": {b"rb2001": {b"0": [2], b"1": [2]},
                                                 b"ag1912": {b"0": [10], b"1": [10]},
                                                 }
                    }
    share_queue.put(pl_parameter)

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
    trader_process = Process(target=MyProfitLossManager, args=(future_account.server_dict['TDServer']
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
