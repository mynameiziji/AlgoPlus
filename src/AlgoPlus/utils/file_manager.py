# -*- coding:utf-8 -*-

import os


def create_page_file(page_dir, page_name, page_size):
    result = None
    try:
        page_loacation = os.path.join(page_dir, page_name)
        if not os.path.exists(page_loacation):
            parent_dir_list = page_dir.split(os.path.sep)
            parent_dir = parent_dir_list[0]

            for dir in parent_dir_list[1:]:
                parent_dir += os.path.sep + dir
                if not os.path.exists(parent_dir):
                    os.mkdir(parent_dir)

            with open(page_loacation, 'xb') as page_file:
                page_file.truncate(page_size)
        else:
            with open(page_loacation, 'ab') as page_file:
                page_file.truncate(os.path.getsize(page_loacation) + page_size)
        result = os.path.getsize(page_loacation)
    except Exception as err_msg:
        print(f"create_page_file || {err_msg}")
    finally:
        return result
