# -*- coding: utf-8 -*-

import os
import csv
from datetime import datetime
from AlgoPlus.utils.file_manager import create_page_file
from AlgoPlus.utils.mmap_manager import create_mmap_buffer


class LogWriter:
    # ################################################# #
    # 构造函数
    def __init__(self, page_dir, first_name, page_id, page_size=409600, sep=' || '):
        try:
            self.status = -1

            # first_name以byte存储合约名
            if isinstance(first_name, bytes) and first_name != b'':
                first_name = first_name.decode(encoding='utf-8')
            elif isinstance(first_name, str) and first_name != '':
                first_name = first_name
            else:
                raise Exception("first_name必须是str/byte类型！")

            # page_dir
            if isinstance(page_dir, bytes) and page_dir != b'':
                page_dir = page_dir.decode(encoding='utf-8')
            elif not isinstance(page_dir, str):
                raise Exception("page_dir必须是str/byte类型！")

            self.page_prefix = f"{first_name}.log"
            self.page_dir = os.path.join(page_dir, self.page_prefix)

            # 分隔符
            self.sep = sep

            self.page_size = page_size
            self.page_id = page_id

            self.page_buffer = None
            self.writed_len = 0
            self._load_page_buffer()

            self.status = 0

        except Exception as err_msg:
            self._write_log(err_msg)

    # ################################################# #
    # 析构函数
    def __del__(self):
        self.release_page_buffer()

    # ################################################# #
    # 释放page buffer
    def release_page_buffer(self):
        result = -1
        try:
            if self.page_buffer is not None and not self.page_buffer.closed:
                self.page_buffer.flush()
                self.page_buffer.close()
            result = 0
        except Exception as err_msg:
            self._write_log(err_msg)
        finally:
            return result

    # ################################################# #
    # 错误信息
    def _write_log(self, *args, sep=' || '):
        local_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"{local_time}{sep}{self.page_dir}\\{self.page_prefix}{sep}{sep.join(map(str, args))}")

    # ################################################# #
    # 创建page mmap
    def _load_page_buffer(self):
        if self.release_page_buffer() == -1:
            self._write_log(f"释放page_buffer发生错误！page_dir={self.page_dir}, page_name={self.page_prefix}.{self.page_id}")

        page_name = f"{self.page_prefix}.{self.page_id}"
        self.page_size = create_page_file(page_dir=self.page_dir, page_name=page_name, page_size=self.page_size)
        if self.page_size is None:
            raise Exception(f"创建/读取page文件失败！page_dir={self.page_dir}, page_name={page_name}, page_size={self.page_size}")

        self.page_buffer = create_mmap_buffer(self.page_dir, page_name, page_size=self.page_size)
        if self.page_buffer is None:
            raise Exception(f"创建mmap buffer失败！page_dir={self.page_dir}, page_name={page_name}, page_size={self.page_size}")

        self.writed_len = self.page_buffer.find(b'\x00')
        self.page_buffer.seek(self.writed_len)

    # ################################################# #
    # 写数据
    def write_log(self, *args):
        result = -1
        try:
            local_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            log_content = (local_time + self.sep + self.sep.join(map(str, args)) + '\n').encode(encoding="utf-8")
            tmp_len = self.writed_len + len(log_content)
            if tmp_len > self.page_size:
                raise Exception("扩展page_size！")
            self.page_buffer.write(log_content)
            result = 0
        except Exception as err_msg:
            if err_msg == "扩展page_size！":
                self._load_page_buffer()
                self._write_log(err_msg)
        finally:
            return result

    # ################################################# #
    # 转csv
    def to_csv(self, csv_dir='', csv_name=''):
        result = -1
        try:
            if self.page_buffer:
                to_csv_location = os.path.join(self.page_dir if csv_dir == '' else csv_dir
                                               , f"{self.page_prefix if csv_name == '' else csv_name}.{self.page_id}.to.csv")

                # windows系统文件避免乱码使用utf-8-sig编码
                with open(to_csv_location, 'w+', newline='', encoding='utf-8-sig') as csv_file:
                    csv_writer = csv.writer(csv_file)
                    self.page_buffer.seek(0)
                    while True:
                        cur_pos = self.page_buffer.tell()
                        if cur_pos + 1 > self.page_size:
                            break
                        content = self.page_buffer.readline()
                        if content[0:1] == b"\x00":
                            break
                        csv_writer.writerow(content.strip().decode(encoding='utf-8').split(self.sep))

                result = 0
        except Exception as err_msg:
            self._write_log(err_msg)
        finally:
            return result


if __name__ == '__main__':
    log_writer = LogWriter('.', datetime.now().strftime('%Y%m%d'), '1')
    log_writer.write_log('我只是想看看你乖不乖！')
    log_writer.write_log('我', '只', '是', '想', '看', '看', '你', '乖', '不', '乖', '！')
    log_writer.to_csv()
