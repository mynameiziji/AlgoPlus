# -*- coding: utf-8 -*-

from ctypes import *
from pymysql import Connect


def get_table_name(name, extent_name=''):
    return name + ('_' + extent_name if extent_name else '')


class MySql:
    def __init__(self, user, password, database, host='127.0.0.1', port=3306, charset="utf8"):
        self.db = self.connect_db(user, password, database, host, port, charset)
        self.db_cursor = self.db.cursor()

    def connect_db(self, user, password, database, host='127.0.0.1', port=3306, charset="utf8"):
        return Connect(host=host, user=user, password=password, database=database, port=port, charset=charset)

    def create_table(self, structure_cls, extent_name=''):
        table_name = get_table_name(structure_cls.__name__, extent_name)
        sql_str = 'CREATE TABLE IF NOT EXISTS ' + table_name + ' (ID INT AUTO_INCREMENT PRIMARY KEY,'
        init_len = len(sql_str)
        for field_name, field_cls in structure_cls._fields_:
            if isinstance(field_cls, type(c_char * 1)):
                sql_str += field_name + ' VARBINARY(' + str(field_cls._length_) + '),'
            elif issubclass(field_cls, c_int) or issubclass(field_cls, c_long):
                sql_str += field_name + ' INT,'
            elif issubclass(field_cls, c_double):
                sql_str += field_name + ' DOUBLE,'
            elif issubclass(field_cls, c_float):
                sql_str += field_name + ' FLOAT,'

        if len(sql_str) > init_len:
            self.db_cursor.execute(sql_str[:-1] + ');')
            self.db.commit()

    def insert_into(self, data_structure, extent_name=''):
        table_name = get_table_name(data_structure.__class__.__name__, extent_name)
        sql_str = 'INSERT INTO ' + table_name + ' VALUES(0,'
        init_len = len(sql_str)
        for field_name, _ in data_structure._fields_:
            _value = getattr(data_structure, field_name)
            if isinstance(_value, bytes):
                sql_str += "'" + _value.decode(encoding="gb18030", errors="ignore") + "',"
            elif isinstance(_value, str):
                sql_str += _value + ","
            else:
                sql_str += str(_value) + ","

        if len(sql_str) > init_len:
            self.db_cursor.execute(sql_str[:-1] + ');')
            self.db.commit()

    def select_from(self, structure_cls, extent_name='', select_field_list=None, where_str='', limit_pos=None, limit_num=None):
        table_name = get_table_name(structure_cls.__name__, extent_name)

        if not select_field_list:
            select_field_str = 'ID,' + ','.join(structure_cls.get_key_field_list())
        elif isinstance(select_field_list, list):
            select_field_str = 'ID,' + ','.join(select_field_list)
        elif isinstance(select_field_list, str):
            select_field_str = 'ID,' + select_field_list
        else:
            return None

        sql_str = 'SELECT ' + select_field_str + \
                  ' FROM ' + table_name + \
                  ' WHERE ' + (where_str if where_str and isinstance(where_str, str) else '1=1') + \
                  ' ORDER BY ID DESC'

        if isinstance(limit_num, int) and isinstance(limit_num, int):
            sql_str += ' LIMIT ' + str(limit_pos) + ',' + str(limit_num)

        self.db_cursor.execute(sql_str + ';')
        return self.db_cursor.fetchall()


if __name__ == "__main__":
    from AlgoPlus.CTP.ApiStruct import DepthMarketDataField

    my_db = MySql('root', 'root', 'ctp')
    my_db.create_table(DepthMarketDataField)
    my_db.insert_into(DepthMarketDataField())
    print(my_db.select_from(DepthMarketDataField, limit_pos=0, limit_num=5))
