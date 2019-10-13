# encoding:utf-8
# distutils: language=c++

from cpython     cimport PyObject
from libc.string cimport const_char
from libcpp      cimport bool as cbool

import os
import ctypes
from datetime import datetime

from .cython2c.ThostFtdcUserApiStruct cimport *
from .cython2c.cTraderApi             cimport CTraderSpi, CTraderApi, CreateFtdcTraderApi
from .ApiStruct import *

from AlgoPlus.utils.check_service import  check_service



# ############################################################################# #
# ############################################################################# #
# ############################################################################# #
# 请参阅CTP量化开发社区(www.ctp.plus)发布的《CTP官方接口文档》：
# 《CTP量化投资API手册(0)概述》                      | http://7jia.com/70000.html
# 《CTP量化投资API手册(1)MdApi》                     | http://7jia.com/70001.html
# 《CTP量化投资API手册(2)TraderApi初始化与登录》     | http://7jia.com/70002.html
# 《CTP量化投资API手册(3)TraderApi基础交易》         | http://7jia.com/70003.html
# 《CTP量化投资API手册(4)TraderApi扩展交易》         | http://7jia.com/70004.html
# 《CTP量化投资API手册(5)TraderApi查资金与持仓》     | http://7jia.com/70005.html
# 《CTP量化投资API手册(6)TraderApi查保证金与手续费》 | http://7jia.com/70006.html
# 《CTP量化投资API手册(7)TraderApi期权交易》         | http://7jia.com/70007.html
# 《CTP量化投资API手册(8)TraderApi银行相关》         | http://7jia.com/70008.html
# 《CTP量化投资API手册(9)TraderApi查合约》           | http://7jia.com/70009.html
# 《CTP量化投资API手册(10)TraderApi查其他》          | http://7jia.com/70010.html
# 《CTP量化投资API手册(11)错误信息》                 | http://7jia.com/70011.html
# ############################################################################# #
# ############################################################################# #
# ############################################################################# #

