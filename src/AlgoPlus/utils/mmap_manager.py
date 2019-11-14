# -*- coding:utf-8 -*-

import os
import mmap


def create_mmap_buffer(page_dir, page_name, page_size):
    page_buffer = None
    try:
        page_location = os.path.join(page_dir, page_name) if page_dir else ''
        page_file = open(page_location, 'rb+') if page_location else None
        page_buffer = mmap.mmap(fileno=page_file.fileno() if page_file else -1
                                , length=page_size
                                , access=mmap.ACCESS_WRITE  # mmap.ACCESS_READ
                                # , tagname=f"{page_dir}\\{page_name}"
                                )
        if page_file is not None:
            page_file.close()

        if page_buffer is not None:
            page_buffer.flush()
    except Exception as err_msg:
        print(f"create_mmap_buffer || {err_msg}")
    finally:
        return page_buffer
