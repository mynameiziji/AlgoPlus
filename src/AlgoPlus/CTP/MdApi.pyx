# encoding:utf-8
# distutils: language=c++

from cpython     cimport PyObject
from libc.stdlib cimport malloc, free
from libcpp.memory cimport shared_ptr,make_shared
from libc.string cimport const_char
from libcpp      cimport bool as cbool

import os
import ctypes
from datetime import datetime

from .cython2c.ThostFtdcUserApiStruct cimport *
from .cython2c.cMdApi                 cimport CMdSpi, CMdApi, CreateFtdcMdApi

from .ApiStruct import *

from AlgoPlus.utils.check_service import  check_service


# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# 请参阅CTP量化开发社区(www.ctp.plus)发布的《CTP官方接口文档》：
# 《CTP接口工作流程概述》                       | http://ctp.plus/?/article/1
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
# 《TraderApi环境初始化与账户登录相关接口说明》 | http://ctp.plus/?/article/3
# 《TraderApi基础交易接口说明》                 | http://ctp.plus/?/article/4
# 《TraderApi扩展交易接口说明》                 | http://ctp.plus/?/article/5
# 《TraderApi资金与持仓查询接口说明》           | http://ctp.plus/?/article/6
# 《TraderApi保证金与手续费查询接口说明》       | http://ctp.plus/?/article/7
# 《TraderApi期权交易接口说明》                 | http://ctp.plus/?/article/8
# 《TraderApi银行相关接口说明》                 | http://ctp.plus/?/article/9
# 《TraderApi合约信息查询接口说明》             | http://ctp.plus/?/article/10
# 《TraderApi其他查询接口说明》                 | http://ctp.plus/?/article/11
# 《错误信息说明》                              | http://ctp.plus/?/article/12
# ############################################################################# #
# ############################################################################# #
# ############################################################################# #


