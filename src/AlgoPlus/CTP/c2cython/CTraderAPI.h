#ifndef CTraderSpi_H
#define CTraderSpi_H

#include "ThostFtdcTraderApi.h"
#include "MyTools.h"

//������̬��������û��ʵ�֣���Cython��ʵ�֣���ʵ�ֻص� python ����
//Ŀ�ľ��ǽ�� C �ص� python ���룬����ʵ����python��ʵ�ֱ�дҵ���߼�

static inline int TraderSpi_OnFrontConnected(PyObject *);

static inline int TraderSpi_OnFrontDisconnected(PyObject *, int);

static inline int TraderSpi_OnHeartBeatWarning(PyObject *, int);

static inline int TraderSpi_OnRspAuthenticate(PyObject *, CThostFtdcRspAuthenticateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspUserLogin(PyObject *, CThostFtdcRspUserLoginField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspUserLogout(PyObject *, CThostFtdcUserLogoutField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspUserPasswordUpdate(PyObject *, CThostFtdcUserPasswordUpdateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspTradingAccountPasswordUpdate(PyObject *, CThostFtdcTradingAccountPasswordUpdateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspUserAuthMethod(PyObject *, CThostFtdcRspUserAuthMethodField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspGenUserCaptcha(PyObject *, CThostFtdcRspGenUserCaptchaField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspGenUserText(PyObject *, CThostFtdcRspGenUserTextField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspOrderInsert(PyObject *, CThostFtdcInputOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspParkedOrderInsert(PyObject *, CThostFtdcParkedOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspParkedOrderAction(PyObject *, CThostFtdcParkedOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspOrderAction(PyObject *, CThostFtdcInputOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQueryMaxOrderVolume(PyObject *, CThostFtdcQueryMaxOrderVolumeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspSettlementInfoConfirm(PyObject *, CThostFtdcSettlementInfoConfirmField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspRemoveParkedOrder(PyObject *, CThostFtdcRemoveParkedOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspRemoveParkedOrderAction(PyObject *, CThostFtdcRemoveParkedOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspExecOrderInsert(PyObject *, CThostFtdcInputExecOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspExecOrderAction(PyObject *, CThostFtdcInputExecOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspForQuoteInsert(PyObject *, CThostFtdcInputForQuoteField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQuoteInsert(PyObject *, CThostFtdcInputQuoteField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQuoteAction(PyObject *, CThostFtdcInputQuoteActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspBatchOrderAction(PyObject *, CThostFtdcInputBatchOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspOptionSelfCloseInsert(PyObject *, CThostFtdcInputOptionSelfCloseField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspOptionSelfCloseAction(PyObject *, CThostFtdcInputOptionSelfCloseActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspCombActionInsert(PyObject *, CThostFtdcInputCombActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryOrder(PyObject *, CThostFtdcOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTrade(PyObject *, CThostFtdcTradeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestorPosition(PyObject *, CThostFtdcInvestorPositionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTradingAccount(PyObject *, CThostFtdcTradingAccountField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestor(PyObject *, CThostFtdcInvestorField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTradingCode(PyObject *, CThostFtdcTradingCodeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInstrumentMarginRate(PyObject *, CThostFtdcInstrumentMarginRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInstrumentCommissionRate(PyObject *, CThostFtdcInstrumentCommissionRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryExchange(PyObject *, CThostFtdcExchangeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryProduct(PyObject *, CThostFtdcProductField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInstrument(PyObject *, CThostFtdcInstrumentField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryDepthMarketData(PyObject *, CThostFtdcDepthMarketDataField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySettlementInfo(PyObject *, CThostFtdcSettlementInfoField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTransferBank(PyObject *, CThostFtdcTransferBankField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestorPositionDetail(PyObject *, CThostFtdcInvestorPositionDetailField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryNotice(PyObject *, CThostFtdcNoticeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySettlementInfoConfirm(PyObject *, CThostFtdcSettlementInfoConfirmField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestorPositionCombineDetail(PyObject *, CThostFtdcInvestorPositionCombineDetailField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryCFMMCTradingAccountKey(PyObject *, CThostFtdcCFMMCTradingAccountKeyField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryEWarrantOffset(PyObject *, CThostFtdcEWarrantOffsetField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestorProductGroupMargin(PyObject *, CThostFtdcInvestorProductGroupMarginField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryExchangeMarginRate(PyObject *, CThostFtdcExchangeMarginRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryExchangeMarginRateAdjust(PyObject *, CThostFtdcExchangeMarginRateAdjustField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryExchangeRate(PyObject *, CThostFtdcExchangeRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySecAgentACIDMap(PyObject *, CThostFtdcSecAgentACIDMapField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryProductExchRate(PyObject *, CThostFtdcProductExchRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryProductGroup(PyObject *, CThostFtdcProductGroupField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryMMInstrumentCommissionRate(PyObject *, CThostFtdcMMInstrumentCommissionRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryMMOptionInstrCommRate(PyObject *, CThostFtdcMMOptionInstrCommRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInstrumentOrderCommRate(PyObject *, CThostFtdcInstrumentOrderCommRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySecAgentTradingAccount(PyObject *, CThostFtdcTradingAccountField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySecAgentCheckMode(PyObject *, CThostFtdcSecAgentCheckModeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQrySecAgentTradeInfo(PyObject *, CThostFtdcSecAgentTradeInfoField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryOptionInstrTradeCost(PyObject *, CThostFtdcOptionInstrTradeCostField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryOptionInstrCommRate(PyObject *, CThostFtdcOptionInstrCommRateField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryExecOrder(PyObject *, CThostFtdcExecOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryForQuote(PyObject *, CThostFtdcForQuoteField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryQuote(PyObject *, CThostFtdcQuoteField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryOptionSelfClose(PyObject *, CThostFtdcOptionSelfCloseField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryInvestUnit(PyObject *, CThostFtdcInvestUnitField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryCombInstrumentGuard(PyObject *, CThostFtdcCombInstrumentGuardField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryCombAction(PyObject *, CThostFtdcCombActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTransferSerial(PyObject *, CThostFtdcTransferSerialField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryAccountregister(PyObject *, CThostFtdcAccountregisterField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspError(PyObject *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRtnOrder(PyObject *, CThostFtdcOrderField *);

static inline int TraderSpi_OnRtnTrade(PyObject *, CThostFtdcTradeField *);

static inline int TraderSpi_OnErrRtnOrderInsert(PyObject *, CThostFtdcInputOrderField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnOrderAction(PyObject *, CThostFtdcOrderActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnInstrumentStatus(PyObject *, CThostFtdcInstrumentStatusField *);

static inline int TraderSpi_OnRtnBulletin(PyObject *, CThostFtdcBulletinField *);

static inline int TraderSpi_OnRtnTradingNotice(PyObject *, CThostFtdcTradingNoticeInfoField *);

static inline int TraderSpi_OnRtnErrorConditionalOrder(PyObject *, CThostFtdcErrorConditionalOrderField *);

static inline int TraderSpi_OnRtnExecOrder(PyObject *, CThostFtdcExecOrderField *);

static inline int TraderSpi_OnErrRtnExecOrderInsert(PyObject *, CThostFtdcInputExecOrderField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnExecOrderAction(PyObject *, CThostFtdcExecOrderActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnForQuoteInsert(PyObject *, CThostFtdcInputForQuoteField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnQuote(PyObject *, CThostFtdcQuoteField *);

static inline int TraderSpi_OnErrRtnQuoteInsert(PyObject *, CThostFtdcInputQuoteField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnQuoteAction(PyObject *, CThostFtdcQuoteActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnForQuoteRsp(PyObject *, CThostFtdcForQuoteRspField *);

static inline int TraderSpi_OnRtnCFMMCTradingAccountToken(PyObject *, CThostFtdcCFMMCTradingAccountTokenField *);

static inline int TraderSpi_OnErrRtnBatchOrderAction(PyObject *, CThostFtdcBatchOrderActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnOptionSelfClose(PyObject *, CThostFtdcOptionSelfCloseField *);

static inline int TraderSpi_OnErrRtnOptionSelfCloseInsert(PyObject *, CThostFtdcInputOptionSelfCloseField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnOptionSelfCloseAction(PyObject *, CThostFtdcOptionSelfCloseActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnCombAction(PyObject *, CThostFtdcCombActionField *);

static inline int TraderSpi_OnErrRtnCombActionInsert(PyObject *, CThostFtdcInputCombActionField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRspQryContractBank(PyObject *, CThostFtdcContractBankField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryParkedOrder(PyObject *, CThostFtdcParkedOrderField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryParkedOrderAction(PyObject *, CThostFtdcParkedOrderActionField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryTradingNotice(PyObject *, CThostFtdcTradingNoticeField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryBrokerTradingParams(PyObject *, CThostFtdcBrokerTradingParamsField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQryBrokerTradingAlgos(PyObject *, CThostFtdcBrokerTradingAlgosField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQueryCFMMCTradingAccountToken(PyObject *, CThostFtdcQueryCFMMCTradingAccountTokenField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRtnFromBankToFutureByBank(PyObject *, CThostFtdcRspTransferField *);

static inline int TraderSpi_OnRtnFromFutureToBankByBank(PyObject *, CThostFtdcRspTransferField *);

static inline int TraderSpi_OnRtnRepealFromBankToFutureByBank(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRtnRepealFromFutureToBankByBank(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRtnFromBankToFutureByFuture(PyObject *, CThostFtdcRspTransferField *);

static inline int TraderSpi_OnRtnFromFutureToBankByFuture(PyObject *, CThostFtdcRspTransferField *);

static inline int TraderSpi_OnRtnRepealFromBankToFutureByFutureManual(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRtnRepealFromFutureToBankByFutureManual(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRtnQueryBankBalanceByFuture(PyObject *, CThostFtdcNotifyQueryAccountField *);

static inline int TraderSpi_OnErrRtnBankToFutureByFuture(PyObject *, CThostFtdcReqTransferField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnFutureToBankByFuture(PyObject *, CThostFtdcReqTransferField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnRepealBankToFutureByFutureManual(PyObject *, CThostFtdcReqRepealField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnRepealFutureToBankByFutureManual(PyObject *, CThostFtdcReqRepealField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnErrRtnQueryBankBalanceByFuture(PyObject *, CThostFtdcReqQueryAccountField *, CThostFtdcRspInfoField *);

static inline int TraderSpi_OnRtnRepealFromBankToFutureByFuture(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRtnRepealFromFutureToBankByFuture(PyObject *, CThostFtdcRspRepealField *);

static inline int TraderSpi_OnRspFromBankToFutureByFuture(PyObject *, CThostFtdcReqTransferField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspFromFutureToBankByFuture(PyObject *, CThostFtdcReqTransferField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRspQueryBankAccountMoneyByFuture(PyObject *, CThostFtdcReqQueryAccountField *, CThostFtdcRspInfoField *, int, bool);

static inline int TraderSpi_OnRtnOpenAccountByBank(PyObject *, CThostFtdcOpenAccountField *);

static inline int TraderSpi_OnRtnCancelAccountByBank(PyObject *, CThostFtdcCancelAccountField *);

static inline int TraderSpi_OnRtnChangeAccountByBank(PyObject *, CThostFtdcChangeAccountField *);

#define Python_GIL(func) \
  do { \
    PyGILState_STATE gil_state = PyGILState_Ensure(); \
    if ((func) == -1) PyErr_Print();  \
    PyGILState_Release(gil_state); \
  } while (false)

class CTraderSpi : public CThostFtdcTraderSpi{
public:

  CTraderSpi(PyObject *obj):self(obj) {};

  virtual ~CTraderSpi() {};

  ///���ͻ����뽻�׺�̨������ͨ������ʱ����δ��¼ǰ�����÷��������á�
  virtual void  OnFrontConnected() {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    TraderSpi_OnFrontConnected(self);

  };

  ///���ͻ����뽻�׺�̨ͨ�����ӶϿ�ʱ���÷��������á���������������API���Զ��������ӣ��ͻ��˿ɲ���������
  ///@param nReason ����ԭ��
  ///0x1001 �����ʧ��
  ///0x1002 ����дʧ��
  ///0x2001 ����������ʱ
  ///0x2002 ��������ʧ��
  ///0x2003 �յ�������
  virtual void  OnFrontDisconnected(int nReason) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    TraderSpi_OnFrontDisconnected(self, nReason);

  };

  ///������ʱ���档����ʱ��δ�յ�����ʱ���÷��������á�
  ///@param nTimeLapse �����ϴν��ձ��ĵ�ʱ��
  virtual void  OnHeartBeatWarning(int nTimeLapse) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    TraderSpi_OnHeartBeatWarning(self, nTimeLapse);

  };

  ///�ͻ�����֤��Ӧ
  virtual void  OnRspAuthenticate(CThostFtdcRspAuthenticateField *pRspAuthenticateField, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspAuthenticateField)
    {
      return;
    }

    TraderSpi_OnRspAuthenticate(self, pRspAuthenticateField, pRspInfo, nRequestID, bIsLast);

  };

  ///��¼������Ӧ
  virtual void  OnRspUserLogin(CThostFtdcRspUserLoginField *pRspUserLogin, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspUserLogin)
    {
      return;
    }

    TraderSpi_OnRspUserLogin(self, pRspUserLogin, pRspInfo, nRequestID, bIsLast);

  };

  ///�ǳ�������Ӧ
  virtual void  OnRspUserLogout(CThostFtdcUserLogoutField *pUserLogout, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pUserLogout) { return; }

    TraderSpi_OnRspUserLogout(self, pUserLogout, pRspInfo, nRequestID, bIsLast);

  };

  ///�û��������������Ӧ
  virtual void  OnRspUserPasswordUpdate(CThostFtdcUserPasswordUpdateField *pUserPasswordUpdate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;


    if (NULL==pUserPasswordUpdate)
    {
      return;
    }

    TraderSpi_OnRspUserPasswordUpdate(self, pUserPasswordUpdate, pRspInfo, nRequestID, bIsLast);

  };

  ///�ʽ��˻��������������Ӧ
  virtual void  OnRspTradingAccountPasswordUpdate(CThostFtdcTradingAccountPasswordUpdateField *pTradingAccountPasswordUpdate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingAccountPasswordUpdate)
    {
      return;
    }

    TraderSpi_OnRspTradingAccountPasswordUpdate(self, pTradingAccountPasswordUpdate, pRspInfo, nRequestID, bIsLast);

  };

  ///��ѯ�û���ǰ֧�ֵ���֤ģʽ�Ļظ�
  virtual void  OnRspUserAuthMethod(CThostFtdcRspUserAuthMethodField *pRspUserAuthMethod, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspUserAuthMethod)
    {
      return;
    }

    TraderSpi_OnRspUserAuthMethod(self, pRspUserAuthMethod, pRspInfo, nRequestID, bIsLast);

  };

  ///��ȡͼ����֤������Ļظ�
  virtual void  OnRspGenUserCaptcha(CThostFtdcRspGenUserCaptchaField *pRspGenUserCaptcha, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspGenUserCaptcha)
    {
      return;
    }

    TraderSpi_OnRspGenUserCaptcha(self, pRspGenUserCaptcha, pRspInfo, nRequestID, bIsLast);

  };

  ///��ȡ������֤������Ļظ�
  virtual void  OnRspGenUserText(CThostFtdcRspGenUserTextField *pRspGenUserText, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspGenUserText)
    {
      return;
    }

    TraderSpi_OnRspGenUserText(self, pRspGenUserText, pRspInfo, nRequestID, bIsLast);

  };

  ///����¼��������Ӧ
  virtual void  OnRspOrderInsert(CThostFtdcInputOrderField *pInputOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOrder)
    {
      return;
    }

    TraderSpi_OnRspOrderInsert(self, pInputOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///Ԥ��¼��������Ӧ
  virtual void  OnRspParkedOrderInsert(CThostFtdcParkedOrderField *pParkedOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pParkedOrder)
    {
      return;
    }

    TraderSpi_OnRspParkedOrderInsert(self, pParkedOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///Ԥ�񳷵�¼��������Ӧ
  virtual void  OnRspParkedOrderAction(CThostFtdcParkedOrderActionField *pParkedOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pParkedOrderAction)
    {
      return;
    }

    TraderSpi_OnRspParkedOrderAction(self, pParkedOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///��������������Ӧ
  virtual void  OnRspOrderAction(CThostFtdcInputOrderActionField *pInputOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOrderAction)
    {
      return;
    }

    TraderSpi_OnRspOrderAction(self, pInputOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///��ѯ��󱨵�������Ӧ
  virtual void  OnRspQueryMaxOrderVolume(CThostFtdcQueryMaxOrderVolumeField *pQueryMaxOrderVolume, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pQueryMaxOrderVolume)
    {
      return;
    }

    TraderSpi_OnRspQueryMaxOrderVolume(self, pQueryMaxOrderVolume, pRspInfo, nRequestID, bIsLast);

  };

  ///Ͷ���߽�����ȷ����Ӧ
  virtual void  OnRspSettlementInfoConfirm(CThostFtdcSettlementInfoConfirmField *pSettlementInfoConfirm, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSettlementInfoConfirm)
    {
      return;
    }

    TraderSpi_OnRspSettlementInfoConfirm(self, pSettlementInfoConfirm, pRspInfo, nRequestID, bIsLast);

  };

  ///ɾ��Ԥ����Ӧ
  virtual void  OnRspRemoveParkedOrder(CThostFtdcRemoveParkedOrderField *pRemoveParkedOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRemoveParkedOrder)
    {
      return;
    }

    TraderSpi_OnRspRemoveParkedOrder(self, pRemoveParkedOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///ɾ��Ԥ�񳷵���Ӧ
  virtual void  OnRspRemoveParkedOrderAction(CThostFtdcRemoveParkedOrderActionField *pRemoveParkedOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRemoveParkedOrderAction)
    {
      return;
    }

    TraderSpi_OnRspRemoveParkedOrderAction(self, pRemoveParkedOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///ִ������¼��������Ӧ
  virtual void  OnRspExecOrderInsert(CThostFtdcInputExecOrderField *pInputExecOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputExecOrder)
    {
      return;
    }

    TraderSpi_OnRspExecOrderInsert(self, pInputExecOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///ִ���������������Ӧ
  virtual void  OnRspExecOrderAction(CThostFtdcInputExecOrderActionField *pInputExecOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputExecOrderAction)
    {
      return;
    }

    TraderSpi_OnRspExecOrderAction(self, pInputExecOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///ѯ��¼��������Ӧ
  virtual void  OnRspForQuoteInsert(CThostFtdcInputForQuoteField *pInputForQuote, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputForQuote)
    {
      return;
    }

    TraderSpi_OnRspForQuoteInsert(self, pInputForQuote, pRspInfo, nRequestID, bIsLast);

  };

  ///����¼��������Ӧ
  virtual void  OnRspQuoteInsert(CThostFtdcInputQuoteField *pInputQuote, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputQuote)
    {
      return;
    }

    TraderSpi_OnRspQuoteInsert(self, pInputQuote, pRspInfo, nRequestID, bIsLast);

  };

  ///���۲���������Ӧ
  virtual void  OnRspQuoteAction(CThostFtdcInputQuoteActionField *pInputQuoteAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputQuoteAction)
    {
      return;
    }

    TraderSpi_OnRspQuoteAction(self, pInputQuoteAction, pRspInfo, nRequestID, bIsLast);

  };

  ///������������������Ӧ
  virtual void  OnRspBatchOrderAction(CThostFtdcInputBatchOrderActionField *pInputBatchOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputBatchOrderAction)
    {
      return;
    }

    TraderSpi_OnRspBatchOrderAction(self, pInputBatchOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///��Ȩ�ԶԳ�¼��������Ӧ
  virtual void  OnRspOptionSelfCloseInsert(CThostFtdcInputOptionSelfCloseField *pInputOptionSelfClose, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOptionSelfClose)
    {
      return;
    }

    TraderSpi_OnRspOptionSelfCloseInsert(self, pInputOptionSelfClose, pRspInfo, nRequestID, bIsLast);

  };

  ///��Ȩ�ԶԳ����������Ӧ
  virtual void  OnRspOptionSelfCloseAction(CThostFtdcInputOptionSelfCloseActionField *pInputOptionSelfCloseAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOptionSelfCloseAction)
    {
      return;
    }

    TraderSpi_OnRspOptionSelfCloseAction(self, pInputOptionSelfCloseAction, pRspInfo, nRequestID, bIsLast);

  };

  ///�������¼��������Ӧ
  virtual void  OnRspCombActionInsert(CThostFtdcInputCombActionField *pInputCombAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputCombAction)
    {
      return;
    }

    TraderSpi_OnRspCombActionInsert(self, pInputCombAction, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������Ӧ
  virtual void  OnRspQryOrder(CThostFtdcOrderField *pOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOrder)
    {
      return;
    }

    TraderSpi_OnRspQryOrder(self, pOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�ɽ���Ӧ
  virtual void  OnRspQryTrade(CThostFtdcTradeField *pTrade, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTrade)
    {
      return;
    }

    TraderSpi_OnRspQryTrade(self, pTrade, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ���ֲ߳���Ӧ
  virtual void  OnRspQryInvestorPosition(CThostFtdcInvestorPositionField *pInvestorPosition, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestorPosition)
    {
      return;
    }

    TraderSpi_OnRspQryInvestorPosition(self, pInvestorPosition, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�ʽ��˻���Ӧ
  virtual void  OnRspQryTradingAccount(CThostFtdcTradingAccountField *pTradingAccount, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingAccount)
    {
      return;
    }

    TraderSpi_OnRspQryTradingAccount(self, pTradingAccount, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ������Ӧ
  virtual void  OnRspQryInvestor(CThostFtdcInvestorField *pInvestor, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestor)
    {
      return;
    }

    TraderSpi_OnRspQryInvestor(self, pInvestor, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ���ױ�����Ӧ
  virtual void  OnRspQryTradingCode(CThostFtdcTradingCodeField *pTradingCode, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingCode)
    {
      return;
    }

    TraderSpi_OnRspQryTradingCode(self, pTradingCode, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Լ��֤������Ӧ
  virtual void  OnRspQryInstrumentMarginRate(CThostFtdcInstrumentMarginRateField *pInstrumentMarginRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInstrumentMarginRate)
    {
      return;
    }

    TraderSpi_OnRspQryInstrumentMarginRate(self, pInstrumentMarginRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Լ����������Ӧ
  virtual void  OnRspQryInstrumentCommissionRate(CThostFtdcInstrumentCommissionRateField *pInstrumentCommissionRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInstrumentCommissionRate)
    {
      return;
    }

    TraderSpi_OnRspQryInstrumentCommissionRate(self, pInstrumentCommissionRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��������Ӧ
  virtual void  OnRspQryExchange(CThostFtdcExchangeField *pExchange, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExchange)
    {
      return;
    }

    TraderSpi_OnRspQryExchange(self, pExchange, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ʒ��Ӧ
  virtual void  OnRspQryProduct(CThostFtdcProductField *pProduct, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pProduct)
    {
      return;
    }

    TraderSpi_OnRspQryProduct(self, pProduct, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Լ��Ӧ
  virtual void  OnRspQryInstrument(CThostFtdcInstrumentField *pInstrument, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInstrument)
    {
      return;
    }

    TraderSpi_OnRspQryInstrument(self, pInstrument, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������Ӧ
  virtual void  OnRspQryDepthMarketData(CThostFtdcDepthMarketDataField *pDepthMarketData, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pDepthMarketData)
    {
      return;
    }

    TraderSpi_OnRspQryDepthMarketData(self, pDepthMarketData, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ���߽�������Ӧ
  virtual void  OnRspQrySettlementInfo(CThostFtdcSettlementInfoField *pSettlementInfo, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSettlementInfo)
    {
      return;
    }

    TraderSpi_OnRspQrySettlementInfo(self, pSettlementInfo, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯת��������Ӧ
  virtual void  OnRspQryTransferBank(CThostFtdcTransferBankField *pTransferBank, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTransferBank)
    {
      return;
    }

    TraderSpi_OnRspQryTransferBank(self, pTransferBank, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ���ֲ߳���ϸ��Ӧ
  virtual void  OnRspQryInvestorPositionDetail(CThostFtdcInvestorPositionDetailField *pInvestorPositionDetail, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestorPositionDetail)
    {
      return;
    }

    TraderSpi_OnRspQryInvestorPositionDetail(self, pInvestorPositionDetail, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�ͻ�֪ͨ��Ӧ
  virtual void  OnRspQryNotice(CThostFtdcNoticeField *pNotice, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pNotice)
    {
      return;
    }

    TraderSpi_OnRspQryNotice(self, pNotice, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������Ϣȷ����Ӧ
  virtual void  OnRspQrySettlementInfoConfirm(CThostFtdcSettlementInfoConfirmField *pSettlementInfoConfirm, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSettlementInfoConfirm)
    {
      return;
    }

    TraderSpi_OnRspQrySettlementInfoConfirm(self, pSettlementInfoConfirm, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ���ֲ߳���ϸ��Ӧ
  virtual void  OnRspQryInvestorPositionCombineDetail(CThostFtdcInvestorPositionCombineDetailField *pInvestorPositionCombineDetail, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestorPositionCombineDetail)
    {
      return;
    }

    TraderSpi_OnRspQryInvestorPositionCombineDetail(self, pInvestorPositionCombineDetail, pRspInfo, nRequestID, bIsLast);

  };

  ///��ѯ��֤����ϵͳ���͹�˾�ʽ��˻���Կ��Ӧ
  virtual void  OnRspQryCFMMCTradingAccountKey(CThostFtdcCFMMCTradingAccountKeyField *pCFMMCTradingAccountKey, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCFMMCTradingAccountKey)
    {
      return;
    }

    TraderSpi_OnRspQryCFMMCTradingAccountKey(self, pCFMMCTradingAccountKey, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�ֵ��۵���Ϣ��Ӧ
  virtual void  OnRspQryEWarrantOffset(CThostFtdcEWarrantOffsetField *pEWarrantOffset, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pEWarrantOffset)
    {
      return;
    }

    TraderSpi_OnRspQryEWarrantOffset(self, pEWarrantOffset, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ����Ʒ��/��Ʒ�ֱ�֤����Ӧ
  virtual void  OnRspQryInvestorProductGroupMargin(CThostFtdcInvestorProductGroupMarginField *pInvestorProductGroupMargin, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestorProductGroupMargin)
    {
      return;
    }

    TraderSpi_OnRspQryInvestorProductGroupMargin(self, pInvestorProductGroupMargin, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��������֤������Ӧ
  virtual void  OnRspQryExchangeMarginRate(CThostFtdcExchangeMarginRateField *pExchangeMarginRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExchangeMarginRate)
    {
      return;
    }

    TraderSpi_OnRspQryExchangeMarginRate(self, pExchangeMarginRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������������֤������Ӧ
  virtual void  OnRspQryExchangeMarginRateAdjust(CThostFtdcExchangeMarginRateAdjustField *pExchangeMarginRateAdjust, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExchangeMarginRateAdjust)
    {
      return;
    }

    TraderSpi_OnRspQryExchangeMarginRateAdjust(self, pExchangeMarginRateAdjust, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������Ӧ
  virtual void  OnRspQryExchangeRate(CThostFtdcExchangeRateField *pExchangeRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExchangeRate)
    {
      return;
    }

    TraderSpi_OnRspQryExchangeRate(self, pExchangeRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������������Ա����Ȩ����Ӧ
  virtual void  OnRspQrySecAgentACIDMap(CThostFtdcSecAgentACIDMapField *pSecAgentACIDMap, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSecAgentACIDMap)
    {
      return;
    }

    TraderSpi_OnRspQrySecAgentACIDMap(self, pSecAgentACIDMap, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ʒ���ۻ���
  virtual void  OnRspQryProductExchRate(CThostFtdcProductExchRateField *pProductExchRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pProductExchRate)
    {
      return;
    }

    TraderSpi_OnRspQryProductExchRate(self, pProductExchRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ʒ��
  virtual void  OnRspQryProductGroup(CThostFtdcProductGroupField *pProductGroup, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pProductGroup)
    {
      return;
    }

    TraderSpi_OnRspQryProductGroup(self, pProductGroup, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�����̺�Լ����������Ӧ
  virtual void  OnRspQryMMInstrumentCommissionRate(CThostFtdcMMInstrumentCommissionRateField *pMMInstrumentCommissionRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pMMInstrumentCommissionRate)
    {
      return;
    }

    TraderSpi_OnRspQryMMInstrumentCommissionRate(self, pMMInstrumentCommissionRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��������Ȩ��Լ��������Ӧ
  virtual void  OnRspQryMMOptionInstrCommRate(CThostFtdcMMOptionInstrCommRateField *pMMOptionInstrCommRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pMMOptionInstrCommRate)
    {
      return;
    }

    TraderSpi_OnRspQryMMOptionInstrCommRate(self, pMMOptionInstrCommRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������������Ӧ
  virtual void  OnRspQryInstrumentOrderCommRate(CThostFtdcInstrumentOrderCommRateField *pInstrumentOrderCommRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInstrumentOrderCommRate)
    {
      return;
    }

    TraderSpi_OnRspQryInstrumentOrderCommRate(self, pInstrumentOrderCommRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�ʽ��˻���Ӧ
  virtual void  OnRspQrySecAgentTradingAccount(CThostFtdcTradingAccountField *pTradingAccount, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingAccount)
    {
      return;
    }

    TraderSpi_OnRspQrySecAgentTradingAccount(self, pTradingAccount, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ�����������ʽ�У��ģʽ��Ӧ
  virtual void  OnRspQrySecAgentCheckMode(CThostFtdcSecAgentCheckModeField *pSecAgentCheckMode, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSecAgentCheckMode)
    {
      return;
    }

    TraderSpi_OnRspQrySecAgentCheckMode(self, pSecAgentCheckMode, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������������Ϣ��Ӧ
  virtual void  OnRspQrySecAgentTradeInfo(CThostFtdcSecAgentTradeInfoField *pSecAgentTradeInfo, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pSecAgentTradeInfo)
    {
      return;
    }

    TraderSpi_OnRspQrySecAgentTradeInfo(self, pSecAgentTradeInfo, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ȩ���׳ɱ���Ӧ
  virtual void  OnRspQryOptionInstrTradeCost(CThostFtdcOptionInstrTradeCostField *pOptionInstrTradeCost, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOptionInstrTradeCost)
    {
      return;
    }

    TraderSpi_OnRspQryOptionInstrTradeCost(self, pOptionInstrTradeCost, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ȩ��Լ��������Ӧ
  virtual void  OnRspQryOptionInstrCommRate(CThostFtdcOptionInstrCommRateField *pOptionInstrCommRate, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOptionInstrCommRate)
    {
      return;
    }

    TraderSpi_OnRspQryOptionInstrCommRate(self, pOptionInstrCommRate, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯִ��������Ӧ
  virtual void  OnRspQryExecOrder(CThostFtdcExecOrderField *pExecOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExecOrder)
    {
      return;
    }

    TraderSpi_OnRspQryExecOrder(self, pExecOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯѯ����Ӧ
  virtual void  OnRspQryForQuote(CThostFtdcForQuoteField *pForQuote, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pForQuote)
    {
      return;
    }

    TraderSpi_OnRspQryForQuote(self, pForQuote, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ������Ӧ
  virtual void  OnRspQryQuote(CThostFtdcQuoteField *pQuote, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pQuote)
    {
      return;
    }

    TraderSpi_OnRspQryQuote(self, pQuote, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ȩ�ԶԳ���Ӧ
  virtual void  OnRspQryOptionSelfClose(CThostFtdcOptionSelfCloseField *pOptionSelfClose, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOptionSelfClose)
    {
      return;
    }

    TraderSpi_OnRspQryOptionSelfClose(self, pOptionSelfClose, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯͶ�ʵ�Ԫ��Ӧ
  virtual void  OnRspQryInvestUnit(CThostFtdcInvestUnitField *pInvestUnit, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInvestUnit)
    {
      return;
    }

    TraderSpi_OnRspQryInvestUnit(self, pInvestUnit, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��Ϻ�Լ��ȫϵ����Ӧ
  virtual void  OnRspQryCombInstrumentGuard(CThostFtdcCombInstrumentGuardField *pCombInstrumentGuard, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCombInstrumentGuard)
    {
      return;
    }

    TraderSpi_OnRspQryCombInstrumentGuard(self, pCombInstrumentGuard, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ���������Ӧ
  virtual void  OnRspQryCombAction(CThostFtdcCombActionField *pCombAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCombAction)
    {
      return;
    }

    TraderSpi_OnRspQryCombAction(self, pCombAction, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯת����ˮ��Ӧ
  virtual void  OnRspQryTransferSerial(CThostFtdcTransferSerialField *pTransferSerial, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTransferSerial)
    {
      return;
    }

    TraderSpi_OnRspQryTransferSerial(self, pTransferSerial, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ����ǩԼ��ϵ��Ӧ
  virtual void  OnRspQryAccountregister(CThostFtdcAccountregisterField *pAccountregister, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pAccountregister)
    {
      return;
    }

    TraderSpi_OnRspQryAccountregister(self, pAccountregister, pRspInfo, nRequestID, bIsLast);

  };

  ///����Ӧ��
  virtual void  OnRspError(CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspInfo)
    {
      return;
    }

    TraderSpi_OnRspError(self, pRspInfo, nRequestID, bIsLast);

  };

  ///����֪ͨ
  virtual void  OnRtnOrder(CThostFtdcOrderField *pOrder) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOrder)
    {
      return;
    }

    TraderSpi_OnRtnOrder(self, pOrder);

  };

  ///�ɽ�֪ͨ
  virtual void  OnRtnTrade(CThostFtdcTradeField *pTrade) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTrade)
    {
      return;
    }

    TraderSpi_OnRtnTrade(self, pTrade);

  };

  ///����¼�����ر�
  virtual void  OnErrRtnOrderInsert(CThostFtdcInputOrderField *pInputOrder, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOrder)
    {
      return;
    }

    TraderSpi_OnErrRtnOrderInsert(self, pInputOrder, pRspInfo);

  };

  ///������������ر�
  virtual void  OnErrRtnOrderAction(CThostFtdcOrderActionField *pOrderAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOrderAction)
    {
      return;
    }

    TraderSpi_OnErrRtnOrderAction(self, pOrderAction, pRspInfo);

  };

  ///��Լ����״̬֪ͨ
  virtual void  OnRtnInstrumentStatus(CThostFtdcInstrumentStatusField *pInstrumentStatus) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInstrumentStatus)
    {
      return;
    }

    TraderSpi_OnRtnInstrumentStatus(self, pInstrumentStatus);

  };

  ///����������֪ͨ
  virtual void  OnRtnBulletin(CThostFtdcBulletinField *pBulletin) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pBulletin)
    {
      return;
    }

    TraderSpi_OnRtnBulletin(self, pBulletin);

  };

  ///����֪ͨ
  virtual void  OnRtnTradingNotice(CThostFtdcTradingNoticeInfoField *pTradingNoticeInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingNoticeInfo)
    {
      return;
    }

    TraderSpi_OnRtnTradingNotice(self, pTradingNoticeInfo);

  };

  ///��ʾ������У�����
  virtual void  OnRtnErrorConditionalOrder(CThostFtdcErrorConditionalOrderField *pErrorConditionalOrder) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pErrorConditionalOrder)
    {
      return;
    }

    TraderSpi_OnRtnErrorConditionalOrder(self, pErrorConditionalOrder);

  };

  ///ִ������֪ͨ
  virtual void  OnRtnExecOrder(CThostFtdcExecOrderField *pExecOrder) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExecOrder)
    {
      return;
    }

    TraderSpi_OnRtnExecOrder(self, pExecOrder);

  };

  ///ִ������¼�����ر�
  virtual void  OnErrRtnExecOrderInsert(CThostFtdcInputExecOrderField *pInputExecOrder, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputExecOrder)
    {
      return;
    }

    TraderSpi_OnErrRtnExecOrderInsert(self, pInputExecOrder, pRspInfo);

  };

  ///ִ�������������ر�
  virtual void  OnErrRtnExecOrderAction(CThostFtdcExecOrderActionField *pExecOrderAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pExecOrderAction)
    {
      return;
    }

    TraderSpi_OnErrRtnExecOrderAction(self, pExecOrderAction, pRspInfo);

  };

  ///ѯ��¼�����ر�
  virtual void  OnErrRtnForQuoteInsert(CThostFtdcInputForQuoteField *pInputForQuote, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputForQuote)
    {
      return;
    }

    TraderSpi_OnErrRtnForQuoteInsert(self, pInputForQuote, pRspInfo);

  };

  ///����֪ͨ
  virtual void  OnRtnQuote(CThostFtdcQuoteField *pQuote) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pQuote)
    {
      return;
    }

    TraderSpi_OnRtnQuote(self, pQuote);

  };

  ///����¼�����ر�
  virtual void  OnErrRtnQuoteInsert(CThostFtdcInputQuoteField *pInputQuote, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputQuote)
    {
      return;
    }

    TraderSpi_OnErrRtnQuoteInsert(self, pInputQuote, pRspInfo);

  };

  ///���۲�������ر�
  virtual void  OnErrRtnQuoteAction(CThostFtdcQuoteActionField *pQuoteAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pQuoteAction)
    {
      return;
    }

    TraderSpi_OnErrRtnQuoteAction(self, pQuoteAction, pRspInfo);

  };

  ///ѯ��֪ͨ
  virtual void  OnRtnForQuoteRsp(CThostFtdcForQuoteRspField *pForQuoteRsp) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pForQuoteRsp)
    {
      return;
    }

    TraderSpi_OnRtnForQuoteRsp(self, pForQuoteRsp);

  };

  ///��֤���������û�����
  virtual void  OnRtnCFMMCTradingAccountToken(CThostFtdcCFMMCTradingAccountTokenField *pCFMMCTradingAccountToken) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCFMMCTradingAccountToken)
    {
      return;
    }

    TraderSpi_OnRtnCFMMCTradingAccountToken(self, pCFMMCTradingAccountToken);

  };

  ///����������������ر�
  virtual void  OnErrRtnBatchOrderAction(CThostFtdcBatchOrderActionField *pBatchOrderAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pBatchOrderAction)
    {
      return;
    }

    TraderSpi_OnErrRtnBatchOrderAction(self, pBatchOrderAction, pRspInfo);

  };

  ///��Ȩ�ԶԳ�֪ͨ
  virtual void  OnRtnOptionSelfClose(CThostFtdcOptionSelfCloseField *pOptionSelfClose) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOptionSelfClose)
    {
      return;
    }

    TraderSpi_OnRtnOptionSelfClose(self, pOptionSelfClose);

  };

  ///��Ȩ�ԶԳ�¼�����ر�
  virtual void  OnErrRtnOptionSelfCloseInsert(CThostFtdcInputOptionSelfCloseField *pInputOptionSelfClose, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputOptionSelfClose)
    {
      return;
    }

    TraderSpi_OnErrRtnOptionSelfCloseInsert(self, pInputOptionSelfClose, pRspInfo);

  };

  ///��Ȩ�ԶԳ��������ر�
  virtual void  OnErrRtnOptionSelfCloseAction(CThostFtdcOptionSelfCloseActionField *pOptionSelfCloseAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOptionSelfCloseAction)
    {
      return;
    }

    TraderSpi_OnErrRtnOptionSelfCloseAction(self, pOptionSelfCloseAction, pRspInfo);

  };

  ///�������֪ͨ
  virtual void  OnRtnCombAction(CThostFtdcCombActionField *pCombAction) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCombAction)
    {
      return;
    }

    TraderSpi_OnRtnCombAction(self, pCombAction);

  };

  ///�������¼�����ر�
  virtual void  OnErrRtnCombActionInsert(CThostFtdcInputCombActionField *pInputCombAction, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pInputCombAction)
    {
      return;
    }

    TraderSpi_OnErrRtnCombActionInsert(self, pInputCombAction, pRspInfo);

  };

  ///�����ѯǩԼ������Ӧ
  virtual void  OnRspQryContractBank(CThostFtdcContractBankField *pContractBank, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pContractBank)
    {
      return;
    }

    TraderSpi_OnRspQryContractBank(self, pContractBank, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯԤ����Ӧ
  virtual void  OnRspQryParkedOrder(CThostFtdcParkedOrderField *pParkedOrder, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pParkedOrder)
    {
      return;
    }

    TraderSpi_OnRspQryParkedOrder(self, pParkedOrder, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯԤ�񳷵���Ӧ
  virtual void  OnRspQryParkedOrderAction(CThostFtdcParkedOrderActionField *pParkedOrderAction, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pParkedOrderAction)
    {
      return;
    }

    TraderSpi_OnRspQryParkedOrderAction(self, pParkedOrderAction, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ����֪ͨ��Ӧ
  virtual void  OnRspQryTradingNotice(CThostFtdcTradingNoticeField *pTradingNotice, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pTradingNotice)
    {
      return;
    }

    TraderSpi_OnRspQryTradingNotice(self, pTradingNotice, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ���͹�˾���ײ�����Ӧ
  virtual void  OnRspQryBrokerTradingParams(CThostFtdcBrokerTradingParamsField *pBrokerTradingParams, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pBrokerTradingParams)
    {
      return;
    }

    TraderSpi_OnRspQryBrokerTradingParams(self, pBrokerTradingParams, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ���͹�˾�����㷨��Ӧ
  virtual void  OnRspQryBrokerTradingAlgos(CThostFtdcBrokerTradingAlgosField *pBrokerTradingAlgos, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pBrokerTradingAlgos)
    {
      return;
    }

    TraderSpi_OnRspQryBrokerTradingAlgos(self, pBrokerTradingAlgos, pRspInfo, nRequestID, bIsLast);

  };

  ///�����ѯ��������û�����
  virtual void  OnRspQueryCFMMCTradingAccountToken(CThostFtdcQueryCFMMCTradingAccountTokenField *pQueryCFMMCTradingAccountToken, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pQueryCFMMCTradingAccountToken)
    {
      return;
    }

    TraderSpi_OnRspQueryCFMMCTradingAccountToken(self, pQueryCFMMCTradingAccountToken, pRspInfo, nRequestID, bIsLast);

  };

  ///���з��������ʽ�ת�ڻ�֪ͨ
  virtual void  OnRtnFromBankToFutureByBank(CThostFtdcRspTransferField *pRspTransfer) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspTransfer)
    {
      return;
    }

    TraderSpi_OnRtnFromBankToFutureByBank(self, pRspTransfer);

  };

  ///���з����ڻ��ʽ�ת����֪ͨ
  virtual void  OnRtnFromFutureToBankByBank(CThostFtdcRspTransferField *pRspTransfer) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspTransfer)
    {
      return;
    }

    TraderSpi_OnRtnFromFutureToBankByBank(self, pRspTransfer);

  };

  ///���з����������ת�ڻ�֪ͨ
  virtual void  OnRtnRepealFromBankToFutureByBank(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromBankToFutureByBank(self, pRspRepeal);

  };

  ///���з�������ڻ�ת����֪ͨ
  virtual void  OnRtnRepealFromFutureToBankByBank(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromFutureToBankByBank(self, pRspRepeal);

  };

  ///�ڻ����������ʽ�ת�ڻ�֪ͨ
  virtual void  OnRtnFromBankToFutureByFuture(CThostFtdcRspTransferField *pRspTransfer) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspTransfer)
    {
      return;
    }

    TraderSpi_OnRtnFromBankToFutureByFuture(self, pRspTransfer);

  };

  ///�ڻ������ڻ��ʽ�ת����֪ͨ
  virtual void  OnRtnFromFutureToBankByFuture(CThostFtdcRspTransferField *pRspTransfer) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspTransfer)
    {
      return;
    }

    TraderSpi_OnRtnFromFutureToBankByFuture(self, pRspTransfer);

  };

  ///ϵͳ����ʱ�ڻ����ֹ������������ת�ڻ��������д�����Ϻ��̷��ص�֪ͨ
  virtual void  OnRtnRepealFromBankToFutureByFutureManual(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromBankToFutureByFutureManual(self, pRspRepeal);

  };

  ///ϵͳ����ʱ�ڻ����ֹ���������ڻ�ת�����������д�����Ϻ��̷��ص�֪ͨ
  virtual void  OnRtnRepealFromFutureToBankByFutureManual(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromFutureToBankByFutureManual(self, pRspRepeal);

  };

  ///�ڻ������ѯ�������֪ͨ
  virtual void  OnRtnQueryBankBalanceByFuture(CThostFtdcNotifyQueryAccountField *pNotifyQueryAccount) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pNotifyQueryAccount)
    {
      return;
    }

    TraderSpi_OnRtnQueryBankBalanceByFuture(self, pNotifyQueryAccount);

  };

  ///�ڻ����������ʽ�ת�ڻ�����ر�
  virtual void  OnErrRtnBankToFutureByFuture(CThostFtdcReqTransferField *pReqTransfer, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqTransfer)
    {
      return;
    }

    TraderSpi_OnErrRtnBankToFutureByFuture(self, pReqTransfer, pRspInfo);

  };

  ///�ڻ������ڻ��ʽ�ת���д���ر�
  virtual void  OnErrRtnFutureToBankByFuture(CThostFtdcReqTransferField *pReqTransfer, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqTransfer)
    {
      return;
    }

    TraderSpi_OnErrRtnFutureToBankByFuture(self, pReqTransfer, pRspInfo);

  };

  ///ϵͳ����ʱ�ڻ����ֹ������������ת�ڻ�����ر�
  virtual void  OnErrRtnRepealBankToFutureByFutureManual(CThostFtdcReqRepealField *pReqRepeal, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqRepeal)
    {
      return;
    }

    TraderSpi_OnErrRtnRepealBankToFutureByFutureManual(self, pReqRepeal, pRspInfo);

  };

  ///ϵͳ����ʱ�ڻ����ֹ���������ڻ�ת���д���ر�
  virtual void  OnErrRtnRepealFutureToBankByFutureManual(CThostFtdcReqRepealField *pReqRepeal, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqRepeal)
    {
      return;
    }

    TraderSpi_OnErrRtnRepealFutureToBankByFutureManual(self, pReqRepeal, pRspInfo);

  };

  ///�ڻ������ѯ����������ر�
  virtual void  OnErrRtnQueryBankBalanceByFuture(CThostFtdcReqQueryAccountField *pReqQueryAccount, CThostFtdcRspInfoField *pRspInfo) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqQueryAccount)
    {
      return;
    }

    TraderSpi_OnErrRtnQueryBankBalanceByFuture(self, pReqQueryAccount, pRspInfo);

  };

  ///�ڻ������������ת�ڻ��������д�����Ϻ��̷��ص�֪ͨ
  virtual void  OnRtnRepealFromBankToFutureByFuture(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromBankToFutureByFuture(self, pRspRepeal);

  };

  ///�ڻ���������ڻ�ת�����������д�����Ϻ��̷��ص�֪ͨ
  virtual void  OnRtnRepealFromFutureToBankByFuture(CThostFtdcRspRepealField *pRspRepeal) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pRspRepeal)
    {
      return;
    }

    TraderSpi_OnRtnRepealFromFutureToBankByFuture(self, pRspRepeal);

  };

  ///�ڻ����������ʽ�ת�ڻ�Ӧ��
  virtual void  OnRspFromBankToFutureByFuture(CThostFtdcReqTransferField *pReqTransfer, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqTransfer)
    {
      return;
    }

    TraderSpi_OnRspFromBankToFutureByFuture(self, pReqTransfer, pRspInfo, nRequestID, bIsLast);

  };

  ///�ڻ������ڻ��ʽ�ת����Ӧ��
  virtual void  OnRspFromFutureToBankByFuture(CThostFtdcReqTransferField *pReqTransfer, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqTransfer)
    {
      return;
    }

    TraderSpi_OnRspFromFutureToBankByFuture(self, pReqTransfer, pRspInfo, nRequestID, bIsLast);

  };

  ///�ڻ������ѯ�������Ӧ��
  virtual void  OnRspQueryBankAccountMoneyByFuture(CThostFtdcReqQueryAccountField *pReqQueryAccount, CThostFtdcRspInfoField *pRspInfo, int nRequestID, bool bIsLast) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pReqQueryAccount)
    {
      return;
    }

    TraderSpi_OnRspQueryBankAccountMoneyByFuture(self, pReqQueryAccount, pRspInfo, nRequestID, bIsLast);

  };

  ///���з������ڿ���֪ͨ
  virtual void  OnRtnOpenAccountByBank(CThostFtdcOpenAccountField *pOpenAccount) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pOpenAccount)
    {
      return;
    }

    TraderSpi_OnRtnOpenAccountByBank(self, pOpenAccount);

  };

  ///���з�����������֪ͨ
  virtual void  OnRtnCancelAccountByBank(CThostFtdcCancelAccountField *pCancelAccount) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pCancelAccount)
    {
      return;
    }

    TraderSpi_OnRtnCancelAccountByBank(self, pCancelAccount);

  };

  ///���з����������˺�֪ͨ
  virtual void  OnRtnChangeAccountByBank(CThostFtdcChangeAccountField *pChangeAccount) {
    //double dwTime = get_tick_count();
    PyGILLock gilLock;

    if (NULL==pChangeAccount)
    {
      return;
    }

    TraderSpi_OnRtnChangeAccountByBank(self, pChangeAccount);

  };

private:
    PyObject *self;
};

#endif /* CTraderSpi_H */