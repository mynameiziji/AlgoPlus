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

from multiprocessing import Process, Queue
from profit_loss_manager_base import ProfitLossManagerBase
from tick_engine import TickEngine


class MyProfitLossManager(ProfitLossManagerBase):
    def __init__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):
        # 初始化参数
        self.init_parameter()

        self.Join()

    # ############################################################################# #
    def init_parameter(self):
        """
        初始化策略参数
        :return:
        """
        self.pl_parameter_dict = self.md_queue.get(block=False)  # 策略参数结构体
        self.order_ref = self.pl_parameter_dict[b"ID"] * 10000
        self._write_log(f"策略参数初始化完成！=>{self.pl_parameter_dict}")


if __name__ == "__main__":
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow24']

    # 共享队列
    share_queue = Queue(maxsize=100)
    pl_parameter = {b"ID": 9,
                    b"rb2001": {b"0": [2], b"1": [2]},
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
