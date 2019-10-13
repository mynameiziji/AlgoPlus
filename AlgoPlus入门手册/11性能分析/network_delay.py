# -*- coding: utf-8 -*-
# AlgoPlus量化投资开源框架范例
# 微信公众号：AlgoPlus
# 项目地址：http://gitee.com/AlgoPlus/AlgoPlus
# 项目网址：http://www.algo.plus
# 项目网址：http://www.ctp.plus
# 项目网址：http://www.7jia.com

import os
import csv
import time
from time import perf_counter as timer
from AlgoPlus.utils.check_service import check_service

if __name__ == "__main__":

    import sys

    sys.path.append("..")
    from account_info import my_future_account_info_dict

    future_account = my_future_account_info_dict['SimNow24']

    for server in future_account.server_dict.values():
        ip = server.split(":")[0]
        port = int(server.split(":")[1])

        timer_dict = {"ID": 0,
                      "StartTime": 0.0,
                      "AnchorTime": 0.0,
                      "DeltaTime": 0.0,
                      }
        header = list(timer_dict)
        # file object
        csv_file = open(os.path.join(".", f"{ip}-{port}.csv"), 'w', newline='')
        # writer object
        csv_writer = csv.DictWriter(csv_file, header)
        # 写入表头
        csv_writer.writeheader()

        ikk = 0
        while ikk < 100:
            ikk += 1
            start_time = timer()
            if check_service(ip, port):
                anchor_time = timer()
                timer_dict["ID"] = ikk
                timer_dict["StartTime"] = start_time
                timer_dict["AnchorTime"] = anchor_time
                timer_dict["DeltaTime"] = anchor_time - start_time
                csv_writer.writerow(timer_dict)
            time.sleep(1)