cdef class TraderApi:
    cdef CTraderApi *_api
    cdef CTraderSpi *_spi

    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    def __cinit__(self, td_server, broker_id, investor_id, password, app_id, auth_code, md_queue=None
                 , page_dir='', private_resume_type=2, public_resume_type=2):
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
            self.front_id = None
            self.session_id = None

            # ############################################################################# #
            if isinstance(td_server, bytes):
                self.td_server = (b'' if td_server.startswith(b'tcp://') else b'tcp://') + td_server
            else:
                self.td_server = (('' if td_server.startswith('tcp://') else 'tcp://') + td_server).encode(encoding='utf-8')

            self.broker_id = broker_id if isinstance(broker_id, bytes) else broker_id.encode(encoding='utf-8')
            self.investor_id = investor_id if isinstance(investor_id, bytes) else investor_id.encode(encoding='utf-8')
            self.password = password if isinstance(password, bytes) else password.encode(encoding='utf-8')
            self.app_id = app_id if isinstance(app_id, bytes) else app_id.encode(encoding='utf-8')
            self.auth_code = auth_code if isinstance(auth_code, bytes) else auth_code.encode(encoding='utf-8')

            # ############################################################################# #
            page_dir = page_dir if isinstance(page_dir, str) else page_dir.decode(encoding='utf-8')
            flow_path = (page_dir if page_dir.endswith('\\') else page_dir + '\\') + self.investor_id.decode(encoding='utf-8') + '\\td.con\\'
            tmp_dir = ''
            for dir in flow_path.split('\\'):
                tmp_dir = os.path.join(tmp_dir, dir)
                if not os.path.exists(tmp_dir):
                    os.mkdir(tmp_dir)
            self.flow_path = flow_path.encode(encoding='utf-8')

            self.private_resume_type = private_resume_type
            self.public_resume_type = public_resume_type

            # ############################################################################# #
            if self.Init_Base() != 0:
                raise Exception("Init_Base || 创建TraderApi与TraderSpi失败！")

            # ############################################################################# #
            info_list = self.td_server.split(b":")
            ip = info_list[1][2:].decode(encoding='utf-8')
            port = int(info_list[2])
            if not check_service(ip, port):
                raise Exception(f"check_service || 服务器{self.td_server}未开启！")

            # ############################################################################# #
            if self.Init_Net() != 0:
                raise Exception("Init_Net || 交易初始化失败！")

            self.md_queue = md_queue

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
        print(f"{local_time}{sep}{self.investor_id}.td{sep}{sep.join(map(str, args))}")



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///获取API的版本信息
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    @staticmethod
    def GetApiVersion(self):
        cdef const_char *result = ''
        try:
            result = CTraderApi.GetApiVersion()
        except Exception as err_msg:
            self._write_log('GetApiVersion', err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///获取当前交易日
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def GetTradingDay(self):
        cdef const_char *result = ''
        try:
            with nogil:
                result = self._api.GetTradingDay()
        except Exception as err_msg:
            self._write_log("GetTradingDay", err_msg)
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
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
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
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def Join(self):
        cdef int result = -1
        try:
            with nogil:
                result = self._api.Join()
        except Exception as err_msg:
            self._write_log("Join", err_msg)
        finally:
            return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///void CreateFtdcTraderApi
    # ///创建TraderApi
    # ///void Init()
    # ///初始化
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def Init_Base(self):
        cdef int bInit = -1
        try:
            self._api = CreateFtdcTraderApi(self.flow_path)
            if self._api is NULL:
                raise MemoryError()
            self._spi = new CTraderSpi(<PyObject *> self)
            if self._spi is NULL:
                raise MemoryError()
            bInit = 0
        except Exception as err_msg:
            self._write_log("Init_Base", err_msg)
        finally:
            return bInit

    # ############################################################################# #
    # RegisterSpi(CThostFtdcTraderSpi *pSpi)
    # ///注册回调接口
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def Init_Net(self):
        cdef int bInit = -1
        try:
            if self._api is NULL or self._spi is NULL:
                raise Exception("交易接口未注册！")
            self._api.RegisterSpi(self._spi)
            self.SubscribePrivateTopic(self.private_resume_type)
            self.SubscribePublicTopic( self.public_resume_type)
            self.RegisterFront(self.td_server)
            # 初始化成功后OnFrontConnected会被回调
            self._api.Init()
            bInit = 0
        except Exception as err_msg:
            self._write_log("Init_Net", err_msg)
        finally:
            return bInit



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # SubscribePrivateTopic(THOST_TE_RESUME_TYPE nResumeType)
    # ///订阅私有流。
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def SubscribePrivateTopic(self, THOST_TE_RESUME_TYPE nResumeType):
        try:
            if self._api is not NULL:
                self._api.SubscribePrivateTopic(nResumeType)
        except Exception as err_msg:
            self._write_log("SubscribePrivateTopic", err_msg)

    # ############################################################################# #
    # SubscribePublicTopic(THOST_TE_RESUME_TYPE nResumeType)
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def SubscribePublicTopic(self, THOST_TE_RESUME_TYPE nResumeType):
        try:
            if self._api is not NULL:
                self._api.SubscribePublicTopic(nResumeType)
        except Exception as err_msg:
            self._write_log("SubscribePublicTopic", err_msg)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # RegisterFront(char *pszFrontAddress)
    # ///注册前置机网络地址
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def RegisterFront(self, char *pszFrontAddress):
        try:
            if self._api is not NULL:
                self._api.RegisterFront(pszFrontAddress)
        except Exception as err_msg:
            self._write_log("RegisterFront", err_msg)

    # ############################################################################# #
    # RegisterNameServer(char *pszNsAddress)
    # ///注册名字服务器网络地址
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def RegisterNameServer(self, char *pszNsAddress):
        try:
            if self._api is not NULL:
                self._api.RegisterNameServer(pszNsAddress)
        except Exception as err_msg:
            self._write_log("RegisterNameServer", err_msg)

    # ############################################################################# #
    # RegisterFensUserInfo(CThostFtdcFensUserInfoField * pFensUserInfo)
    # ///注册名字服务器用户信息
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def RegisterFensUserInfo(self, size_t pFensUserInfo):
        try:
            if self._api is not NULL:
                self._api.RegisterFensUserInfo(<CThostFtdcFensUserInfoField *> pFensUserInfo)
        except Exception as err_msg:
            self._write_log("RegisterFensUserInfo", err_msg)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///当客户端与交易后台建立起通信连接时（还未登录前），该方法被调用。
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnFrontConnected(self):
        self._write_log("OnFrontConnected")

    # ############################################################################# #
    # ///当客户端与交易后台通信连接断开时，该方法被调用。当发生这个情况后，API会自动重新连接，客户端可不做处理。
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnFrontDisconnected(self, nReason):
        self._write_log("OnFrontDisconnected", nReason)

    # ############################################################################# #
    # ///心跳超时警告。当长时间未收到报文时，该方法被调用。
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnHeartBeatWarning(self, nTimeLapse):
        self._write_log("OnHeartBeatWarning", nTimeLapse)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqAuthenticate(CThostFtdcReqAuthenticateField *pReqAuthenticateField, int nRequestID)
    # ///客户端认证请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqAuthenticate(self, pReqAuthenticateField):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqAuthenticateField)
                with nogil:
                    result = self._api.ReqAuthenticate(<CThostFtdcReqAuthenticateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqAuthenticate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///客户端认证响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspAuthenticate(self, pRspAuthenticateField, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspAuthenticate", pRspAuthenticateField)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqUserAuthMethod(CThostFtdcReqUserAuthMethodField *pReqUserAuthMethod, int nRequestID)
    # ///查询用户当前支持的认证模式
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserAuthMethod(self, pReqUserAuthMethod):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserAuthMethod)
                with nogil:
                    result = self._api.ReqUserAuthMethod(<CThostFtdcReqUserAuthMethodField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserAuthMethod", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///查询用户当前支持的认证模式的回复
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspUserAuthMethod(self, pRspUserAuthMethod, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserAuthMethod", pRspUserAuthMethod)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # RegisterUserSystemInfo(CThostFtdcUserSystemInfoField *pUserSystemInfo)
    # ///注册用户终端信息，用于中继服务器多连接模式
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def RegisterUserSystemInfo(self, pUserSystemInfo):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pUserSystemInfo)
                with nogil:
                    result = self._api.RegisterUserSystemInfo(<CThostFtdcUserSystemInfoField *> address)
        except Exception as err_msg:
            self._write_log("RegisterUserSystemInfo", err_msg)
        finally:
            return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # SubmitUserSystemInfo(CThostFtdcUserSystemInfoField *pUserSystemInfo)
    # ///上报用户终端信息，用于中继服务器操作员登录模式
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def SubmitUserSystemInfo(self, pUserSystemInfo):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pUserSystemInfo)
                with nogil:
                    result = self._api.SubmitUserSystemInfo(<CThostFtdcUserSystemInfoField *> address)
        except Exception as err_msg:
            self._write_log("SubmitUserSystemInfo", err_msg)
        finally:
            return result



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqUserLogin(CThostFtdcReqUserLoginField *pReqUserLoginField, int nRequestID)
    # ///用户登录请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserLogin(self, pReqUserLogin):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserLogin)
                with nogil:
                    result = self._api.ReqUserLogin(<CThostFtdcReqUserLoginField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserLogin", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ReqUserLoginWithCaptcha(CThostFtdcReqUserLoginWithCaptchaField *pReqUserLoginWithCaptcha, int nRequestID)
    # ///用户发出带有图片验证码的登陆请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserLoginWithCaptcha(self, pReqUserLoginWithCaptcha):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserLoginWithCaptcha)
                with nogil:
                    result = self._api.ReqUserLoginWithCaptcha(<CThostFtdcReqUserLoginWithCaptchaField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserLoginWithCaptcha", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ReqUserLoginWithText(CThostFtdcReqUserLoginWithTextField *pReqUserLoginWithText, int nRequestID)
    # ///用户发出带有短信验证码的登陆请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserLoginWithText(self, pReqUserLoginWithText):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserLoginWithText)
                with nogil:
                    result = self._api.ReqUserLoginWithText(<CThostFtdcReqUserLoginWithTextField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserLoginWithText", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ReqUserLoginWithOTP(CThostFtdcReqUserLoginWithOTPField *pReqUserLoginWithOTP, int nRequestID)
    # ///用户发出带有动态口令的登陆请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserLoginWithOTP(self, pReqUserLoginWithOTP):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqUserLoginWithOTP)
                with nogil:
                    result = self._api.ReqUserLoginWithOTP(<CThostFtdcReqUserLoginWithOTPField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserLoginWithOTP", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///登录请求响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspUserLogin(self, pRspUserLogin, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserLogin", pRspUserLogin)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqGenUserCaptcha(CThostFtdcReqGenUserCaptchaField *pReqGenUserCaptcha, int nRequestID)
    # ///用户发出获取图形验证码请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqGenUserCaptcha(self, pReqGenUserCaptcha):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqGenUserCaptcha)
                with nogil:
                    result = self._api.ReqGenUserCaptcha(<CThostFtdcReqGenUserCaptchaField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqGenUserCaptcha", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///获取图形验证码请求的回复
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspGenUserCaptcha(self, pRspGenUserCaptcha, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspGenUserCaptcha", pRspGenUserCaptcha)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqGenUserText(CThostFtdcReqGenUserTextField *pReqGenUserText, int nRequestID)
    # ///用户发出获取短信验证码请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqGenUserText(self, pReqGenUserText):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqGenUserText)
                with nogil:
                    result = self._api.ReqGenUserText(<CThostFtdcReqGenUserTextField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqGenUserText", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///获取短信验证码请求的回复
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspGenUserText(self, pRspGenUserText, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspGenUserText", pRspGenUserText)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqUserLogout(CThostFtdcUserLogoutField *pUserLogout, int nRequestID)
    # ///登出请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserLogout(self, pUserLogout):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pUserLogout)
                with nogil:
                    result = self._api.ReqUserLogout(<CThostFtdcUserLogoutField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserLogout", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///登出请求响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspUserLogout(self, pUserLogout, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserLogout", pUserLogout)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestor(CThostFtdcQryInvestorField *pQryInvestor, int nRequestID)
    # ///请求查询投资者
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqQryInvestor(self, pQryInvestor):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestor)
                with nogil:
                    result = self._api.ReqQryInvestor(<CThostFtdcQryInvestorField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestor", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspQryInvestor(self, pInvestor, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestor", pInvestor)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqUserPasswordUpdate(CThostFtdcUserPasswordUpdateField *pUserPasswordUpdate, int nRequestID)
    # ///用户口令更新请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqUserPasswordUpdate(self, pUserPasswordUpdate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pUserPasswordUpdate)
                with nogil:
                    result = self._api.ReqUserPasswordUpdate(<CThostFtdcUserPasswordUpdateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqUserPasswordUpdate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///用户口令更新请求响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspUserPasswordUpdate(self, pUserPasswordUpdate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspUserPasswordUpdate", pUserPasswordUpdate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqTradingAccountPasswordUpdate(CThostFtdcTradingAccountPasswordUpdateField *pTradingAccountPasswordUpdate, int nRequestID)
    # ///资金账户口令更新请求
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqTradingAccountPasswordUpdate(self, pTradingAccountPasswordUpdate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pTradingAccountPasswordUpdate)
                with nogil:
                    result = self._api.ReqTradingAccountPasswordUpdate(<CThostFtdcTradingAccountPasswordUpdateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqTradingAccountPasswordUpdate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///资金账户口令更新请求响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspTradingAccountPasswordUpdate(self, pTradingAccountPasswordUpdate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspTradingAccountPasswordUpdate", pTradingAccountPasswordUpdate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQueryCFMMCTradingAccountToken(CThostFtdcQueryCFMMCTradingAccountTokenField *pQueryCFMMCTradingAccountToken, int nRequestID)
    # ///请求查询监控中心用户令牌
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqQueryCFMMCTradingAccountToken(self, pQueryCFMMCTradingAccountToken):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQueryCFMMCTradingAccountToken)
                with nogil:
                    result = self._api.ReqQueryCFMMCTradingAccountToken(<CThostFtdcQueryCFMMCTradingAccountTokenField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQueryCFMMCTradingAccountToken", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询监控中心用户令牌
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspQueryCFMMCTradingAccountToken(self, pQueryCFMMCTradingAccountToken, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQueryCFMMCTradingAccountToken", pQueryCFMMCTradingAccountToken)

    # ############################################################################# #
    # ///保证金监控中心用户令牌
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRtnCFMMCTradingAccountToken(self, pCFMMCTradingAccountToken):
        self._write_log("OnRtnCFMMCTradingAccountToken", pCFMMCTradingAccountToke)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqSettlementInfoConfirm(CThostFtdcSettlementInfoConfirmField *pSettlementInfoConfirm, int nRequestID)
    # ///投资者结算结果确认
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqSettlementInfoConfirm(self, pSettlementInfoConfirm):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pSettlementInfoConfirm)
                with nogil:
                    result = self._api.ReqSettlementInfoConfirm(<CThostFtdcSettlementInfoConfirmField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqSettlementInfoConfirm", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///投资者结算结果确认响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspSettlementInfoConfirm(self, pSettlementInfoConfirm, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspSettlementInfoConfirm", pSettlementInfoConfirm)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySettlementInfoConfirm(CThostFtdcQrySettlementInfoConfirmField *pQrySettlementInfoConfirm, int nRequestID)
    # ///请求查询结算信息确认
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqQrySettlementInfoConfirm(self, pQrySettlementInfoConfirm):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQrySettlementInfoConfirm)
                with nogil:
                    result = self._api.ReqQrySettlementInfoConfirm(<CThostFtdcQrySettlementInfoConfirmField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySettlementInfoConfirm", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询结算信息确认响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspQrySettlementInfoConfirm(self, pSettlementInfoConfirm, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySettlementInfoConfirm", pSettlementInfoConfirm)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySettlementInfo(CThostFtdcQrySettlementInfoField *pQrySettlementInfo, int nRequestID)
    # ///请求查询投资者结算结果
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def ReqQrySettlementInfo(self, pQrySettlementInfo):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQrySettlementInfo)
                with nogil:
                    result = self._api.ReqQrySettlementInfo(<CThostFtdcQrySettlementInfoField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySettlementInfo", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者结算结果响应
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspQrySettlementInfo(self, pSettlementInfo, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySettlementInfo", pSettlementInfo)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///合约交易状态通知
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRtnInstrumentStatus(self, pInstrumentStatus):
        self._write_log("OnRtnInstrumentStatus", pInstrumentStatus)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///错误应答
    # 《CTP量化投资API手册(2)TraderApi初始化与登录》 | http://7jia.com/70002.html
    def OnRspError(self, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspError", pRspInfo)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqOrderInsert(CThostFtdcInputOrderField *pInputOrder, int nRequestID)
    # ///报单录入请求
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def ReqOrderInsert(self, pInputOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputOrder)
                with nogil:
                    result = self._api.ReqOrderInsert(<CThostFtdcInputOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqOrderInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///报单录入请求响应
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRspOrderInsert(self, pInputOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspOrderInsert", pInputOrder)

    # ############################################################################# #
    # ///报单通知
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRtnOrder(self, pOrder):
        self._write_log("OnRtnOrder", pOrder)

    # ############################################################################# #
    # ///成交通知
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRtnTrade(self, pTrade):
        self._write_log("OnRtnTrade", pTrade)

    # ############################################################################# #
    # ///报单录入错误回报
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnErrRtnOrderInsert(self, pInputOrder, pRspInfo):
        self._write_log("OnErrRtnOrderInsert", pInputOrder)

    # ############################################################################# #
    # ///提示条件单校验错误
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRtnErrorConditionalOrder(self, pErrorConditionalOrder):
        self._write_log("OnRtnErrorConditionalOrder", pErrorConditionalOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryOrder(CThostFtdcQryOrderField *pQryOrder, int nRequestID)
    # ///请求查询报单
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def ReqQryOrder(self, pQryOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryOrder)
                with nogil:
                    result = self._api.ReqQryOrder(<CThostFtdcQryOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryOrder", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询报单响应
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRspQryOrder(self, pOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryOrder", pOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTrade(CThostFtdcQryTradeField *pQryTrade, int nRequestID)
    # ///请求查询成交
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def ReqQryTrade(self, pQryTrade):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTrade)
                with nogil:
                    result = self._api.ReqQryTrade(<CThostFtdcQryTradeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTrade", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询成交响应
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRspQryTrade(self, pTrade, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTrade", pTrade)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqOrderAction(CThostFtdcInputOrderActionField *pInputOrderAction, int nRequestID)
    # ///报单操作请求
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def ReqOrderAction(self, pInputOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputOrderAction)
                with nogil:
                    result = self._api.ReqOrderAction(<CThostFtdcInputOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///撤单操作请求响应
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRspOrderAction(self, pInputOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspOrderAction", pInputOrderAction)

    # ############################################################################# #
    # ///撤单操作错误回报
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnErrRtnOrderAction(self, pOrderAction, pRspInfo):
        self._write_log("OnErrRtnOrderAction", pOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqBatchOrderAction(CThostFtdcInputBatchOrderActionField *pInputBatchOrderAction, int nRequestID)
    # ///批量报单操作请求
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def ReqBatchOrderAction(self, pInputBatchOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputBatchOrderAction)
                with nogil:
                    result = self._api.ReqBatchOrderAction(<CThostFtdcInputBatchOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqBatchOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///批量报单操作请求响应
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnRspBatchOrderAction(self, pInputBatchOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspBatchOrderAction", pInputBatchOrderAction)

    # ############################################################################# #
    # ///批量报单操作错误回报
    # 《CTP量化投资API手册(3)TraderApi基础交易》                 | http://7jia.com/70003.html
    def OnErrRtnBatchOrderAction(self, pBatchOrderAction, pRspInfo):
        self._write_log("OnErrRtnBatchOrderAction", pBatchOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqParkedOrderInsert(CThostFtdcParkedOrderField *pParkedOrder, int nRequestID)
    # ///预埋单录入请求
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqParkedOrderInsert(self, pParkedOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pParkedOrder)
                with nogil:
                    result = self._api.ReqParkedOrderInsert(<CThostFtdcParkedOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqParkedOrderInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///预埋单录入请求响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspParkedOrderInsert(self, pParkedOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspParkedOrderInsert", pParkedOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryParkedOrder(CThostFtdcQryParkedOrderField *pQryParkedOrder, int nRequestID)
    # ///请求查询预埋单
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqQryParkedOrder(self, pQryParkedOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryParkedOrder)
                with nogil:
                    result = self._api.ReqQryParkedOrder(<CThostFtdcQryParkedOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryParkedOrder", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询预埋单响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspQryParkedOrder(self, pParkedOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryParkedOrder", pParkedOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqRemoveParkedOrder(CThostFtdcRemoveParkedOrderField *pRemoveParkedOrder, int nRequestID)
    # ///请求删除预埋单
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqRemoveParkedOrder(self, pRemoveParkedOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pRemoveParkedOrder)
                with nogil:
                    result = self._api.ReqRemoveParkedOrder(<CThostFtdcRemoveParkedOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqRemoveParkedOrder", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///删除预埋单响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspRemoveParkedOrder(self, pRemoveParkedOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspRemoveParkedOrder", pRemoveParkedOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqParkedOrderAction(CThostFtdcParkedOrderActionField *pParkedOrderAction, int nRequestID)
    # ///预埋撤单录入请求
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqParkedOrderAction(self, pParkedOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pParkedOrderAction)
                with nogil:
                    result = self._api.ReqParkedOrderAction(<CThostFtdcParkedOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqParkedOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///预埋撤单录入请求响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspParkedOrderAction(self, pParkedOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspParkedOrderAction", pParkedOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryParkedOrderAction(CThostFtdcQryParkedOrderActionField *pQryParkedOrderAction, int nRequestID)
    # ///请求查询预埋撤单
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqQryParkedOrderAction(self, pQryParkedOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryParkedOrderAction)
                with nogil:
                    result = self._api.ReqQryParkedOrderAction(<CThostFtdcQryParkedOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryParkedOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询预埋撤单响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspQryParkedOrderAction(self, pParkedOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryParkedOrderAction", pParkedOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqRemoveParkedOrderAction(CThostFtdcRemoveParkedOrderActionField *pRemoveParkedOrderAction, int nRequestID)
    # ///请求删除预埋撤单
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqRemoveParkedOrderAction(self, pRemoveParkedOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pRemoveParkedOrderAction)
                with nogil:
                    result = self._api.ReqRemoveParkedOrderAction(<CThostFtdcRemoveParkedOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqRemoveParkedOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///删除预埋撤单响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspRemoveParkedOrderAction(self, pRemoveParkedOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspRemoveParkedOrderAction", pRemoveParkedOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqCombActionInsert(CThostFtdcInputCombActionField *pInputCombAction, int nRequestID)
    # ///申请组合录入请求
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqCombActionInsert(self, pInputCombAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputCombAction)
                with nogil:
                    result = self._api.ReqCombActionInsert(<CThostFtdcInputCombActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqCombActionInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///申请组合录入请求响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspCombActionInsert(self, pInputCombAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspCombActionInsert", pInputCombAction)

    # ############################################################################# #
    # ///申请组合通知
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRtnCombAction(self, pCombAction):
        self._write_log("OnRtnCombAction", pCombAction)

    # ############################################################################# #
    # ///申请组合录入错误回报
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnErrRtnCombActionInsert(self, pInputCombAction, pRspInfo):
        self._write_log("OnErrRtnCombActionInsert", pInputCombAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryCombAction(CThostFtdcQryCombActionField *pQryCombAction, int nRequestID)
    # ///请求查询申请组合
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def ReqQryCombAction(self, pQryCombAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryCombAction)
                with nogil:
                    result = self._api.ReqQryCombAction(<CThostFtdcQryCombActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryCombAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询申请组合响应
    # 《CTP量化投资API手册(4)TraderApi扩展交易》                 | http://7jia.com/70004.html
    def OnRspQryCombAction(self, pCombAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryCombAction", pCombAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTradingAccount(CThostFtdcQryTradingAccountField *pQryTradingAccount, int nRequestID)
    # ///请求查询资金账户
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def ReqQryTradingAccount(self, pQryTradingAccount):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTradingAccount)
                with nogil:
                    result = self._api.ReqQryTradingAccount(<CThostFtdcQryTradingAccountField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTradingAccount", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询资金账户响应
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def OnRspQryTradingAccount(self, pTradingAccount, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTradingAccount", pTradingAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySecAgentTradingAccount(CThostFtdcQryTradingAccountField *pQryTradingAccount, int nRequestID)
    # ///请求查询资金账户
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def ReqQrySecAgentTradingAccount(self, pQryTradingAccount):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTradingAccount)
                with nogil:
                    result = self._api.ReqQrySecAgentTradingAccount(<CThostFtdcQryTradingAccountField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySecAgentTradingAccount", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询资金账户响应
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def OnRspQrySecAgentTradingAccount(self, pTradingAccount, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySecAgentTradingAccount", pTradingAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestorPosition(CThostFtdcQryInvestorPositionField *pQryInvestorPosition, int nRequestID)
    # ///请求查询投资者持仓
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def ReqQryInvestorPosition(self, pQryInvestorPosition):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestorPosition)
                with nogil:
                    result = self._api.ReqQryInvestorPosition(<CThostFtdcQryInvestorPositionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestorPosition", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者持仓响应
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def OnRspQryInvestorPosition(self, pInvestorPosition, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestorPosition", pInvestorPosition)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestorPositionDetail(CThostFtdcQryInvestorPositionDetailField *pQryInvestorPositionDetail, int nRequestID)
    # ///请求查询投资者持仓明细
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def ReqQryInvestorPositionDetail(self, pQryInvestorPositionDetail):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestorPositionDetail)
                with nogil:
                    result = self._api.ReqQryInvestorPositionDetail(<CThostFtdcQryInvestorPositionDetailField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestorPositionDetail", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者持仓明细响应
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def OnRspQryInvestorPositionDetail(self, pInvestorPositionDetail, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestorPositionDetail", pInvestorPositionDetail)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestorPositionCombineDetail(CThostFtdcQryInvestorPositionCombineDetailField *pQryInvestorPositionCombineDetail, int nRequestID)
    # ///请求查询投资者持仓明细
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def ReqQryInvestorPositionCombineDetail(self, pQryInvestorPositionCombineDetail):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestorPositionCombineDetail)
                with nogil:
                    result = self._api.ReqQryInvestorPositionCombineDetail(<CThostFtdcQryInvestorPositionCombineDetailField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestorPositionCombineDetail", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者持仓明细响应
    # 《CTP量化投资API手册(5)TraderApi查资金与持仓》           | http://7jia.com/70005.html
    def OnRspQryInvestorPositionCombineDetail(self, pInvestorPositionCombineDetail, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestorPositionCombineDetail", pInvestorPositionCombineDetail)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQuoteInsert(CThostFtdcInputQuoteField *pInputQuote, int nRequestID)
    # ///报价录入请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQuoteInsert(self, pInputQuote):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputQuote)
                with nogil:
                    result = self._api.ReqQuoteInsert(<CThostFtdcInputQuoteField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQuoteInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///报价录入请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQuoteInsert(self, pInputQuote, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQuoteInsert", pInputQuote)

    # ############################################################################# #
    # ///报价通知
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRtnQuote(self, pQuote):
        self._write_log("OnRtnQuote", pQuote)

    # ############################################################################# #
    # ///报价录入错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnQuoteInsert(self, pInputQuote, pRspInfo):
        self._write_log("OnErrRtnQuoteInsert", pInputQuote)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryQuote(CThostFtdcQryQuoteField *pQryQuote, int nRequestID)
    # ///请求查询报价
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQryQuote(self, pQryQuote):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryQuote)
                with nogil:
                    result = self._api.ReqQryQuote(<CThostFtdcQryQuoteField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryQuote", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询报价响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQryQuote(self, pQuote, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryQuote", pQuote)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQuoteAction(CThostFtdcInputQuoteActionField *pInputQuoteAction, int nRequestID)
    # ///报价操作请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQuoteAction(self, pInputQuoteAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputQuoteAction)
                with nogil:
                    result = self._api.ReqQuoteAction(<CThostFtdcInputQuoteActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQuoteAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///报价操作请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQuoteAction(self, pInputQuoteAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQuoteAction", pInputQuoteAction)

    # ############################################################################# #
    # ///报价操作错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnQuoteAction(self, pQuoteAction, pRspInfo):
        self._write_log("OnErrRtnQuoteAction", pQuoteAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqForQuoteInsert(CThostFtdcInputForQuoteField *pInputForQuote, int nRequestID)
    # ///询价录入请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqForQuoteInsert(self, pInputForQuote):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputForQuote)
                with nogil:
                    result = self._api.ReqForQuoteInsert(<CThostFtdcInputForQuoteField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqForQuoteInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///询价录入请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspForQuoteInsert(self, pInputForQuote, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspForQuoteInsert", pInputForQuote)

    # ############################################################################# #
    # ///询价通知
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRtnForQuoteRsp(self, pForQuoteRsp):
        self._write_log("OnRtnForQuoteRsp", pForQuoteRsp)

    # ############################################################################# #
    # ///询价录入错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnForQuoteInsert(self, pInputForQuote, pRspInfo):
        self._write_log("OnErrRtnForQuoteInsert", pInputForQuote)



    # ############################################################################# #
    # ReqQryForQuote(CThostFtdcQryForQuoteField *pQryForQuote, int nRequestID)
    # ///请求查询询价
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQryForQuote(self, pQryForQuote):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryForQuote)
                with nogil:
                    result = self._api.ReqQryForQuote(<CThostFtdcQryForQuoteField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryForQuote", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询询价响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQryForQuote(self, pForQuote, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryForQuote", pForQuote)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqExecOrderInsert(CThostFtdcInputExecOrderField *pInputExecOrder, int nRequestID)
    # ///执行宣告录入请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqExecOrderInsert(self, pInputExecOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputExecOrder)
                with nogil:
                    result = self._api.ReqExecOrderInsert(<CThostFtdcInputExecOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqExecOrderInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///执行宣告录入请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspExecOrderInsert(self, pInputExecOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspExecOrderInsert", pInputExecOrder)

    # ############################################################################# #
    # ///执行宣告通知
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRtnExecOrder(self, pExecOrder):
        self._write_log("OnRtnExecOrder", pExecOrder)

    # ############################################################################# #
    # ///执行宣告录入错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnExecOrderInsert(self, pInputExecOrder, pRspInfo):
        self._write_log("OnErrRtnExecOrderInsert", pInputExecOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryExecOrder(CThostFtdcQryExecOrderField *pQryExecOrder, int nRequestID)
    # ///请求查询执行宣告
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQryExecOrder(self, pQryExecOrder):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryExecOrder)
                with nogil:
                    result = self._api.ReqQryExecOrder(<CThostFtdcQryExecOrderField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryExecOrder", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询执行宣告响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQryExecOrder(self, pExecOrder, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryExecOrder", pExecOrder)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqExecOrderAction(CThostFtdcInputExecOrderActionField *pInputExecOrderAction, int nRequestID)
    # ///执行宣告操作请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqExecOrderAction(self, pInputExecOrderAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputExecOrderAction)
                with nogil:
                    result = self._api.ReqExecOrderAction(<CThostFtdcInputExecOrderActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqExecOrderAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///执行宣告操作请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspExecOrderAction(self, pInputExecOrderAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspExecOrderAction", pInputExecOrderAction)

    # ############################################################################# #
    # ///执行宣告操作错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnExecOrderAction(self, pExecOrderAction, pRspInfo):
        self._write_log("OnErrRtnExecOrderAction", pExecOrderAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqOptionSelfCloseInsert(CThostFtdcInputOptionSelfCloseField *pInputOptionSelfClose, int nRequestID)
    # ///期权自对冲录入请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqOptionSelfCloseInsert(self, pInputOptionSelfClose):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputOptionSelfClose)
                with nogil:
                    result = self._api.ReqOptionSelfCloseInsert(<CThostFtdcInputOptionSelfCloseField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqOptionSelfCloseInsert", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///期权自对冲录入请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspOptionSelfCloseInsert(self, pInputOptionSelfClose, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspOptionSelfCloseInsert", pInputOptionSelfClose)

    # ############################################################################# #
    # ///期权自对冲通知
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRtnOptionSelfClose(self, pOptionSelfClose):
        self._write_log("OnRtnOptionSelfClose", pOptionSelfClose)

    # ############################################################################# #
    # ///期权自对冲录入错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnOptionSelfCloseInsert(self, pInputOptionSelfClose, pRspInfo):
        self._write_log("OnErrRtnOptionSelfCloseInsert", pInputOptionSelfClose)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryOptionSelfClose(CThostFtdcQryOptionSelfCloseField *pQryOptionSelfClose, int nRequestID)
    # ///请求查询期权自对冲
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqQryOptionSelfClose(self, pQryOptionSelfClose):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryOptionSelfClose)
                with nogil:
                    result = self._api.ReqQryOptionSelfClose(<CThostFtdcQryOptionSelfCloseField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryOptionSelfClose", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询期权自对冲响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspQryOptionSelfClose(self, pOptionSelfClose, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryOptionSelfClose", pOptionSelfClose)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqOptionSelfCloseAction(CThostFtdcInputOptionSelfCloseActionField *pInputOptionSelfCloseAction, int nRequestID)
    # ///期权自对冲操作请求
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def ReqOptionSelfCloseAction(self, pInputOptionSelfCloseAction):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pInputOptionSelfCloseAction)
                with nogil:
                    result = self._api.ReqOptionSelfCloseAction(<CThostFtdcInputOptionSelfCloseActionField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqOptionSelfCloseAction", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///期权自对冲操作请求响应
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnRspOptionSelfCloseAction(self, pInputOptionSelfCloseAction, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspOptionSelfCloseAction", pInputOptionSelfCloseAction)

    # ############################################################################# #
    # ///期权自对冲操作错误回报
    # 《CTP量化投资API手册(7)TraderApi期权交易》                 | http://7jia.com/70007.html
    def OnErrRtnOptionSelfCloseAction(self, pOptionSelfCloseAction, pRspInfo):
        self._write_log("OnErrRtnOptionSelfCloseAction", pOptionSelfCloseAction)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqFromBankToFutureByFuture(CThostFtdcReqTransferField *pReqTransfer, int nRequestID)
    # ///期货发起银行资金转期货请求
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqFromBankToFutureByFuture(self, pReqTransfer):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqTransfer)
                with nogil:
                    result = self._api.ReqFromBankToFutureByFuture(<CThostFtdcReqTransferField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqFromBankToFutureByFuture", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///期货发起银行资金转期货应答
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspFromBankToFutureByFuture(self, pReqTransfer, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspFromBankToFutureByFuture", pReqTransfer)

    # ############################################################################# #
    # ///期货发起银行资金转期货通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnFromBankToFutureByFuture(self, pRspTransfer):
        self._write_log("OnRtnFromBankToFutureByFuture", pRspTransfer)

    # ############################################################################# #
    # ///期货发起银行资金转期货错误回报
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnErrRtnBankToFutureByFuture(self, pReqTransfer, pRspInfo):
        self._write_log("OnErrRtnBankToFutureByFuture", pReqTransfer)

    # ############################################################################# #
    # ///期货发起冲正银行转期货请求，银行处理完毕后报盘发回的通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromBankToFutureByFuture(self, pRspRepeal):
        self._write_log("OnRtnRepealFromBankToFutureByFuture", pRspRepeal)

    # ############################################################################# #
    # ///系统运行时期货端手工发起冲正银行转期货请求，银行处理完毕后报盘发回的通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromBankToFutureByFutureManual(self, pRspRepeal):
        self._write_log("OnRtnRepealFromBankToFutureByFutureManual", pRspRepeal)

    # ############################################################################# #
    # ///系统运行时期货端手工发起冲正银行转期货错误回报
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnErrRtnRepealBankToFutureByFutureManual(self, pReqRepeal, pRspInfo):
        self._write_log("OnErrRtnRepealBankToFutureByFutureManual", pReqRepeal)

    # ############################################################################# #
    # ///银行发起银行资金转期货通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnFromBankToFutureByBank(self, pRspTransfer):
        self._write_log("OnRtnFromBankToFutureByBank", pRspTransfer)

    # ############################################################################# #
    # ///银行发起冲正银行转期货通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromBankToFutureByBank(self, pRspRepeal):
        self._write_log("OnRtnRepealFromBankToFutureByBank", pRspRepeal)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqFromFutureToBankByFuture(CThostFtdcReqTransferField *pReqTransfer, int nRequestID)
    # ///期货发起期货资金转银行请求
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqFromFutureToBankByFuture(self, pReqTransfer):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqTransfer)
                with nogil:
                    result = self._api.ReqFromFutureToBankByFuture(<CThostFtdcReqTransferField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqFromFutureToBankByFuture", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///期货发起期货资金转银行应答
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspFromFutureToBankByFuture(self, pReqTransfer, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspFromFutureToBankByFuture", pReqTransfer)

    # ############################################################################# #
    # ///期货发起期货资金转银行通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnFromFutureToBankByFuture(self, pRspTransfer):
        self._write_log("OnRtnFromFutureToBankByFuture", pRspTransfer)

    # ############################################################################# #
    # ///期货发起期货资金转银行错误回报
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnErrRtnFutureToBankByFuture(self, pReqTransfer, pRspInfo):
        self._write_log("OnErrRtnFutureToBankByFuture", pReqTransfer)

    # ############################################################################# #
    # ///期货发起冲正期货转银行请求，银行处理完毕后报盘发回的通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromFutureToBankByFuture(self, pRspRepeal):
        self._write_log("OnRtnRepealFromFutureToBankByFuture", pRspRepeal)

    # ############################################################################# #
    # ///系统运行时期货端手工发起冲正期货转银行请求，银行处理完毕后报盘发回的通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromFutureToBankByFutureManual(self, pRspRepeal):
        self._write_log("OnRtnRepealFromFutureToBankByFutureManual", pRspRepeal)

    # ############################################################################# #
    # ///系统运行时期货端手工发起冲正期货转银行错误回报
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnErrRtnRepealFutureToBankByFutureManual(self, pReqRepeal, pRspInfo):
        self._write_log("OnErrRtnRepealFutureToBankByFutureManual", pReqRepeal)

    # ############################################################################# #
    # ///银行发起期货资金转银行通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnFromFutureToBankByBank(self, pRspTransfer):
        self._write_log("OnRtnFromFutureToBankByBank", pRspTransfer)

    # ############################################################################# #
    # ///银行发起冲正期货转银行通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnRepealFromFutureToBankByBank(self, pRspRepeal):
        self._write_log("OnRtnRepealFromFutureToBankByBank", pRspRepeal)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQueryBankAccountMoneyByFuture(CThostFtdcReqQueryAccountField *pReqQueryAccount, int nRequestID)
    # ///期货发起查询银行余额请求
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqQueryBankAccountMoneyByFuture(self, pReqQueryAccount):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pReqQueryAccount)
                with nogil:
                    result = self._api.ReqQueryBankAccountMoneyByFuture(<CThostFtdcReqQueryAccountField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQueryBankAccountMoneyByFuture", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///期货发起查询银行余额应答
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspQueryBankAccountMoneyByFuture(self, pReqQueryAccount, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQueryBankAccountMoneyByFuture", pReqQueryAccount)

    # ############################################################################# #
    # ///期货发起查询银行余额通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnQueryBankBalanceByFuture(self, pNotifyQueryAccount):
        self._write_log("OnRtnQueryBankBalanceByFuture", pNotifyQueryAccount)

    # ############################################################################# #
    # ///期货发起查询银行余额错误回报
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnErrRtnQueryBankBalanceByFuture(self, pReqQueryAccount, pRspInfo):
        self._write_log("OnErrRtnQueryBankBalanceByFuture", pReqQueryAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTransferSerial(CThostFtdcQryTransferSerialField *pQryTransferSerial, int nRequestID)
    # ///请求查询转帐流水
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqQryTransferSerial(self, pQryTransferSerial):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTransferSerial)
                with nogil:
                    result = self._api.ReqQryTransferSerial(<CThostFtdcQryTransferSerialField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTransferSerial", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询转帐流水响应
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspQryTransferSerial(self, pTransferSerial, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTransferSerial", pTransferSerial)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTransferBank(CThostFtdcQryTransferBankField *pQryTransferBank, int nRequestID)
    # ///请求查询转帐银行
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqQryTransferBank(self, pQryTransferBank):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTransferBank)
                with nogil:
                    result = self._api.ReqQryTransferBank(<CThostFtdcQryTransferBankField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTransferBank", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询转帐银行响应
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspQryTransferBank(self, pTransferBank, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTransferBank", pTransferBank)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryContractBank(CThostFtdcQryContractBankField *pQryContractBank, int nRequestID)
    # ///请求查询签约银行
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqQryContractBank(self, pQryContractBank):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryContractBank)
                with nogil:
                    result = self._api.ReqQryContractBank(<CThostFtdcQryContractBankField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryContractBank", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询签约银行响应
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspQryContractBank(self, pContractBank, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryContractBank", pContractBank)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryAccountregister(CThostFtdcQryAccountregisterField *pQryAccountregister, int nRequestID)
    # ///请求查询银期签约关系
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def ReqQryAccountregister(self, pQryAccountregister):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryAccountregister)
                with nogil:
                    result = self._api.ReqQryAccountregister(<CThostFtdcQryAccountregisterField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryAccountregister", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询银期签约关系响应
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRspQryAccountregister(self, pAccountregister, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryAccountregister", pAccountregister)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///银行发起银期开户通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnOpenAccountByBank(self, pOpenAccount):
        self._write_log("OnRtnOpenAccountByBank", pOpenAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///银行发起银期销户通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnCancelAccountByBank(self, pCancelAccount):
        self._write_log("OnRtnCancelAccountByBank", pCancelAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ///银行发起变更银行账号通知
    # 《CTP量化投资API手册(8)TraderApi银行相关》                 | http://7jia.com/70008.html
    def OnRtnChangeAccountByBank(self, pChangeAccount):
        self._write_log("OnRtnChangeAccountByBank", pChangeAccount)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInstrumentMarginRate(CThostFtdcQryInstrumentMarginRateField *pQryInstrumentMarginRate, int nRequestID)
    # ///请求查询合约保证金率
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryInstrumentMarginRate(self, pQryInstrumentMarginRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInstrumentMarginRate)
                with nogil:
                    result = self._api.ReqQryInstrumentMarginRate(<CThostFtdcQryInstrumentMarginRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInstrumentMarginRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询合约保证金率响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryInstrumentMarginRate(self, pInstrumentMarginRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInstrumentMarginRate", pInstrumentMarginRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestorProductGroupMargin(CThostFtdcQryInvestorProductGroupMarginField *pQryInvestorProductGroupMargin, int nRequestID)
    # ///请求查询投资者品种/跨品种保证金
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryInvestorProductGroupMargin(self, pQryInvestorProductGroupMargin):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestorProductGroupMargin)
                with nogil:
                    result = self._api.ReqQryInvestorProductGroupMargin(<CThostFtdcQryInvestorProductGroupMarginField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestorProductGroupMargin", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资者品种/跨品种保证金响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryInvestorProductGroupMargin(self, pInvestorProductGroupMargin, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestorProductGroupMargin", pInvestorProductGroupMargin)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryExchangeMarginRate(CThostFtdcQryExchangeMarginRateField *pQryExchangeMarginRate, int nRequestID)
    # ///请求查询交易所保证金率
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryExchangeMarginRate(self, pQryExchangeMarginRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryExchangeMarginRate)
                with nogil:
                    result = self._api.ReqQryExchangeMarginRate(<CThostFtdcQryExchangeMarginRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryExchangeMarginRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询交易所保证金率响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryExchangeMarginRate(self, pExchangeMarginRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryExchangeMarginRate", pExchangeMarginRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryExchangeMarginRateAdjust(CThostFtdcQryExchangeMarginRateAdjustField *pQryExchangeMarginRateAdjust, int nRequestID)
    # ///请求查询交易所调整保证金率
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryExchangeMarginRateAdjust(self, pQryExchangeMarginRateAdjust):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryExchangeMarginRateAdjust)
                with nogil:
                    result = self._api.ReqQryExchangeMarginRateAdjust(<CThostFtdcQryExchangeMarginRateAdjustField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryExchangeMarginRateAdjust", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询交易所调整保证金率响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryExchangeMarginRateAdjust(self, pExchangeMarginRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryExchangeMarginRateAdjust", pExchangeMarginRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInstrumentCommissionRate(CThostFtdcQryInstrumentCommissionRateField *pQryInstrumentCommissionRate, int nRequestID)
    # ///请求查询合约手续费率
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryInstrumentCommissionRate(self, pQryInstrumentCommissionRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInstrumentCommissionRate)
                with nogil:
                    result = self._api.ReqQryInstrumentCommissionRate(<CThostFtdcQryInstrumentCommissionRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInstrumentCommissionRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询合约手续费率响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryInstrumentCommissionRate(self, pInstrumentCommissionRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInstrumentCommissionRate", pInstrumentCommissionRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryMMInstrumentCommissionRate(CThostFtdcQryMMInstrumentCommissionRateField *pQryMMInstrumentCommissionRate, int nRequestID)
    # ///请求查询做市商合约手续费率
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryMMInstrumentCommissionRate(self, pQryMMInstrumentCommissionRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryMMInstrumentCommissionRate)
                with nogil:
                    result = self._api.ReqQryMMInstrumentCommissionRate(<CThostFtdcQryMMInstrumentCommissionRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryMMInstrumentCommissionRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询做市商合约手续费率响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryMMInstrumentCommissionRate(self, pMMInstrumentCommissionRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryMMInstrumentCommissionRate", pMMInstrumentCommissionRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInstrumentOrderCommRate(CThostFtdcQryInstrumentOrderCommRateField *pQryInstrumentOrderCommRate, int nRequestID)
    # ///请求查询报单手续费
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryInstrumentOrderCommRate(self, pQryInstrumentOrderCommRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInstrumentOrderCommRate)
                with nogil:
                    result = self._api.ReqQryInstrumentOrderCommRate(<CThostFtdcQryInstrumentOrderCommRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInstrumentOrderCommRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询报单手续费响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryInstrumentOrderCommRate(self, pInstrumentOrderCommRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInstrumentOrderCommRate", pInstrumentOrderCommRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryOptionInstrCommRate(CThostFtdcQryOptionInstrCommRateField *pQryOptionInstrCommRate, int nRequestID)
    # ///请求查询期权合约手续费
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryOptionInstrCommRate(self, pQryOptionInstrCommRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryOptionInstrCommRate)
                with nogil:
                    result = self._api.ReqQryOptionInstrCommRate(<CThostFtdcQryOptionInstrCommRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryOptionInstrCommRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询期权合约手续费响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryOptionInstrCommRate(self, pOptionInstrCommRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryOptionInstrCommRate", pOptionInstrCommRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryMMOptionInstrCommRate(CThostFtdcQryMMOptionInstrCommRateField *pQryMMOptionInstrCommRate, int nRequestID)
    # ///请求查询做市商期权合约手续费
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryMMOptionInstrCommRate(self, pQryMMOptionInstrCommRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryMMOptionInstrCommRate)
                with nogil:
                    result = self._api.ReqQryMMOptionInstrCommRate(<CThostFtdcQryMMOptionInstrCommRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryMMOptionInstrCommRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询做市商期权合约手续费响应
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryMMOptionInstrCommRate(self, pMMOptionInstrCommRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryMMOptionInstrCommRate", pMMOptionInstrCommRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryOptionInstrTradeCost(CThostFtdcQryOptionInstrTradeCostField *pQryOptionInstrTradeCost, int nRequestID)
    # ///请求查询期权交易成本
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def ReqQryOptionInstrTradeCost(self, pQryOptionInstrTradeCost):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryOptionInstrTradeCost)
                with nogil:
                    result = self._api.ReqQryOptionInstrTradeCost(<CThostFtdcQryOptionInstrTradeCostField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryOptionInstrTradeCost", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询期权交易成本
    # 《CTP量化投资API手册(6)TraderApi查保证金与手续费》       | http://7jia.com/70006.html
    def OnRspQryOptionInstrTradeCost(self, pOptionInstrTradeCost, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryOptionInstrTradeCost", pOptionInstrTradeCost)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryExchange(CThostFtdcQryExchangeField *pQryExchange, int nRequestID)
    # ///请求查询交易所
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryExchange(self, pQryExchange):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryExchange)
                with nogil:
                    result = self._api.ReqQryExchange(<CThostFtdcQryExchangeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryExchange", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询交易所响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryExchange(self, pExchange, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryExchange", pExchange)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInstrument(CThostFtdcQryInstrumentField *pQryInstrument, int nRequestID)
    # ///请求查询合约
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryInstrument(self, pQryInstrument):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInstrument)
                with nogil:
                    result = self._api.ReqQryInstrument(<CThostFtdcQryInstrumentField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInstrument", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询合约响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryInstrument(self, pInstrument, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInstrument", pInstrument)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTradingCode(CThostFtdcQryTradingCodeField *pQryTradingCode, int nRequestID)
    # ///请求查询交易编码
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryTradingCode(self, pQryTradingCode):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTradingCode)
                with nogil:
                    result = self._api.ReqQryTradingCode(<CThostFtdcQryTradingCodeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTradingCode", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询交易编码响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryTradingCode(self, pTradingCode, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTradingCode", pTradingCode)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryProduct(CThostFtdcQryProductField *pQryProduct, int nRequestID)
    # ///请求查询产品
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryProduct(self, pQryProduct):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryProduct)
                with nogil:
                    result = self._api.ReqQryProduct(<CThostFtdcQryProductField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryProduct", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询产品响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryProduct(self, pProduct, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryProduct", pProduct)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryProductExchRate(CThostFtdcQryProductExchRateField *pQryProductExchRate, int nRequestID)
    # ///请求查询产品报价汇率
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryProductExchRate(self, pQryProductExchRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryProductExchRate)
                with nogil:
                    result = self._api.ReqQryProductExchRate(<CThostFtdcQryProductExchRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryProductExchRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询产品报价汇率
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryProductExchRate(self, pProductExchRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryProductExchRate", pProductExchRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryProductGroup(CThostFtdcQryProductGroupField *pQryProductGroup, int nRequestID)
    # ///请求查询产品组
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryProductGroup(self, pQryProductGroup):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryProductGroup)
                with nogil:
                    result = self._api.ReqQryProductGroup(<CThostFtdcQryProductGroupField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryProductGroup", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询产品组响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryProductGroup(self, pProductGroup, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryProductGroup", pProductGroup)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryInvestUnit(CThostFtdcQryInvestUnitField *pQryInvestUnit, int nRequestID)
    # ///请求查询投资单元
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryInvestUnit(self, pQryInvestUnit):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryInvestUnit)
                with nogil:
                    result = self._api.ReqQryInvestUnit(<CThostFtdcQryInvestUnitField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryInvestUnit", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询投资单元响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryInvestUnit(self, pInvestUnit, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryInvestUnit", pInvestUnit)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryCombInstrumentGuard(CThostFtdcQryCombInstrumentGuardField *pQryCombInstrumentGuard, int nRequestID)
    # ///请求查询组合合约安全系数
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def ReqQryCombInstrumentGuard(self, pQryCombInstrumentGuard):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryCombInstrumentGuard)
                with nogil:
                    result = self._api.ReqQryCombInstrumentGuard(<CThostFtdcQryCombInstrumentGuardField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryCombInstrumentGuard", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询组合合约安全系数响应
    # 《CTP量化投资API手册(9)TraderApi查合约》             | http://7jia.com/70009.html
    def OnRspQryCombInstrumentGuard(self, pCombInstrumentGuard, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryCombInstrumentGuard", pCombInstrumentGuard)



    # ############################################################################# #
    # ///交易所公告通知
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRtnBulletin(self, pBulletin):
        self._write_log("OnRtnBulletin", pBulletin)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryDepthMarketData(CThostFtdcQryDepthMarketDataField *pQryDepthMarketData, int nRequestID)
    # ///请求查询行情
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryDepthMarketData(self, pQryDepthMarketData):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryDepthMarketData)
                with nogil:
                    result = self._api.ReqQryDepthMarketData(<CThostFtdcQryDepthMarketDataField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryDepthMarketData", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询行情响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryDepthMarketData(self, pDepthMarketData, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryDepthMarketData", pDepthMarketData)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQueryMaxOrderVolume(CThostFtdcQueryMaxOrderVolumeField *pQueryMaxOrderVolume, int nRequestID)
    # ///查询最大报单数量请求
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQueryMaxOrderVolume(self, pQueryMaxOrderVolume):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQueryMaxOrderVolume)
                with nogil:
                    result = self._api.ReqQueryMaxOrderVolume(<CThostFtdcQueryMaxOrderVolumeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQueryMaxOrderVolume", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///查询最大报单数量响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQueryMaxOrderVolume(self, pQueryMaxOrderVolume, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQueryMaxOrderVolume", pQueryMaxOrderVolume)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryEWarrantOffset(CThostFtdcQryEWarrantOffsetField *pQryEWarrantOffset, int nRequestID)
    # ///请求查询仓单折抵信息
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryEWarrantOffset(self, pQryEWarrantOffset):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryEWarrantOffset)
                with nogil:
                  result = self._api.ReqQryEWarrantOffset(<CThostFtdcQryEWarrantOffsetField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryEWarrantOffset", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询仓单折抵信息响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryEWarrantOffset(self, pEWarrantOffset, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryEWarrantOffset", pEWarrantOffset)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryExchangeRate(CThostFtdcQryExchangeRateField *pQryExchangeRate, int nRequestID)
    # ///请求查询汇率
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryExchangeRate(self, pQryExchangeRate):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryExchangeRate)
                with nogil:
                    result = self._api.ReqQryExchangeRate(<CThostFtdcQryExchangeRateField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryExchangeRate", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询汇率响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryExchangeRate(self, pExchangeRate, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryExchangeRate", pExchangeRate)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryNotice(CThostFtdcQryNoticeField *pQryNotice, int nRequestID)
    # ///请求查询客户通知
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryNotice(self, pQryNotice):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryNotice)
                with nogil:
                    result = self._api.ReqQryNotice(<CThostFtdcQryNoticeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryNotice", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询客户通知响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryNotice(self, pNotice, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryNotice", pNotice)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryTradingNotice(CThostFtdcQryTradingNoticeField *pQryTradingNotice, int nRequestID)
    # ///请求查询交易通知
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryTradingNotice(self, pQryTradingNotice):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryTradingNotice)
                with nogil:
                    result = self._api.ReqQryTradingNotice(<CThostFtdcQryTradingNoticeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryTradingNotice", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询交易通知响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryTradingNotice(self, pTradingNotice, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryTradingNotice", pTradingNotice)

    # ############################################################################# #
    # ///交易通知
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRtnTradingNotice(self, pTradingNoticeInfo):
        self._write_log("OnRtnTradingNotice", pTradingNoticeInfo)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryCFMMCTradingAccountKey(CThostFtdcQryCFMMCTradingAccountKeyField *pQryCFMMCTradingAccountKey, int nRequestID)
    # ///请求查询保证金监管系统经纪公司资金账户密钥
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryCFMMCTradingAccountKey(self, pQryCFMMCTradingAccountKey):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryCFMMCTradingAccountKey)
                with nogil:
                    result = self._api.ReqQryCFMMCTradingAccountKey(<CThostFtdcQryCFMMCTradingAccountKeyField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryCFMMCTradingAccountKey", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///查询保证金监管系统经纪公司资金账户密钥响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryCFMMCTradingAccountKey(self, pCFMMCTradingAccountKey, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryCFMMCTradingAccountKey", pCFMMCTradingAccountKey)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryBrokerTradingParams(CThostFtdcQryBrokerTradingParamsField *pQryBrokerTradingParams, int nRequestID)
    # ///请求查询经纪公司交易参数
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryBrokerTradingParams(self, pQryBrokerTradingParams):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryBrokerTradingParams)
                with nogil:
                    result = self._api.ReqQryBrokerTradingParams(<CThostFtdcQryBrokerTradingParamsField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryBrokerTradingParams", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询经纪公司交易参数响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryBrokerTradingParams(self, pBrokerTradingParams, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryBrokerTradingParams", pBrokerTradingParams)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQryBrokerTradingAlgos(CThostFtdcQryBrokerTradingAlgosField *pQryBrokerTradingAlgos, int nRequestID)
    # ///请求查询经纪公司交易算法
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQryBrokerTradingAlgos(self, pQryBrokerTradingAlgos):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQryBrokerTradingAlgos)
                with nogil:
                    result = self._api.ReqQryBrokerTradingAlgos(<CThostFtdcQryBrokerTradingAlgosField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQryBrokerTradingAlgos", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询经纪公司交易算法响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQryBrokerTradingAlgos(self, pBrokerTradingAlgos, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQryBrokerTradingAlgos", pBrokerTradingAlgos)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySecAgentTradeInfo(CThostFtdcQrySecAgentTradeInfoField *pQrySecAgentTradeInfo, int nRequestID)
    # ///请求查询二级代理商信息
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQrySecAgentTradeInfo(self, pQrySecAgentTradeInfo):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQrySecAgentTradeInfo)
                with nogil:
                    result = self._api.ReqQrySecAgentTradeInfo(<CThostFtdcQrySecAgentTradeInfoField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySecAgentTradeInfo", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询二级代理商信息响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQrySecAgentTradeInfo(self, pSecAgentTradeInfo, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySecAgentTradeInfo", pSecAgentTradeInfo)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySecAgentCheckMode(CThostFtdcQrySecAgentCheckModeField *pQrySecAgentCheckMode, int nRequestID)
    # ///请求查询二级代理商资金校验模式
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQrySecAgentCheckMode(self, pQrySecAgentCheckMode):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQrySecAgentCheckMode)
                with nogil:
                    result = self._api.ReqQrySecAgentCheckMode(<CThostFtdcQrySecAgentCheckModeField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySecAgentCheckMode", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询二级代理商资金校验模式响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQrySecAgentCheckMode(self, pSecAgentCheckMode, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySecAgentCheckMode", pSecAgentCheckMode)



    # ############################################################################# #
    # ############################################################################# #
    # ############################################################################# #
    # ReqQrySecAgentACIDMap(CThostFtdcQrySecAgentACIDMapField *pQrySecAgentACIDMap, int nRequestID)
    # ///请求查询二级代理操作员银期权限
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def ReqQrySecAgentACIDMap(self, pQrySecAgentACIDMap):
        cdef int result = -1
        cdef int nRequestID
        cdef size_t address = 0
        try:
            nRequestID = self.Inc_RequestID()
            if self._api is not NULL:
                address = addressof(pQrySecAgentACIDMap)
                with nogil:
                    result = self._api.ReqQrySecAgentACIDMap(<CThostFtdcQrySecAgentACIDMapField *> address, nRequestID)
        except Exception as err_msg:
            self._write_log("ReqQrySecAgentACIDMap", err_msg)
        finally:
            return result

    # ############################################################################# #
    # ///请求查询二级代理操作员银期权限响应
    # 《CTP量化投资API手册(10)TraderApi查其他》                 | http://7jia.com/70010.html
    def OnRspQrySecAgentACIDMap(self, pSecAgentACIDMap, pRspInfo, nRequestID, bIsLast):
        self._write_log("OnRspQrySecAgentACIDMap", pSecAgentACIDMap)



# ///当客户端与交易后台建立起通信连接时（还未登录前），该方法被调用。
cdef extern int   TraderSpi_OnFrontConnected(self) except -1:
    cdef int retVal = -1
    try:
        req_authenticate = ReqAuthenticateField(BrokerID=self.broker_id
                                                , UserID=self.investor_id
                                                , AppID=self.app_id
                                                , AuthCode=self.auth_code)
        retVal = self.ReqAuthenticate(req_authenticate)
        if retVal != 0:
            self._write_log("ReqAuthenticate", "认证申请失败！", f"返回值:{retVal}", req_authenticate)
        self.OnFrontConnected()
    except Exception as err_msg:
        self._write_log("OnFrontConnected", err_msg)

    return 0

# ///当客户端与交易后台通信连接断开时，该方法被调用。当发生这个情况后，API会自动重新连接，客户端可不做处理。
# ///@param nReason 错误原因
# ///        0x1001 网络读失败
# ///        0x1002 网络写失败
# ///        0x2001 接收心跳超时
# ///        0x2002 发送心跳失败
# ///        0x2003 收到错误报文
cdef extern int   TraderSpi_OnFrontDisconnected(self, int nReason) except -1:

    try:
        self.OnFrontDisconnected(nReason)
    except Exception as err_msg:
        self._write_log("OnFrontDisconnected", err_msg)

    return 0

# ///心跳超时警告。当长时间未收到报文时，该方法被调用。
# ///@param nTimeLapse 距离上次接收报文的时间
cdef extern int   TraderSpi_OnHeartBeatWarning(self, int nTimeLapse) except -1:

    try:
        self.OnHeartBeatWarning(nTimeLapse)
    except Exception as err_msg:
        self._write_log("OnHeartBeatWarning", err_msg)

    return 0

# ///客户端认证响应
cdef extern int   TraderSpi_OnRspAuthenticate(self, CThostFtdcRspAuthenticateField *pRspAuthenticateField
                                                  , CThostFtdcRspInfoField *pRspInfo
                                                  , int nRequestID
                                                  , cbool bIsLast) except -1:
    cdef int retVal = -1
    try:
        if pRspAuthenticateField is not NULL:
            rsp_authenticate = RspAuthenticateField.from_address(<size_t> pRspAuthenticateField)
            if pRspInfo is not NULL:
                rsp_info = RspInfoField.from_address(<size_t> pRspInfo)
                if rsp_info.ErrorID == 0:
                    self._write_log("OnRspAuthenticate", f"认证成功:{rsp_authenticate}")

                    req_user_login = ReqUserLoginField(BrokerID=self.broker_id
                                                       , UserID=self.investor_id
                                                       , Password=self.password)
                    retVal = self.ReqUserLogin(req_user_login)
                    if retVal != 0:
                        self._write_log("ReqUserLogin", "登录交易账户失败！", f"返回值:{retVal}", req_user_login)
                else:
                    self._write_log("OnRspAuthenticate", f"认证失败:{rsp_info}")
            else:
                rsp_info = None

            self.OnRspAuthenticate(rsp_authenticate
                                   , rsp_info
                                   , nRequestID
                                   , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspAuthenticate", err_msg)

    return 0

# ///查询用户当前支持的认证模式的回复
cdef extern int   TraderSpi_OnRspUserAuthMethod(self, CThostFtdcRspUserAuthMethodField *pRspUserAuthMethod
                                                    , CThostFtdcRspInfoField *pRspInfo
                                                    , int nRequestID
                                                    , cbool bIsLast) except -1:

    try:
        if pRspUserAuthMethod is not NULL:
            self.OnRspUserAuthMethod(RspUserAuthMethodField.from_address(<size_t> pRspUserAuthMethod)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspUserAuthMethod", err_msg)

    return 0

# ///登录请求响应
cdef extern int   TraderSpi_OnRspUserLogin(self, CThostFtdcRspUserLoginField *pRspUserLogin
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
                  self.front_id = rsp_user_login.FrontID
                  self.session_id = rsp_user_login.SessionID
                  req_settlement_info_confirm = SettlementInfoConfirmField(BrokerID=self.broker_id
                                                                           , InvestorID=self.investor_id)

                  retVal = self.ReqSettlementInfoConfirm(req_settlement_info_confirm)
                  if retVal != 0:
                      self._write_log("ReqSettlementInfoConfirm", "确认结算单失败！", f"返回值:{retVal}", req_settlement_info_confirm)
              else:
                  self._write_log("OnRspUserLogin", "登录交易账户失败！", rsp_info)
            else:
                rsp_info = None

            self.OnRspUserLogin(rsp_user_login
                                , rsp_info
                                , nRequestID
                                , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspUserLogin", err_msg)

    return 0

# ///获取图形验证码请求的回复
cdef extern int   TraderSpi_OnRspGenUserCaptcha(self, CThostFtdcRspGenUserCaptchaField *pRspGenUserCaptcha
                                                    , CThostFtdcRspInfoField *pRspInfo
                                                    , int nRequestID
                                                    , cbool bIsLast) except -1:

    try:
        if pRspGenUserCaptcha is not NULL:
            self.OnRspGenUserCaptcha(RspGenUserCaptchaField.from_address(<size_t> pRspGenUserCaptcha)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspGenUserCaptcha", err_msg)

    return 0

# ///获取短信验证码请求的回复
cdef extern int   TraderSpi_OnRspGenUserText(self, CThostFtdcRspGenUserTextField *pRspGenUserText
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pRspGenUserText is not NULL:
            self.OnRspGenUserText(RspGenUserTextField.from_address(<size_t> pRspGenUserText)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspGenUserText", err_msg)

    return 0

# ///登出请求响应
cdef extern int   TraderSpi_OnRspUserLogout(self, CThostFtdcUserLogoutField *pUserLogout
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
        self._write_log("OnRspUserLogout", err_msg)

    return 0

# ///请求查询投资者响应
cdef extern int   TraderSpi_OnRspQryInvestor(self, CThostFtdcInvestorField *pInvestor
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pInvestor is not NULL:
            self.OnRspQryInvestor(InvestorField.from_address(<size_t> pInvestor)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestor", err_msg)

    return 0

# ///用户口令更新请求响应
cdef extern int   TraderSpi_OnRspUserPasswordUpdate(self, CThostFtdcUserPasswordUpdateField *pUserPasswordUpdate
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pUserPasswordUpdate is not NULL:
            self.OnRspUserPasswordUpdate(UserPasswordUpdateField.from_address(<size_t> pUserPasswordUpdate)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspUserPasswordUpdate", err_msg)

    return 0

# ///资金账户口令更新请求响应
cdef extern int   TraderSpi_OnRspTradingAccountPasswordUpdate(self, CThostFtdcTradingAccountPasswordUpdateField *pTradingAccountPasswordUpdate
                                                                  , CThostFtdcRspInfoField *pRspInfo
                                                                  , int nRequestID
                                                                  , cbool bIsLast) except -1:

    try:
        if pTradingAccountPasswordUpdate is not NULL:
            self.OnRspTradingAccountPasswordUpdate(TradingAccountPasswordUpdateField.from_address(<size_t> pTradingAccountPasswordUpdate)
                                                   , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                   , nRequestID
                                                   , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspTradingAccountPasswordUpdate", err_msg)

    return 0

# ///请求查询监控中心用户令牌
cdef extern int   TraderSpi_OnRspQueryCFMMCTradingAccountToken(self, CThostFtdcQueryCFMMCTradingAccountTokenField *pQueryCFMMCTradingAccountToken
                                                                   , CThostFtdcRspInfoField *pRspInfo
                                                                   , int nRequestID
                                                                   , cbool bIsLast) except -1:

    try:
        if pQueryCFMMCTradingAccountToken is not NULL:
            self.OnRspQueryCFMMCTradingAccountToken(QueryCFMMCTradingAccountTokenField.from_address(<size_t> pQueryCFMMCTradingAccountToken)
                                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                    , nRequestID
                                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQueryCFMMCTradingAccountToken", err_msg)

    return 0

# ///保证金监控中心用户令牌
cdef extern int   TraderSpi_OnRtnCFMMCTradingAccountToken(self, CThostFtdcCFMMCTradingAccountTokenField *pCFMMCTradingAccountToken) except -1:

    try:
        if pCFMMCTradingAccountToken is not NULL:
            self.OnRtnCFMMCTradingAccountToken(CFMMCTradingAccountTokenField.from_address(<size_t> pCFMMCTradingAccountToken))
    except Exception as err_msg:
        self._write_log("OnRtnCFMMCTradingAccountToken", err_msg)

    return 0

# ///投资者结算结果确认响应
cdef extern int   TraderSpi_OnRspSettlementInfoConfirm(self, CThostFtdcSettlementInfoConfirmField *pSettlementInfoConfirm
                                                           , CThostFtdcRspInfoField *pRspInfo
                                                           , int nRequestID
                                                           , cbool bIsLast) except -1:

    try:
        if pSettlementInfoConfirm is not NULL:
            rsp_settlement_info_confirm = SettlementInfoConfirmField.from_address(<size_t> pSettlementInfoConfirm)
            if pRspInfo is not NULL:
                rsp_info = RspInfoField.from_address(<size_t> pRspInfo)
                if rsp_info.ErrorID == 0:
                    # 启动完成
                    self.status = 0
                    self._write_log("交易启动完毕", f"CTP版本号：{self.GetApiVersion(self)}", f"交易日:{self.GetTradingDay()}"
                                    , f"server:{self.td_server}", f"broker_id:{self.broker_id}", f"investor_id:{self.investor_id}")
                else:
                    self._write_log("OnRspSettlementInfoConfirm", "确认结算单失败！", f"CTP版本号：{self.GetApiVersion(self)}", f"交易日:{self.GetTradingDay()}"
                                    , f"server:{self.td_server}", f"broker_id:{self.broker_id}", f"investor_id:{self.investor_id}", rsp_settlement_info_confirm)
            else:
                rsp_info = None

            self.OnRspSettlementInfoConfirm(rsp_settlement_info_confirm
                                            , rsp_info
                                            , nRequestID
                                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspSettlementInfoConfirm", err_msg)

    return 0

# ///请求查询结算信息确认响应
cdef extern int   TraderSpi_OnRspQrySettlementInfoConfirm(self, CThostFtdcSettlementInfoConfirmField *pSettlementInfoConfirm
                                                              , CThostFtdcRspInfoField *pRspInfo
                                                              , int nRequestID
                                                              , cbool bIsLast) except -1:

    try:
        if pSettlementInfoConfirm is not NULL:
            self.OnRspQrySettlementInfoConfirm(SettlementInfoConfirmField.from_address(<size_t> pSettlementInfoConfirm)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                               , nRequestID
                                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySettlementInfoConfirm", err_msg)

    return 0

# ///请求查询投资者结算结果响应
cdef extern int   TraderSpi_OnRspQrySettlementInfo(self, CThostFtdcSettlementInfoField *pSettlementInfo
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pSettlementInfo is not NULL:
            self.OnRspQrySettlementInfo(SettlementInfoField.from_address(<size_t> pSettlementInfo)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySettlementInfo", err_msg)

    return 0

# ///合约交易状态通知
cdef extern int   TraderSpi_OnRtnInstrumentStatus(self, CThostFtdcInstrumentStatusField *pInstrumentStatus) except -1:

    try:
        if pInstrumentStatus is not NULL:
            self.OnRtnInstrumentStatus(InstrumentStatusField.from_address(<size_t> pInstrumentStatus))
    except Exception as err_msg:
        self._write_log("OnRtnInstrumentStatus", err_msg)

    return 0

# ///错误应答
cdef extern int   TraderSpi_OnRspError(self, CThostFtdcRspInfoField *pRspInfo
                                           , int nRequestID
                                           , cbool bIsLast) except -1:

    try:
        if pRspInfo is not NULL:
            self.OnRspError(RspInfoField.from_address(<size_t> pRspInfo)
                            , nRequestID
                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspError", err_msg)

    return 0

# ///报单录入请求响应
cdef extern int   TraderSpi_OnRspOrderInsert(self, CThostFtdcInputOrderField *pInputOrder
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pInputOrder is not NULL:
            self.OnRspOrderInsert(InputOrderField.from_address(<size_t> pInputOrder)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspOrderInsert", err_msg)

    return 0

# ///报单通知
cdef extern int   TraderSpi_OnRtnOrder(self, CThostFtdcOrderField *pOrder) except -1:

    try:
        if pOrder is not NULL:
            self.OnRtnOrder(OrderField.from_address(<size_t> pOrder))
    except Exception as err_msg:
        self._write_log("OnRtnOrder", err_msg)

    return 0

# ///成交通知
cdef extern int   TraderSpi_OnRtnTrade(self, CThostFtdcTradeField *pTrade) except -1:

    try:
        if pTrade is not NULL:
            self.OnRtnTrade(TradeField.from_address(<size_t> pTrade))
    except Exception as err_msg:
        self._write_log("OnRtnTrade", err_msg)

    return 0

# ///报单录入错误回报
cdef extern int   TraderSpi_OnErrRtnOrderInsert(self, CThostFtdcInputOrderField *pInputOrder
                                                    , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputOrder is not NULL:
            self.OnErrRtnOrderInsert(InputOrderField.from_address(<size_t> pInputOrder)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnOrderInsert", err_msg)

    return 0

# ///提示条件单校验错误
cdef extern int   TraderSpi_OnRtnErrorConditionalOrder(self, CThostFtdcErrorConditionalOrderField *pErrorConditionalOrder) except -1:

    try:
        if pErrorConditionalOrder is not NULL:
            self.OnRtnErrorConditionalOrder(ErrorConditionalOrderField.from_address(<size_t> pErrorConditionalOrder))
    except Exception as err_msg:
        self._write_log("OnRtnErrorConditionalOrder", err_msg)

    return 0

# ///请求查询报单响应
cdef extern int   TraderSpi_OnRspQryOrder(self, CThostFtdcOrderField *pOrder
                                              , CThostFtdcRspInfoField *pRspInfo
                                              , int nRequestID
                                              , cbool bIsLast) except -1:

    try:
        if pOrder is not NULL:
            self.OnRspQryOrder(OrderField.from_address(<size_t> pOrder)
                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                               , nRequestID
                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryOrder", err_msg)

    return 0

# ///请求查询成交响应
cdef extern int   TraderSpi_OnRspQryTrade(self, CThostFtdcTradeField *pTrade
                                              , CThostFtdcRspInfoField *pRspInfo
                                              , int nRequestID
                                              , cbool bIsLast) except -1:

    try:
        if pTrade is not NULL:
            self.OnRspQryTrade(TradeField.from_address(<size_t> pTrade)
                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                               , nRequestID
                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTrade", err_msg)

    return 0

# ///报单操作请求响应
cdef extern int   TraderSpi_OnRspOrderAction(self, CThostFtdcInputOrderActionField *pInputOrderAction
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pInputOrderAction is not NULL:
            self.OnRspOrderAction(InputOrderActionField.from_address(<size_t> pInputOrderAction)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspOrderAction", err_msg)

    return 0

# ///报单操作错误回报
cdef extern int   TraderSpi_OnErrRtnOrderAction(self, CThostFtdcOrderActionField *pOrderAction
                                                    , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pOrderAction is not NULL:
            self.OnErrRtnOrderAction(OrderActionField.from_address(<size_t> pOrderAction)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnOrderAction", err_msg)

    return 0

# ///批量报单操作请求响应
cdef extern int   TraderSpi_OnRspBatchOrderAction(self, CThostFtdcInputBatchOrderActionField *pInputBatchOrderAction
                                                      , CThostFtdcRspInfoField *pRspInfo
                                                      , int nRequestID
                                                      , cbool bIsLast) except -1:

    try:
        if pInputBatchOrderAction is not NULL:
            self.OnRspBatchOrderAction(InputBatchOrderActionField.from_address(<size_t> pInputBatchOrderAction)
                                       , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                       , nRequestID
                                       , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspBatchOrderAction", err_msg)

    return 0

# ///批量报单操作错误回报
cdef extern int   TraderSpi_OnErrRtnBatchOrderAction(self, CThostFtdcBatchOrderActionField *pBatchOrderAction
                                                         , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pBatchOrderAction is not NULL:
            self.OnErrRtnBatchOrderAction(BatchOrderActionField.from_address(<size_t> pBatchOrderAction)
                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnBatchOrderAction", err_msg)

    return 0

# ///预埋单录入请求响应
cdef extern int   TraderSpi_OnRspParkedOrderInsert(self, CThostFtdcParkedOrderField *pParkedOrder
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pParkedOrder is not NULL:
            self.OnRspParkedOrderInsert(ParkedOrderField.from_address(<size_t> pParkedOrder)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspParkedOrderInsert", err_msg)

    return 0

# ///请求查询预埋单响应
cdef extern int   TraderSpi_OnRspQryParkedOrder(self, CThostFtdcParkedOrderField *pParkedOrder
                                                    , CThostFtdcRspInfoField *pRspInfo
                                                    , int nRequestID
                                                    , cbool bIsLast) except -1:

    try:
        if pParkedOrder is not NULL:
            self.OnRspQryParkedOrder(ParkedOrderField.from_address(<size_t> pParkedOrder)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryParkedOrder", err_msg)

    return 0

# ///删除预埋单响应
cdef extern int   TraderSpi_OnRspRemoveParkedOrder(self, CThostFtdcRemoveParkedOrderField *pRemoveParkedOrder
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pRemoveParkedOrder is not NULL:
            self.OnRspRemoveParkedOrder(RemoveParkedOrderField.from_address(<size_t> pRemoveParkedOrder)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspRemoveParkedOrder", err_msg)

    return 0

# ///预埋撤单录入请求响应
cdef extern int   TraderSpi_OnRspParkedOrderAction(self, CThostFtdcParkedOrderActionField *pParkedOrderAction
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pParkedOrderAction is not NULL:
            self.OnRspParkedOrderAction(ParkedOrderActionField.from_address(<size_t> pParkedOrderAction)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspParkedOrderAction", err_msg)

    return 0

# ///请求查询预埋撤单响应
cdef extern int   TraderSpi_OnRspQryParkedOrderAction(self, CThostFtdcParkedOrderActionField *pParkedOrderAction
                                                          , CThostFtdcRspInfoField *pRspInfo
                                                          , int nRequestID
                                                          , cbool bIsLast) except -1:

    try:
        if pParkedOrderAction is not NULL:
            self.OnRspQryParkedOrderAction(ParkedOrderActionField.from_address(<size_t> pParkedOrderAction)
                                           , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                           , nRequestID
                                           , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryParkedOrderAction", err_msg)

    return 0

# ///删除预埋撤单响应
cdef extern int   TraderSpi_OnRspRemoveParkedOrderAction(self, CThostFtdcRemoveParkedOrderActionField *pRemoveParkedOrderAction
                                                             , CThostFtdcRspInfoField *pRspInfo
                                                             , int nRequestID
                                                             , cbool bIsLast) except -1:

    try:
        if pRemoveParkedOrderAction is not NULL:
            self.OnRspRemoveParkedOrderAction(RemoveParkedOrderActionField.from_address(<size_t> pRemoveParkedOrderAction)
                                              , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                              , nRequestID
                                              , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspRemoveParkedOrderAction", err_msg)

    return 0

# ///申请组合录入请求响应
cdef extern int   TraderSpi_OnRspCombActionInsert(self, CThostFtdcInputCombActionField *pInputCombAction
                                                      , CThostFtdcRspInfoField *pRspInfo
                                                      , int nRequestID
                                                      , cbool bIsLast) except -1:

    try:
        if pInputCombAction is not NULL:
            self.OnRspCombActionInsert(InputCombActionField.from_address(<size_t> pInputCombAction)
                                       , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                       , nRequestID
                                       , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspCombActionInsert", err_msg)

    return 0

# ///申请组合通知
cdef extern int   TraderSpi_OnRtnCombAction(self, CThostFtdcCombActionField *pCombAction) except -1:

    try:
        if pCombAction is not NULL:
            self.OnRtnCombAction(CombActionField.from_address(<size_t> pCombAction))
    except Exception as err_msg:
        self._write_log("OnRtnCombAction", err_msg)

    return 0

# ///申请组合录入错误回报
cdef extern int   TraderSpi_OnErrRtnCombActionInsert(self, CThostFtdcInputCombActionField *pInputCombAction
                                                         , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputCombAction is not NULL:
            self.OnErrRtnCombActionInsert(InputCombActionField.from_address(<size_t> pInputCombAction)
                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnCombActionInsert", err_msg)

    return 0

# ///请求查询申请组合响应
cdef extern int   TraderSpi_OnRspQryCombAction(self, CThostFtdcCombActionField *pCombAction
                                                   , CThostFtdcRspInfoField *pRspInfo
                                                   , int nRequestID
                                                   , cbool bIsLast) except -1:

    try:
        if pCombAction is not NULL:
            self.OnRspQryCombAction(CombActionField.from_address(<size_t> pCombAction)
                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                    , nRequestID
                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryCombAction", err_msg)

    return 0

# ///请求查询资金账户响应
cdef extern int   TraderSpi_OnRspQryTradingAccount(self, CThostFtdcTradingAccountField *pTradingAccount
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pTradingAccount is not NULL:
            self.OnRspQryTradingAccount(TradingAccountField.from_address(<size_t> pTradingAccount)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTradingAccount", err_msg)

    return 0

# ///请求查询资金账户响应
cdef extern int   TraderSpi_OnRspQrySecAgentTradingAccount(self, CThostFtdcTradingAccountField *pTradingAccount
                                                               , CThostFtdcRspInfoField *pRspInfo
                                                               , int nRequestID
                                                               , cbool bIsLast) except -1:

    try:
        if pTradingAccount is not NULL:
            self.OnRspQrySecAgentTradingAccount(TradingAccountField.from_address(<size_t> pTradingAccount)
                                                , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                , nRequestID
                                                , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySecAgentTradingAccount", err_msg)

    return 0

# ///请求查询投资者持仓响应
cdef extern int   TraderSpi_OnRspQryInvestorPosition(self, CThostFtdcInvestorPositionField *pInvestorPosition
                                                         , CThostFtdcRspInfoField *pRspInfo
                                                         , int nRequestID
                                                         , cbool bIsLast) except -1:

    try:
        if pInvestorPosition is not NULL:
            self.OnRspQryInvestorPosition(InvestorPositionField.from_address(<size_t> pInvestorPosition)
                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                          , nRequestID
                                          , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestorPosition", err_msg)

    return 0

# ///请求查询投资者持仓明细响应
cdef extern int   TraderSpi_OnRspQryInvestorPositionDetail(self, CThostFtdcInvestorPositionDetailField *pInvestorPositionDetail
                                                               , CThostFtdcRspInfoField *pRspInfo
                                                               , int nRequestID
                                                               , cbool bIsLast) except -1:

    try:
        if pInvestorPositionDetail is not NULL:
            self.OnRspQryInvestorPositionDetail(InvestorPositionDetailField.from_address(<size_t> pInvestorPositionDetail)
                                                , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                , nRequestID
                                                , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestorPositionDetail", err_msg)

    return 0

# ///请求查询投资者持仓明细响应
cdef extern int   TraderSpi_OnRspQryInvestorPositionCombineDetail(self, CThostFtdcInvestorPositionCombineDetailField *pInvestorPositionCombineDetail
                                                                      , CThostFtdcRspInfoField *pRspInfo
                                                                      , int nRequestID
                                                                      , cbool bIsLast) except -1:

    try:
        if pInvestorPositionCombineDetail is not NULL:
            self.OnRspQryInvestorPositionCombineDetail(InvestorPositionCombineDetailField.from_address(<size_t> pInvestorPositionCombineDetail)
                                                       , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                       , nRequestID
                                                       , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestorPositionCombineDetail", err_msg)

    return 0

# ///报价录入请求响应
cdef extern int   TraderSpi_OnRspQuoteInsert(self, CThostFtdcInputQuoteField *pInputQuote
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pInputQuote is not NULL:
            self.OnRspQuoteInsert(InputQuoteField.from_address(<size_t> pInputQuote)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQuoteInsert", err_msg)

    return 0

# ///报价通知
cdef extern int   TraderSpi_OnRtnQuote(self, CThostFtdcQuoteField *pQuote) except -1:

    try:
        if pQuote is not NULL:
            self.OnRtnQuote(QuoteField.from_address(<size_t> pQuote))
    except Exception as err_msg:
        self._write_log("OnRtnQuote", err_msg)

    return 0

# ///报价录入错误回报
cdef extern int   TraderSpi_OnErrRtnQuoteInsert(self, CThostFtdcInputQuoteField *pInputQuote
                                                    , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputQuote is not NULL:
            self.OnErrRtnQuoteInsert(InputQuoteField.from_address(<size_t> pInputQuote)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnQuoteInsert", err_msg)

    return 0

# ///请求查询报价响应
cdef extern int   TraderSpi_OnRspQryQuote(self, CThostFtdcQuoteField *pQuote
                                              , CThostFtdcRspInfoField *pRspInfo
                                              , int nRequestID
                                              , cbool bIsLast) except -1:

    try:
        if pQuote is not NULL:
            self.OnRspQryQuote(QuoteField.from_address(<size_t> pQuote)
                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                               , nRequestID
                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryQuote", err_msg)

    return 0

# ///报价操作请求响应
cdef extern int   TraderSpi_OnRspQuoteAction(self, CThostFtdcInputQuoteActionField *pInputQuoteAction
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pInputQuoteAction is not NULL:
            self.OnRspQuoteAction(InputQuoteActionField.from_address(<size_t> pInputQuoteAction)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQuoteAction", err_msg)

    return 0

# ///报价操作错误回报
cdef extern int   TraderSpi_OnErrRtnQuoteAction(self, CThostFtdcQuoteActionField *pQuoteAction
                                                    , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pQuoteAction is not NULL:
            self.OnErrRtnQuoteAction(QuoteActionField.from_address(<size_t> pQuoteAction)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnQuoteAction", err_msg)

    return 0

# ///询价录入请求响应
cdef extern int   TraderSpi_OnRspForQuoteInsert(self, CThostFtdcInputForQuoteField *pInputForQuote
                                                    , CThostFtdcRspInfoField *pRspInfo
                                                    , int nRequestID
                                                    , cbool bIsLast) except -1:

    try:
        if pInputForQuote is not NULL:
            self.OnRspForQuoteInsert(InputForQuoteField.from_address(<size_t> pInputForQuote)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspForQuoteInsert", err_msg)

    return 0

# ///询价通知
cdef extern int   TraderSpi_OnRtnForQuoteRsp(self, CThostFtdcForQuoteRspField *pForQuoteRsp) except -1:

    try:
        if pForQuoteRsp is not NULL:
            self.OnRtnForQuoteRsp(ForQuoteRspField.from_address(<size_t> pForQuoteRsp))
    except Exception as err_msg:
        self._write_log("OnRtnForQuoteRsp", err_msg)

    return 0

# ///询价录入错误回报
cdef extern int   TraderSpi_OnErrRtnForQuoteInsert(self, CThostFtdcInputForQuoteField *pInputForQuote
                                                       , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputForQuote is not NULL:
            self.OnErrRtnForQuoteInsert(InputForQuoteField.from_address(<size_t> pInputForQuote)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnForQuoteInsert", err_msg)

    return 0

# ///请求查询询价响应
cdef extern int   TraderSpi_OnRspQryForQuote(self, CThostFtdcForQuoteField *pForQuote
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pForQuote is not NULL:
            self.OnRspQryForQuote(ForQuoteField.from_address(<size_t> pForQuote)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryForQuote", err_msg)

    return 0

# ///执行宣告录入请求响应
cdef extern int   TraderSpi_OnRspExecOrderInsert(self, CThostFtdcInputExecOrderField *pInputExecOrder
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pInputExecOrder is not NULL:
            self.OnRspExecOrderInsert(InputExecOrderField.from_address(<size_t> pInputExecOrder)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspExecOrderInsert", err_msg)

    return 0

# ///执行宣告通知
cdef extern int   TraderSpi_OnRtnExecOrder(self, CThostFtdcExecOrderField *pExecOrder) except -1:

    try:
        if pExecOrder is not NULL:
            self.OnRtnExecOrder(ExecOrderField.from_address(<size_t> pExecOrder))
    except Exception as err_msg:
        self._write_log("OnRtnExecOrder", err_msg)

    return 0

# ///执行宣告录入错误回报
cdef extern int   TraderSpi_OnErrRtnExecOrderInsert(self, CThostFtdcInputExecOrderField *pInputExecOrder
                                                        , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputExecOrder is not NULL:
            self.OnErrRtnExecOrderInsert(InputExecOrderField.from_address(<size_t> pInputExecOrder)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnExecOrderInsert", err_msg)

    return 0

# ///请求查询执行宣告响应
cdef extern int   TraderSpi_OnRspQryExecOrder(self, CThostFtdcExecOrderField *pExecOrder
                                                  , CThostFtdcRspInfoField *pRspInfo
                                                  , int nRequestID
                                                  , cbool bIsLast) except -1:

    try:
        if pExecOrder is not NULL:
            self.OnRspQryExecOrder(ExecOrderField.from_address(<size_t> pExecOrder)
                                   , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                   , nRequestID
                                   , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryExecOrder", err_msg)

    return 0

# ///执行宣告操作请求响应
cdef extern int   TraderSpi_OnRspExecOrderAction(self, CThostFtdcInputExecOrderActionField *pInputExecOrderAction
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pInputExecOrderAction is not NULL:
            self.OnRspExecOrderAction(InputExecOrderActionField.from_address(<size_t> pInputExecOrderAction)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspExecOrderAction", err_msg)

    return 0

# ///执行宣告操作错误回报
cdef extern int   TraderSpi_OnErrRtnExecOrderAction(self, CThostFtdcExecOrderActionField *pExecOrderAction
                                                        , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pExecOrderAction is not NULL:
            self.OnErrRtnExecOrderAction(ExecOrderActionField.from_address(<size_t> pExecOrderAction)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnExecOrderAction", err_msg)

    return 0

# ///期权自对冲录入请求响应
cdef extern int   TraderSpi_OnRspOptionSelfCloseInsert(self, CThostFtdcInputOptionSelfCloseField *pInputOptionSelfClose
                                                           , CThostFtdcRspInfoField *pRspInfo
                                                           , int nRequestID
                                                           , cbool bIsLast) except -1:

    try:
        if pInputOptionSelfClose is not NULL:
            self.OnRspOptionSelfCloseInsert(InputOptionSelfCloseField.from_address(<size_t> pInputOptionSelfClose)
                                            , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                            , nRequestID
                                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspOptionSelfCloseInsert", err_msg)

    return 0

# ///期权自对冲通知
cdef extern int   TraderSpi_OnRtnOptionSelfClose(self, CThostFtdcOptionSelfCloseField *pOptionSelfClose) except -1:

    try:
        if pOptionSelfClose is not NULL:
            self.OnRtnOptionSelfClose(OptionSelfCloseField.from_address(<size_t> pOptionSelfClose))
    except Exception as err_msg:
        self._write_log("OnRtnOptionSelfClose", err_msg)

    return 0

# ///期权自对冲录入错误回报
cdef extern int   TraderSpi_OnErrRtnOptionSelfCloseInsert(self, CThostFtdcInputOptionSelfCloseField *pInputOptionSelfClose
                                                              , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pInputOptionSelfClose is not NULL:
            self.OnErrRtnOptionSelfCloseInsert(InputOptionSelfCloseField.from_address(<size_t> pInputOptionSelfClose)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnOptionSelfCloseInsert", err_msg)

    return 0

# ///请求查询期权自对冲响应
cdef extern int   TraderSpi_OnRspQryOptionSelfClose(self, CThostFtdcOptionSelfCloseField *pOptionSelfClose
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pOptionSelfClose is not NULL:
            self.OnRspQryOptionSelfClose(OptionSelfCloseField.from_address(<size_t> pOptionSelfClose)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryOptionSelfClose", err_msg)

    return 0

# ///期权自对冲操作请求响应
cdef extern int   TraderSpi_OnRspOptionSelfCloseAction(self, CThostFtdcInputOptionSelfCloseActionField *pInputOptionSelfCloseAction
                                                           , CThostFtdcRspInfoField *pRspInfo
                                                           , int nRequestID
                                                           , cbool bIsLast) except -1:

    try:
        if pInputOptionSelfCloseAction is not NULL:
            self.OnRspOptionSelfCloseAction(InputOptionSelfCloseActionField.from_address(<size_t> pInputOptionSelfCloseAction)
                                            , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                            , nRequestID
                                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspOptionSelfCloseAction", err_msg)

    return 0

# ///期权自对冲操作错误回报
cdef extern int   TraderSpi_OnErrRtnOptionSelfCloseAction(self, CThostFtdcOptionSelfCloseActionField *pOptionSelfCloseAction
                                                              , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pOptionSelfCloseAction is not NULL:
            self.OnErrRtnOptionSelfCloseAction(OptionSelfCloseActionField.from_address(<size_t> pOptionSelfCloseAction)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnOptionSelfCloseAction", err_msg)

    return 0

# ///期货发起银行资金转期货应答
cdef extern int   TraderSpi_OnRspFromBankToFutureByFuture(self, CThostFtdcReqTransferField *pReqTransfer
                                                              , CThostFtdcRspInfoField *pRspInfo
                                                              , int nRequestID
                                                              , cbool bIsLast) except -1:

    try:
        if pReqTransfer is not NULL:
            self.OnRspFromBankToFutureByFuture(ReqTransferField.from_address(<size_t> pReqTransfer)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                               , nRequestID
                                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspFromBankToFutureByFuture", err_msg)

    return 0

# ///期货发起银行资金转期货通知
cdef extern int   TraderSpi_OnRtnFromBankToFutureByFuture(self, CThostFtdcRspTransferField *pRspTransfer) except -1:

    try:
        if pRspTransfer is not NULL:
            self.OnRtnFromBankToFutureByFuture(RspTransferField.from_address(<size_t> pRspTransfer))
    except Exception as err_msg:
        self._write_log("OnRtnFromBankToFutureByFuture", err_msg)

    return 0

# ///期货发起银行资金转期货错误回报
cdef extern int   TraderSpi_OnErrRtnBankToFutureByFuture(self, CThostFtdcReqTransferField *pReqTransfer
                                                             , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pReqTransfer is not NULL:
            self.OnErrRtnBankToFutureByFuture(ReqTransferField.from_address(<size_t> pReqTransfer)
                                              , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnBankToFutureByFuture", err_msg)

    return 0

# ///期货发起冲正银行转期货请求，银行处理完毕后报盘发回的通知
cdef extern int   TraderSpi_OnRtnRepealFromBankToFutureByFuture(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromBankToFutureByFuture(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromBankToFutureByFuture", err_msg)

    return 0

# ///系统运行时期货端手工发起冲正银行转期货请求，银行处理完毕后报盘发回的通知
cdef extern int   TraderSpi_OnRtnRepealFromBankToFutureByFutureManual(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromBankToFutureByFutureManual(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromBankToFutureByFutureManual", err_msg)

    return 0

# ///系统运行时期货端手工发起冲正银行转期货错误回报
cdef extern int   TraderSpi_OnErrRtnRepealBankToFutureByFutureManual(self, CThostFtdcReqRepealField *pReqRepeal
                                                                         , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pReqRepeal is not NULL:
            self.OnErrRtnRepealBankToFutureByFutureManual(ReqRepealField.from_address(<size_t> pReqRepeal)
                                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnRepealBankToFutureByFutureManual", err_msg)

    return 0

# ///银行发起银行资金转期货通知
cdef extern int   TraderSpi_OnRtnFromBankToFutureByBank(self, CThostFtdcRspTransferField *pRspTransfer) except -1:

    try:
        if pRspTransfer is not NULL:
            self.OnRtnFromBankToFutureByBank(RspTransferField.from_address(<size_t> pRspTransfer))
    except Exception as err_msg:
        self._write_log("OnRtnFromBankToFutureByBank", err_msg)

    return 0

# ///银行发起冲正银行转期货通知
cdef extern int   TraderSpi_OnRtnRepealFromBankToFutureByBank(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromBankToFutureByBank(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromBankToFutureByBank", err_msg)

    return 0

# ///期货发起期货资金转银行应答
cdef extern int   TraderSpi_OnRspFromFutureToBankByFuture(self, CThostFtdcReqTransferField *pReqTransfer
                                                              , CThostFtdcRspInfoField *pRspInfo
                                                              , int nRequestID
                                                              , cbool bIsLast) except -1:

    try:
        if pReqTransfer is not NULL:
            self.OnRspFromFutureToBankByFuture(ReqTransferField.from_address(<size_t> pReqTransfer)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                               , nRequestID
                                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspFromFutureToBankByFuture", err_msg)

    return 0

# ///期货发起期货资金转银行通知
cdef extern int   TraderSpi_OnRtnFromFutureToBankByFuture(self, CThostFtdcRspTransferField *pRspTransfer) except -1:

    try:
        if pRspTransfer is not NULL:
            self.OnRtnFromFutureToBankByFuture(RspTransferField.from_address(<size_t> pRspTransfer))
    except Exception as err_msg:
        self._write_log("OnRtnFromFutureToBankByFuture", err_msg)

    return 0

# ///期货发起期货资金转银行错误回报
cdef extern int   TraderSpi_OnErrRtnFutureToBankByFuture(self, CThostFtdcReqTransferField *pReqTransfer
                                                             , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pReqTransfer is not NULL:
            self.OnErrRtnFutureToBankByFuture(ReqTransferField.from_address(<size_t> pReqTransfer)
                                              , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnFutureToBankByFuture", err_msg)

    return 0

# ///期货发起冲正期货转银行请求，银行处理完毕后报盘发回的通知
cdef extern int   TraderSpi_OnRtnRepealFromFutureToBankByFuture(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromFutureToBankByFuture(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromFutureToBankByFuture", err_msg)

    return 0

# ///系统运行时期货端手工发起冲正期货转银行请求，银行处理完毕后报盘发回的通知
cdef extern int   TraderSpi_OnRtnRepealFromFutureToBankByFutureManual(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromFutureToBankByFutureManual(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromFutureToBankByFutureManual", err_msg)

    return 0

# ///系统运行时期货端手工发起冲正期货转银行错误回报
cdef extern int   TraderSpi_OnErrRtnRepealFutureToBankByFutureManual(self, CThostFtdcReqRepealField *pReqRepeal
                                                                         , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pReqRepeal is not NULL:
            self.OnErrRtnRepealFutureToBankByFutureManual(ReqRepealField.from_address(<size_t> pReqRepeal)
                                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnRepealFutureToBankByFutureManual", err_msg)

    return 0

# ///银行发起期货资金转银行通知
cdef extern int   TraderSpi_OnRtnFromFutureToBankByBank(self, CThostFtdcRspTransferField *pRspTransfer) except -1:

    try:
        if pRspTransfer is not NULL:
            self.OnRtnFromFutureToBankByBank(RspTransferField.from_address(<size_t> pRspTransfer))
    except Exception as err_msg:
        self._write_log("OnRtnFromFutureToBankByBank", err_msg)

    return 0

# ///银行发起冲正期货转银行通知
cdef extern int   TraderSpi_OnRtnRepealFromFutureToBankByBank(self, CThostFtdcRspRepealField *pRspRepeal) except -1:

    try:
        if pRspRepeal is not NULL:
            self.OnRtnRepealFromFutureToBankByBank(RspRepealField.from_address(<size_t> pRspRepeal))
    except Exception as err_msg:
        self._write_log("OnRtnRepealFromFutureToBankByBank", err_msg)

    return 0

# ///期货发起查询银行余额应答
cdef extern int   TraderSpi_OnRspQueryBankAccountMoneyByFuture(self, CThostFtdcReqQueryAccountField *pReqQueryAccount
                                                                   , CThostFtdcRspInfoField *pRspInfo
                                                                   , int nRequestID
                                                                   , cbool bIsLast) except -1:

    try:
        if pReqQueryAccount is not NULL:
            self.OnRspQueryBankAccountMoneyByFuture(ReqQueryAccountField.from_address(<size_t> pReqQueryAccount)
                                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                    , nRequestID
                                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQueryBankAccountMoneyByFuture", err_msg)

    return 0

# ///期货发起查询银行余额通知
cdef extern int   TraderSpi_OnRtnQueryBankBalanceByFuture(self, CThostFtdcNotifyQueryAccountField *pNotifyQueryAccount) except -1:

    try:
        if pNotifyQueryAccount is not NULL:
            self.OnRtnQueryBankBalanceByFuture(NotifyQueryAccountField.from_address(<size_t> pNotifyQueryAccount))
    except Exception as err_msg:
        self._write_log("OnRtnQueryBankBalanceByFuture", err_msg)

    return 0

# ///期货发起查询银行余额错误回报
cdef extern int   TraderSpi_OnErrRtnQueryBankBalanceByFuture(self, CThostFtdcReqQueryAccountField *pReqQueryAccount
                                                                 , CThostFtdcRspInfoField *pRspInfo) except -1:

    try:
        if pReqQueryAccount is not NULL:
            self.OnErrRtnQueryBankBalanceByFuture(ReqQueryAccountField.from_address(<size_t> pReqQueryAccount)
                                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo))
    except Exception as err_msg:
        self._write_log("OnErrRtnQueryBankBalanceByFuture", err_msg)

    return 0

# ///请求查询转帐流水响应
cdef extern int   TraderSpi_OnRspQryTransferSerial(self, CThostFtdcTransferSerialField *pTransferSerial
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pTransferSerial is not NULL:
            self.OnRspQryTransferSerial(TransferSerialField.from_address(<size_t> pTransferSerial)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTransferSerial", err_msg)

    return 0

# ///请求查询转帐银行响应
cdef extern int   TraderSpi_OnRspQryTransferBank(self, CThostFtdcTransferBankField *pTransferBank
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pTransferBank is not NULL:
            self.OnRspQryTransferBank(TransferBankField.from_address(<size_t> pTransferBank)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTransferBank", err_msg)

    return 0

# ///请求查询签约银行响应
cdef extern int   TraderSpi_OnRspQryContractBank(self, CThostFtdcContractBankField *pContractBank
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pContractBank is not NULL:
            self.OnRspQryContractBank(ContractBankField.from_address(<size_t> pContractBank)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryContractBank", err_msg)

    return 0

# ///请求查询银期签约关系响应
cdef extern int   TraderSpi_OnRspQryAccountregister(self, CThostFtdcAccountregisterField *pAccountregister
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pAccountregister is not NULL:
            self.OnRspQryAccountregister(AccountregisterField.from_address(<size_t> pAccountregister)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryAccountregister", err_msg)

    return 0

# ///银行发起银期开户通知
cdef extern int   TraderSpi_OnRtnOpenAccountByBank(self, CThostFtdcOpenAccountField *pOpenAccount) except -1:

    try:
        if pOpenAccount is not NULL:
            self.OnRtnOpenAccountByBank(OpenAccountField.from_address(<size_t> pOpenAccount))
    except Exception as err_msg:
        self._write_log("OnRtnOpenAccountByBank", err_msg)

    return 0

# ///银行发起银期销户通知
cdef extern int   TraderSpi_OnRtnCancelAccountByBank(self, CThostFtdcCancelAccountField *pCancelAccount) except -1:

    try:
        if pCancelAccount is not NULL:
            self.OnRtnCancelAccountByBank(CancelAccountField.from_address(<size_t> pCancelAccount))
    except Exception as err_msg:
        self._write_log("OnRtnCancelAccountByBank", err_msg)

    return 0

# ///银行发起变更银行账号通知
cdef extern int   TraderSpi_OnRtnChangeAccountByBank(self, CThostFtdcChangeAccountField *pChangeAccount) except -1:

    try:
        if pChangeAccount is not NULL:
            self.OnRtnChangeAccountByBank(ChangeAccountField.from_address(<size_t> pChangeAccount))
    except Exception as err_msg:
        self._write_log("OnRtnChangeAccountByBank", err_msg)

    return 0

# ///请求查询合约保证金率响应
cdef extern int   TraderSpi_OnRspQryInstrumentMarginRate(self, CThostFtdcInstrumentMarginRateField *pInstrumentMarginRate
                                                             , CThostFtdcRspInfoField *pRspInfo
                                                             , int nRequestID
                                                             , cbool bIsLast) except -1:

    try:
        if pInstrumentMarginRate is not NULL:
            self.OnRspQryInstrumentMarginRate(InstrumentMarginRateField.from_address(<size_t> pInstrumentMarginRate)
                                              , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                              , nRequestID
                                              , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInstrumentMarginRate", err_msg)

    return 0

# ///请求查询投资者品种/跨品种保证金响应
cdef extern int   TraderSpi_OnRspQryInvestorProductGroupMargin(self, CThostFtdcInvestorProductGroupMarginField *pInvestorProductGroupMargin
                                                                   , CThostFtdcRspInfoField *pRspInfo
                                                                   , int nRequestID
                                                                   , cbool bIsLast) except -1:

    try:
        if pInvestorProductGroupMargin is not NULL:
            self.OnRspQryInvestorProductGroupMargin(InvestorProductGroupMarginField.from_address(<size_t> pInvestorProductGroupMargin)
                                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                    , nRequestID
                                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestorProductGroupMargin", err_msg)

    return 0

# ///请求查询交易所保证金率响应
cdef extern int   TraderSpi_OnRspQryExchangeMarginRate(self, CThostFtdcExchangeMarginRateField *pExchangeMarginRate
                                                           , CThostFtdcRspInfoField *pRspInfo
                                                           , int nRequestID
                                                           , cbool bIsLast) except -1:

    try:
        if pExchangeMarginRate is not NULL:
            self.OnRspQryExchangeMarginRate(ExchangeMarginRateField.from_address(<size_t> pExchangeMarginRate)
                                            , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                            , nRequestID
                                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryExchangeMarginRate", err_msg)

    return 0

# ///请求查询交易所调整保证金率响应
cdef extern int   TraderSpi_OnRspQryExchangeMarginRateAdjust(self, CThostFtdcExchangeMarginRateAdjustField *pExchangeMarginRateAdjust
                                                                 , CThostFtdcRspInfoField *pRspInfo
                                                                 , int nRequestID
                                                                 , cbool bIsLast) except -1:

    try:
        if pExchangeMarginRateAdjust is not NULL:
            self.OnRspQryExchangeMarginRateAdjust(ExchangeMarginRateAdjustField.from_address(<size_t> pExchangeMarginRateAdjust)
                                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                  , nRequestID
                                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryExchangeMarginRateAdjust", err_msg)

    return 0

# ///请求查询合约手续费率响应
cdef extern int   TraderSpi_OnRspQryInstrumentCommissionRate(self, CThostFtdcInstrumentCommissionRateField *pInstrumentCommissionRate
                                                                 , CThostFtdcRspInfoField *pRspInfo
                                                                 , int nRequestID
                                                                 , cbool bIsLast) except -1:

    try:
        if pInstrumentCommissionRate is not NULL:
            self.OnRspQryInstrumentCommissionRate(InstrumentCommissionRateField.from_address(<size_t> pInstrumentCommissionRate)
                                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                  , nRequestID
                                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInstrumentCommissionRate", err_msg)

    return 0

# ///请求查询做市商合约手续费率响应
cdef extern int   TraderSpi_OnRspQryMMInstrumentCommissionRate(self, CThostFtdcMMInstrumentCommissionRateField *pMMInstrumentCommissionRate
                                                                   , CThostFtdcRspInfoField *pRspInfo
                                                                   , int nRequestID
                                                                   , cbool bIsLast) except -1:

    try:
        if pMMInstrumentCommissionRate is not NULL:
            self.OnRspQryMMInstrumentCommissionRate(MMInstrumentCommissionRateField.from_address(<size_t> pMMInstrumentCommissionRate)
                                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                    , nRequestID
                                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryMMInstrumentCommissionRate", err_msg)

    return 0

# ///请求查询报单手续费响应
cdef extern int   TraderSpi_OnRspQryInstrumentOrderCommRate(self, CThostFtdcInstrumentOrderCommRateField *pInstrumentOrderCommRate
                                                                , CThostFtdcRspInfoField *pRspInfo
                                                                , int nRequestID
                                                                , cbool bIsLast) except -1:

    try:
        if pInstrumentOrderCommRate is not NULL:
            self.OnRspQryInstrumentOrderCommRate(InstrumentOrderCommRateField.from_address(<size_t> pInstrumentOrderCommRate)
                                                 , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                 , nRequestID
                                                 , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInstrumentOrderCommRate", err_msg)

    return 0

# ///请求查询期权合约手续费响应
cdef extern int   TraderSpi_OnRspQryOptionInstrCommRate(self, CThostFtdcOptionInstrCommRateField *pOptionInstrCommRate
                                                            , CThostFtdcRspInfoField *pRspInfo
                                                            , int nRequestID
                                                            , cbool bIsLast) except -1:

    try:
        if pOptionInstrCommRate is not NULL:
            self.OnRspQryOptionInstrCommRate(OptionInstrCommRateField.from_address(<size_t> pOptionInstrCommRate)
                                             , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                             , nRequestID
                                             , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryOptionInstrCommRate", err_msg)

    return 0

# ///请求查询做市商期权合约手续费响应
cdef extern int   TraderSpi_OnRspQryMMOptionInstrCommRate(self, CThostFtdcMMOptionInstrCommRateField *pMMOptionInstrCommRate
                                                              , CThostFtdcRspInfoField *pRspInfo
                                                              , int nRequestID
                                                              , cbool bIsLast) except -1:

    try:
        if pMMOptionInstrCommRate is not NULL:
            self.OnRspQryMMOptionInstrCommRate(MMOptionInstrCommRateField.from_address(<size_t> pMMOptionInstrCommRate)
                                               , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                               , nRequestID
                                               , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryMMOptionInstrCommRate", err_msg)

    return 0

# ///请求查询期权交易成本响应
cdef extern int   TraderSpi_OnRspQryOptionInstrTradeCost(self, CThostFtdcOptionInstrTradeCostField *pOptionInstrTradeCost
                                                             , CThostFtdcRspInfoField *pRspInfo
                                                             , int nRequestID
                                                             , cbool bIsLast) except -1:

    try:
        if pOptionInstrTradeCost is not NULL:
            self.OnRspQryOptionInstrTradeCost(OptionInstrTradeCostField.from_address(<size_t> pOptionInstrTradeCost)
                                              , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                              , nRequestID
                                              , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryOptionInstrTradeCost", err_msg)

    return 0

# ///请求查询交易所响应
cdef extern int   TraderSpi_OnRspQryExchange(self, CThostFtdcExchangeField *pExchange
                                                 , CThostFtdcRspInfoField *pRspInfo
                                                 , int nRequestID
                                                 , cbool bIsLast) except -1:

    try:
        if pExchange is not NULL:
            self.OnRspQryExchange(ExchangeField.from_address(<size_t> pExchange)
                                  , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                  , nRequestID
                                  , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryExchange", err_msg)

    return 0

# ///请求查询合约响应
cdef extern int   TraderSpi_OnRspQryInstrument(self, CThostFtdcInstrumentField *pInstrument
                                                   , CThostFtdcRspInfoField *pRspInfo
                                                   , int nRequestID
                                                   , cbool bIsLast) except -1:

    try:
        if pInstrument is not NULL:
            self.OnRspQryInstrument(InstrumentField.from_address(<size_t> pInstrument)
                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                    , nRequestID
                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInstrument", err_msg)

    return 0

# ///请求查询交易编码响应
cdef extern int   TraderSpi_OnRspQryTradingCode(self, CThostFtdcTradingCodeField *pTradingCode
                                                    , CThostFtdcRspInfoField *pRspInfo
                                                    , int nRequestID
                                                    , cbool bIsLast) except -1:

    try:
        if pTradingCode is not NULL:
            self.OnRspQryTradingCode(TradingCodeField.from_address(<size_t> pTradingCode)
                                     , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                     , nRequestID
                                     , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTradingCode", err_msg)

    return 0

# ///请求查询产品响应
cdef extern int   TraderSpi_OnRspQryProduct(self, CThostFtdcProductField *pProduct
                                                , CThostFtdcRspInfoField *pRspInfo
                                                , int nRequestID
                                                , cbool bIsLast) except -1:

    try:
        if pProduct is not NULL:
            self.OnRspQryProduct(ProductField.from_address(<size_t> pProduct)
                                 , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                 , nRequestID
                                 , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryProduct", err_msg)

    return 0

# ///请求查询产品报价汇率
cdef extern int   TraderSpi_OnRspQryProductExchRate(self, CThostFtdcProductExchRateField *pProductExchRate
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pProductExchRate is not NULL:
            self.OnRspQryProductExchRate(ProductExchRateField.from_address(<size_t> pProductExchRate)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryProductExchRate", err_msg)

    return 0

# ///请求查询产品组
cdef extern int   TraderSpi_OnRspQryProductGroup(self, CThostFtdcProductGroupField *pProductGroup
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pProductGroup is not NULL:
            self.OnRspQryProductGroup(ProductGroupField.from_address(<size_t> pProductGroup)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryProductGroup", err_msg)

    return 0

# ///请求查询投资单元响应
cdef extern int   TraderSpi_OnRspQryInvestUnit(self, CThostFtdcInvestUnitField *pInvestUnit
                                                   , CThostFtdcRspInfoField *pRspInfo
                                                   , int nRequestID
                                                   , cbool bIsLast) except -1:

    try:
        if pInvestUnit is not NULL:
            self.OnRspQryInvestUnit(InvestUnitField.from_address(<size_t> pInvestUnit)
                                    , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                    , nRequestID
                                    , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryInvestUnit", err_msg)

    return 0

# ///请求查询组合合约安全系数响应
cdef extern int   TraderSpi_OnRspQryCombInstrumentGuard(self, CThostFtdcCombInstrumentGuardField *pCombInstrumentGuard
                                                            , CThostFtdcRspInfoField *pRspInfo
                                                            , int nRequestID
                                                            , cbool bIsLast) except -1:

    try:
        if pCombInstrumentGuard is not NULL:
            self.OnRspQryCombInstrumentGuard(CombInstrumentGuardField.from_address(<size_t> pCombInstrumentGuard)
                                             , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                             , nRequestID
                                             , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryCombInstrumentGuard", err_msg)

    return 0

# ///交易所公告通知
cdef extern int   TraderSpi_OnRtnBulletin(self, CThostFtdcBulletinField *pBulletin) except -1:

    try:
        if pBulletin is not NULL:
            self.OnRtnBulletin(BulletinField.from_address(<size_t> pBulletin))
    except Exception as err_msg:
        self._write_log("OnRtnBulletin", err_msg)

    return 0

# ///请求查询行情响应
cdef extern int   TraderSpi_OnRspQryDepthMarketData(self, CThostFtdcDepthMarketDataField *pDepthMarketData
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pDepthMarketData is not NULL:
            self.OnRspQryDepthMarketData(DepthMarketDataField.from_address(<size_t> pDepthMarketData)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryDepthMarketData", err_msg)

    return 0

# ///查询最大报单数量响应
cdef extern int   TraderSpi_OnRspQueryMaxOrderVolume(self, CThostFtdcQueryMaxOrderVolumeField *pQueryMaxOrderVolume
                                                         , CThostFtdcRspInfoField *pRspInfo
                                                         , int nRequestID
                                                         , cbool bIsLast) except -1:

    try:
        if pQueryMaxOrderVolume is not NULL:
            self.OnRspQueryMaxOrderVolume(QueryMaxOrderVolumeField.from_address(<size_t> pQueryMaxOrderVolume)
                                          , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                          , nRequestID
                                          , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQueryMaxOrderVolume", err_msg)

    return 0

# ///请求查询仓单折抵信息响应
cdef extern int   TraderSpi_OnRspQryEWarrantOffset(self, CThostFtdcEWarrantOffsetField *pEWarrantOffset
                                                       , CThostFtdcRspInfoField *pRspInfo
                                                       , int nRequestID
                                                       , cbool bIsLast) except -1:

    try:
        if pEWarrantOffset is not NULL:
            self.OnRspQryEWarrantOffset(EWarrantOffsetField.from_address(<size_t> pEWarrantOffset)
                                        , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                        , nRequestID
                                        , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryEWarrantOffset", err_msg)

    return 0

# ///请求查询汇率响应
cdef extern int   TraderSpi_OnRspQryExchangeRate(self, CThostFtdcExchangeRateField *pExchangeRate
                                                     , CThostFtdcRspInfoField *pRspInfo
                                                     , int nRequestID
                                                     , cbool bIsLast) except -1:

    try:
        if pExchangeRate is not NULL:
            self.OnRspQryExchangeRate(ExchangeRateField.from_address(<size_t> pExchangeRate)
                                      , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                      , nRequestID
                                      , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryExchangeRate", err_msg)

    return 0

# ///请求查询客户通知响应
cdef extern int   TraderSpi_OnRspQryNotice(self, CThostFtdcNoticeField *pNotice
                                               , CThostFtdcRspInfoField *pRspInfo
                                               , int nRequestID
                                               , cbool bIsLast) except -1:

    try:
        if pNotice is not NULL:
            self.OnRspQryNotice(NoticeField.from_address(<size_t> pNotice)
                                , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                , nRequestID
                                , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryNotice", err_msg)

    return 0

# ///请求查询交易通知响应
cdef extern int   TraderSpi_OnRspQryTradingNotice(self, CThostFtdcTradingNoticeField *pTradingNotice
                                                      , CThostFtdcRspInfoField *pRspInfo
                                                      , int nRequestID
                                                      , cbool bIsLast) except -1:

    try:
        if pTradingNotice is not NULL:
            self.OnRspQryTradingNotice(TradingNoticeField.from_address(<size_t> pTradingNotice)
                                       , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                       , nRequestID
                                       , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryTradingNotice", err_msg)

    return 0

# ///交易通知
cdef extern int   TraderSpi_OnRtnTradingNotice(self, CThostFtdcTradingNoticeInfoField *pTradingNoticeInfo) except -1:

    try:
        if pTradingNoticeInfo is not NULL:
            self.OnRtnTradingNotice(TradingNoticeInfoField.from_address(<size_t> pTradingNoticeInfo))
    except Exception as err_msg:
        self._write_log("OnRtnTradingNotice", err_msg)

    return 0

# ///查询保证金监管系统经纪公司资金账户密钥响应
cdef extern int   TraderSpi_OnRspQryCFMMCTradingAccountKey(self, CThostFtdcCFMMCTradingAccountKeyField *pCFMMCTradingAccountKey
                                                               , CThostFtdcRspInfoField *pRspInfo
                                                               , int nRequestID
                                                               , cbool bIsLast) except -1:

    try:
        if pCFMMCTradingAccountKey is not NULL:
            self.OnRspQryCFMMCTradingAccountKey(CFMMCTradingAccountKeyField.from_address(<size_t> pCFMMCTradingAccountKey)
                                                , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                                , nRequestID
                                                , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryCFMMCTradingAccountKey", err_msg)

    return 0

# ///请求查询经纪公司交易参数响应
cdef extern int   TraderSpi_OnRspQryBrokerTradingParams(self, CThostFtdcBrokerTradingParamsField *pBrokerTradingParams
                                                            , CThostFtdcRspInfoField *pRspInfo
                                                            , int nRequestID
                                                            , cbool bIsLast) except -1:

    try:
        if pBrokerTradingParams is not NULL:
            self.OnRspQryBrokerTradingParams(BrokerTradingParamsField.from_address(<size_t> pBrokerTradingParams)
                                             , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                             , nRequestID
                                             , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryBrokerTradingParams", err_msg)

    return 0

# ///请求查询经纪公司交易算法响应
cdef extern int   TraderSpi_OnRspQryBrokerTradingAlgos(self, CThostFtdcBrokerTradingAlgosField *pBrokerTradingAlgos
                                                           , CThostFtdcRspInfoField *pRspInfo
                                                           , int nRequestID
                                                           , cbool bIsLast) except -1:

    try:
        if pBrokerTradingAlgos is not NULL:
            self.OnRspQryBrokerTradingAlgos(BrokerTradingAlgosField.from_address(<size_t> pBrokerTradingAlgos)
                                            , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                            , nRequestID
                                            , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQryBrokerTradingAlgos", err_msg)

    return 0

# ///请求查询二级代理商信息响应
cdef extern int   TraderSpi_OnRspQrySecAgentTradeInfo(self, CThostFtdcSecAgentTradeInfoField *pSecAgentTradeInfo
                                                          , CThostFtdcRspInfoField *pRspInfo
                                                          , int nRequestID
                                                          , cbool bIsLast) except -1:

    try:
        if pSecAgentTradeInfo is not NULL:
            self.OnRspQrySecAgentTradeInfo(SecAgentTradeInfoField.from_address(<size_t> pSecAgentTradeInfo)
                                           , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                           , nRequestID
                                           , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySecAgentTradeInfo", err_msg)

    return 0

# ///请求查询二级代理商资金校验模式响应
cdef extern int   TraderSpi_OnRspQrySecAgentCheckMode(self, CThostFtdcSecAgentCheckModeField *pSecAgentCheckMode
                                                          , CThostFtdcRspInfoField *pRspInfo
                                                          , int nRequestID
                                                          , cbool bIsLast) except -1:

    try:
        if pSecAgentCheckMode is not NULL:
            self.OnRspQrySecAgentCheckMode(SecAgentCheckModeField.from_address(<size_t> pSecAgentCheckMode)
                                           , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                           , nRequestID
                                           , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySecAgentCheckMode", err_msg)

    return 0

# ///请求查询二级代理操作员银期权限响应
cdef extern int   TraderSpi_OnRspQrySecAgentACIDMap(self, CThostFtdcSecAgentACIDMapField *pSecAgentACIDMap
                                                        , CThostFtdcRspInfoField *pRspInfo
                                                        , int nRequestID
                                                        , cbool bIsLast) except -1:

    try:
        if pSecAgentACIDMap is not NULL:
            self.OnRspQrySecAgentACIDMap(SecAgentACIDMapField.from_address(<size_t> pSecAgentACIDMap)
                                         , None if pRspInfo is NULL else RspInfoField.from_address(<size_t> pRspInfo)
                                         , nRequestID
                                         , bIsLast)
    except Exception as err_msg:
        self._write_log("OnRspQrySecAgentACIDMap", err_msg)

    return 0