cdef class MdApi():
    cdef CMdApi *_api
    cdef CMdSpi *_spi

    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    def __cinit__(self, md_server, broker_id, investor_id, password, app_id, auth_code
                      , instrument_id_list, md_queue_list=None
                      , page_dir='', using_udp=False, multicast=False):
        try:
            # ############################################################################# #
            # 状态
            self.status = -1

            # ############################################################################# #
            self._api = NULL
            self._spi = NULL

            # ############################################################################# #
            self.RequestID = 1

            # ############################################################################# #
            if isinstance(md_server, bytes):
                self.md_server = (b'' if md_server.startswith(b'tcp://') + md_server else b'tcp://')
            else:
                self.md_server = (('' if md_server.startswith('tcp://') else 'tcp://') + md_server).encode(encoding='utf-8')

            self.broker_id = broker_id if isinstance(broker_id, bytes) else broker_id.encode(encoding='utf-8')
            self.investor_id = investor_id if isinstance(investor_id, bytes) else investor_id.encode(encoding='utf-8')
            self.password = password if isinstance(password, bytes) else password.encode(encoding='utf-8')
            self.app_id = app_id if isinstance(app_id, bytes) else app_id.encode(encoding='utf-8')
            self.auth_code = auth_code if isinstance(auth_code, bytes) else auth_code.encode(encoding='utf-8')

            # ############################################################################# #
            page_dir = os.path.join(page_dir if isinstance(page_dir, str) else page_dir.decode(encoding='utf-8'), self.investor_id.decode(encoding='utf-8'))
            flow_path = (page_dir if page_dir.endswith('\\') else page_dir + '\\') + 'md.con\\'
            tmp_dir = ''
            for dir in flow_path.split('\\'):
                tmp_dir = os.path.join(tmp_dir, dir)
                if not os.path.exists(tmp_dir):
                    os.mkdir(tmp_dir)
            self.flow_path = flow_path.encode(encoding='utf-8')

            self.using_udp = using_udp
            self.multicast = multicast

            # ############################################################################# #
            if self.Init_Base() != 0:
                raise Exception("Init_Base || 创建MdApi与MdSpi失败！")

            # ############################################################################# #
            info_list = self.md_server.split(b":")
            ip = info_list[1][2:].decode(encoding='utf-8')
            port = int(info_list[2])
            if not check_service(ip, port):
                raise Exception(f'check_service || 服务器{self.md_server}未开启！')

            self.instrument_id_list = instrument_id_list
            self.md_queue_list = md_queue_list

            # ############################################################################# #
            # 初始化运行环境，只有调用后，接口才开始发起前置的连接请求。
            if self.Init_Net() != 0:
                raise Exception("Init_Net || 行情初始化失败！")
        except Exception as err_msg:
            self._write_log(err_msg)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    def Inc_RequestID(self):
        self.RequestID = self.RequestID + 1
        return self.RequestID

    # ############################################################################# #
    def _write_log(self, *args, sep=' || '):
        local_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"{local_time}{sep}md{sep.join(map(str, args))}")



    # ############################################################################# #
    # ///获取API的版本信息
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    @staticmethod
    def GetApiVersion(self):
        cdef const_char *result = ''
        try:
            result = CMdApi.GetApiVersion()
        except Exception as err_msg:
            self._write_log('GetApiVersion', err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///获取当前交易日
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def GetTradingDay(self):
        cdef const_char *result = ''
        try:
            if self._api is NULL:
                raise Exception('只有登录成功后,才能得到正确的交易日！')
            with nogil:
                result = self._api.GetTradingDay()
        except Exception as err_msg:
            self._write_log('GetTradingDay', err_msg)
        finally:
          return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    def __dealloc__(self):
        try:
            self.Release()
        except Exception as err_msg:
            self._write_log('__dealloc__', err_msg)

    # ############################################################################# #
    # ///删除接口对象本身
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def Release(self):
        try:
            if self._api is not NULL:
                self._api.RegisterSpi(NULL)
                self._api.Release()
                self._api = NULL
                self._spi = NULL
        except Exception as err_msg:
            self._write_log('Release', err_msg)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///等待接口线程结束运行
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def Join(self):
        cdef int result = -1
        try:
            with nogil:
                result = self._api.Join()
        except Exception as err_msg:
            self._write_log('Join', err_msg)
        finally:
            return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///创建MdApi
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def Init_Base(self):
        cdef int bInit = -1
        try:
            self._api = CreateFtdcMdApi(self.flow_path, self.using_udp, self.multicast)
            if self._api is NULL:
                raise MemoryError()
            self._spi = new CMdSpi(<PyObject *> self)
            if self._spi is NULL:
                raise MemoryError()
            bInit=0
        except Exception as err_msg:
            self._write_log('Init_Base', err_msg)
        finally:
          return bInit

    # ############################################################################# #
    # ///void RegisterSpi()
    # ///注册回调接口
    # ///void Init()
    # ///初始化
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def Init_Net(self):
        cdef int bInit=-1
        try:
            if self._api is NULL or self._spi is NULL:
                raise Exception("行情接口未注册！")
            self._api.RegisterSpi(self._spi)
            if self.RegisterFront(self.md_server) == 0:
                # 初始化成功后OnFrontConnected会被回调
                self._api.Init()
                bInit=0
        except Exception as err_msg:
            self._write_log('Init_Net', err_msg)
        finally:
          return bInit



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///注册前置机网络地址
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def RegisterFront(self, char *pszFrontAddress):
        cdef int result = -1
        try:
            if self._api is not NULL:
                self._api.RegisterFront(pszFrontAddress)
                result = 0
        except Exception as err_msg:
            self._write_log('RegisterFront', err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///注册名字服务器网络地址
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def RegisterNameServer(self, char *pszNsAddress):
        cdef int result = -1
        try:
            if self._api is not NULL:
                self._api.RegisterNameServer(pszNsAddress)
                result = 0
        except Exception as err_msg:
            self._write_log('RegisterNameServer', err_msg)
        finally:
            return result

    # ///注册名字服务器用户信息
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def RegisterFensUserInfo(self, pFensUserInfo):
        cdef int result = -1
        cdef size_t address = 0
        try:
            if self._api is not NULL:
                address = addressof(pFensUserInfo)
                self._api.RegisterFensUserInfo(<CThostFtdcFensUserInfoField *> address)
                result = 0
        except Exception as err_msg:
            self._write_log('RegisterFensUserInfo', err_msg)
        finally:
            return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///当客户端与交易后台建立起通信连接时（还未登录前），该方法被调用。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnFrontConnected(self):
        if self.status == -2:
          self._write_log("OnFrontConnected", "重连成功！")

    # ///当客户端与交易后台通信连接断开时，该方法被调用。当发生这个情况后，API会自动重新连接，客户端可不做处理。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnFrontDisconnected(self, nReason):
        self.status = -2
        self._write_log("OnFrontDisconnected", nReason)

    # ///心跳超时警告。当长时间未收到报文时，该方法被调用。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnHeartBeatWarning(self, nTimeLapse):
        self.status = -2
        self._write_log("OnHeartBeatWarning", nTimeLapse)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///用户登录请求
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def ReqUserLogin(self, pReqUserLoginField):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserLoginField)
                with nogil:
                    result = self._api.ReqUserLogin(<CThostFtdcReqUserLoginField *> pReqUserLoginField, nRequestID)
        except Exception as err_msg:
            self._write_log('ReqUserLogin', err_msg)
        finally:
            return result

    # ///登录请求响应
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspUserLogin(self, pRspUserLogin, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserLogin", pRspUserLogin)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///登出请求
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def ReqUserLogout(self, size_t pUserLogout):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pUserLogout)
                with nogil:
                    result = self._api.ReqUserLogout(<CThostFtdcUserLogoutField *> pUserLogout, nRequestID)
        except Exception as err_msg:
            self._write_log('ReqUserLogout', err_msg)
        finally:
            return result

    # ///登出请求响应
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspUserLogout(self, pUserLogout, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserLogout", pUserLogout)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///订阅行情。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def SubscribeMarketData(self, pInstrumentID):
        cdef int result = -1
        cdef Py_ssize_t count
        cdef char **InstrumentIDs
        try:
            if self._api is not NULL:
                count = len(pInstrumentID)
                if count > 0:
                    InstrumentIDs = <char **> malloc(sizeof(char*) * count)
                    try:
                        for i from 0 <= i < count:
                            InstrumentIDs[i] = pInstrumentID[i]
                        with nogil:
                            result = self._api.SubscribeMarketData(InstrumentIDs, <int>count)
                    finally:
                        free(InstrumentIDs)
        except Exception as err_msg:
            self._write_log('SubscribeMarketData', err_msg)
        finally:
            return result

    # ///订阅行情应答
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspSubMarketData(self, pSpecificInstrument, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspSubMarketData", pSpecificInstrument)

    # ############################################################################# #
    # ///退订行情。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def UnSubscribeMarketData(self, pInstrumentID):
        cdef int result = -1
        cdef Py_ssize_t count
        cdef char **InstrumentIDs
        try:
            if self._api is not NULL:
                count = len(pInstrumentID)
                InstrumentIDs = <char **> malloc(sizeof(char*) * count)
                try:
                    for i from 0 <= i < count:
                        InstrumentIDs[i] = pInstrumentID[i]
                    with nogil:
                        result = self._api.UnSubscribeMarketData(InstrumentIDs, <int>count)
                finally:
                    free(InstrumentIDs)
        except Exception as err_msg:
            self._write_log('UnSubscribeMarketData', err_msg)
        finally:
            return result

    # ///取消订阅行情应答
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspUnSubMarketData(self, pSpecificInstrument, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUnSubMarketData", pSpecificInstrument)

    # ///深度行情通知
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRtnDepthMarketData(self, pDepthMarketData):
        pass


    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///订阅询价。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def SubscribeForQuoteRsp(self, pInstrumentID):
        cdef int result = -1
        cdef Py_ssize_t count
        cdef char **InstrumentIDs
        try:
            if self._api is not NULL:
                count = len(pInstrumentID)
                InstrumentIDs = <char **> malloc(sizeof(char*) * count)
                try:
                    for i from 0 <= i < count:
                        InstrumentIDs[i] = pInstrumentID[i]
                    with nogil:
                        result = self._api.SubscribeForQuoteRsp(InstrumentIDs, <int>count)
                finally:
                    free(InstrumentIDs)
        except Exception as err_msg:
            self._write_log('SubscribeForQuoteRsp', err_msg)
        finally:
            return result

    # ///订阅询价应答
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspSubForQuoteRsp(self, pSpecificInstrument, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspSubForQuoteRsp", pSpecificInstrument)

    # ############################################################################# #
    # ///退订询价。
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def UnSubscribeForQuoteRsp(self, pInstrumentID):
        cdef int result = -1
        cdef Py_ssize_t count
        cdef char **InstrumentIDs
        try:
            if self._api is not NULL:
                count = len(pInstrumentID)
                InstrumentIDs = <char **> malloc(sizeof(char*) * count)
                try:
                    for i from 0 <= i < count:
                        InstrumentIDs[i] = pInstrumentID[i]
                    with nogil:
                        result = self._api.UnSubscribeForQuoteRsp(InstrumentIDs, <int>count)
                finally:
                    free(InstrumentIDs)
        except Exception as err_msg:
            self._write_log('UnSubscribeForQuoteRsp', err_msg)
        finally:
            return result

    # ///取消订阅询价应答
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspUnSubForQuoteRsp(self, pSpecificInstrument, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUnSubForQuoteRsp", pSpecificInstrument)

    # ///询价通知
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRtnForQuoteRsp(self, pForQuoteRsp):
        pass



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///错误应答
    # 《MdApi接口说明》                             | http://ctp.plus/?/article/2
    def OnRspError(self, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspError", pRspInfo)



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# ///当客户端与交易后台建立起通信连接时（还未登录前），该方法被调用。
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnFrontConnected(self) except -1:
    cdef int retVal = -1
    try:
        req_user_login = ReqUserLoginField(BrokerID=self.broker_id
                                           , UserID=self.investor_id
                                           , Password=self.password)
        retVal = self.ReqUserLogin(req_user_login)
        if retVal != 0:
            self._write_log("ReqUserLogin", "登录行情账户失败！", f"返回值:{retVal}", req_user_login)
        self.OnFrontConnected()
    except Exception as err_msg:
        self._write_log('MdSpi_OnFrontConnected', err_msg)

    return 0

# ############################################################################# #
# ///当客户端与交易后台通信连接断开时，该方法被调用。当发生这个情况后，API会自动重新连接，客户端可不做处理。
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnFrontDisconnected(self, int nReason) except -1:
    try:
        self.OnFrontDisconnected(nReason)
    except Exception as err_msg:
        self._write_log('MdSpi_OnFrontDisconnected', err_msg)

    return 0

# ############################################################################# #
# ///心跳超时警告。当长时间未收到报文时，该方法被调用。
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnHeartBeatWarning(self, int nTimeLapse) except -1:

    try:
        self.OnHeartBeatWarning(nTimeLapse)
    except Exception as err_msg:
        self._write_log('MdSpi_OnHeartBeatWarning', err_msg)

    return 0



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# ///登录请求响应
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspUserLogin(self, CThostFtdcRspUserLoginField *pRspUserLogin
                                           , CThostFtdcRspInfoField *pRspInfo
                                           , int nRequestID
                                           , cbool bIsLast) except -1:
    cdef int retVal = -1
    try:
        if pRspUserLogin is not NULL:
            rsp_user_login = RspUserLoginField.from_address(<size_t> pRspUserLogin)
            if pRspInfo is not NULL:
                rsp_info = RspInfoField.from_address(<size_t> pRspInfo)
                if rsp_info.ErrorID == 0:
                    retVal = self.SubscribeMarketData(self.instrument_id_list)
                    if self.instrument_id_list and retVal != 0:
                        self._write_log("SubscribeMarketData", f"订阅行情失败！", f"instrument_id_list:{self.instrument_id_list}")
                    else:
                      self.status = 0
                      self._write_log("MdSpi_OnRspUserLogin", "行情启动完毕！", f"CTP版本号：{self.GetApiVersion(self)}", f"交易日:{self.GetTradingDay()}"
                                      , f"server:{self.md_server}", f"broker_id:{self.broker_id}", f"instrument_id_list:{self.instrument_id_list}")
                else:
                    self._write_log("MdSpi_OnRspUserLogin", "登录行情账户失败！", rsp_info)
            else:
                rsp_info = None
                self._write_log("MdSpi_OnRspUserLogin", "响应信息异常！", rsp_info)

            self.OnRspUserLogin(rsp_user_login
                                , rsp_info
                                , nRequestID
                                , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspUserLogin', err_msg)

    return 0

# ############################################################################# #
# ///登出请求响应
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspUserLogout(self, CThostFtdcUserLogoutField *pUserLogout
                                            , CThostFtdcRspInfoField *pRspInfo
                                            , int nRequestID
                                            , cbool bIsLast) except -1:

    try:
        if pUserLogout is not NULL:
            self.OnRspUserLogout(UserLogoutField.from_address(<size_t> pUserLogout)
                                 , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                 , nRequestID
                                 , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspUserLogout', err_msg)

    return 0



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# ///订阅行情应答
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspSubMarketData(self, CThostFtdcSpecificInstrumentField *pSpecificInstrument
                                               , CThostFtdcRspInfoField *pRspInfo
                                               , int nRequestID
                                               , cbool bIsLast) except -1:

    try:
        if pSpecificInstrument is not NULL:
            self.OnRspSubMarketData(SpecificInstrumentField.from_address(<size_t> pSpecificInstrument)
                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                    , nRequestID
                                    , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspSubMarketData', err_msg)

    return 0

# ############################################################################# #
# ///取消订阅行情应答
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspUnSubMarketData(self, CThostFtdcSpecificInstrumentField *pSpecificInstrument
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pSpecificInstrument is not NULL:
            self.OnRspUnSubMarketData(SpecificInstrumentField.from_address(<size_t> pSpecificInstrument)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspUnSubMarketData', err_msg)

    return 0

# ############################################################################# #
# ///深度行情通知
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRtnDepthMarketData(self, CThostFtdcDepthMarketDataField *pDepthMarketData) except -1:

    try:
        if pDepthMarketData is not NULL:
            self.OnRtnDepthMarketData(DepthMarketDataField.from_address(<size_t> pDepthMarketData))
    except Exception as err_msg:
        self._write_log('MdSpi_OnRtnDepthMarketData', err_msg)

    return 0



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# ///订阅询价应答
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspSubForQuoteRsp(self, CThostFtdcSpecificInstrumentField *pSpecificInstrument
                                                , CThostFtdcRspInfoField *pRspInfo
                                                , int nRequestID
                                                , cbool bIsLast) except -1:

    try:
        if pSpecificInstrument is not NULL:
            self.OnRspSubForQuoteRsp(SpecificInstrumentField.from_address(<size_t> pSpecificInstrument)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspSubForQuoteRsp', err_msg)

    return 0

# ############################################################################# #
# ///取消订阅询价应答
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspUnSubForQuoteRsp(self, CThostFtdcSpecificInstrumentField *pSpecificInstrument
                                                  , CThostFtdcRspInfoField *pRspInfo
                                                  , int nRequestID
                                                  , cbool bIsLast) except -1:

    try:
        if pSpecificInstrument is not NULL:
            self.OnRspUnSubForQuoteRsp(SpecificInstrumentField.from_address(<size_t> pSpecificInstrument)
                                       , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                       , nRequestID
                                       , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspUnSubForQuoteRsp', err_msg)

    return 0

# ############################################################################# #
# ///询价通知
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRtnForQuoteRsp(self, CThostFtdcForQuoteRspField *pForQuoteRsp) except -1:

    try:
        if pForQuoteRsp is not NULL:
            self.OnRtnForQuoteRsp(ForQuoteRspField.from_address(<size_t> pForQuoteRsp))
    except Exception as err_msg:
        self._write_log('MdSpi_OnRtnForQuoteRsp', err_msg)

    return 0



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# ///错误应答
# 《MdApi接口说明》                             | http://ctp.plus/?/article/2
cdef extern int   MdSpi_OnRspError(self, CThostFtdcRspInfoField *pRspInfo
                                       , int nRequestID
                                       , cbool bIsLast) except -1:

    try:
        if pRspInfo is not NULL:
            self.OnRspError(RspInfoField.from_address(<size_t> pRspInfo)
                            , nRequestID
                            , bIsLast)
    except Exception as err_msg:
        self._write_log('MdSpi_OnRspError', err_msg)

    return 0



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
