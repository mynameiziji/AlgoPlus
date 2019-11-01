# 规则

OrderRef用来标识报单，OrderActionRef用来标识标撤单。

CTP量化投资API要求报单的OrderRef/OrderActionRef字段在同一线程内必须是递增的，长度不超过13的数字字符串。

如果包含非数字字符，或者非递增关系，都会触发以下的错误：

>{'ErrorID': 22, 'ErrorMsg': 'CTP:报单错误：不允许重复报单'}

# 设计方案：

* 如果为每个策略开启一个线程，即一个TraderApi管理一个策略，则指定策略ID，为每个策略分配一个报单区间，据此在回报/通知中分辨出对应策略。

* 如果一个TraderApi作为主引擎管理多个策略，则需要在引擎层面管理OrderRef/OrderActionRef，然后维护策略与OrderRef/OrderActionRef的关系表，据此在回报/通知中分辨出对应策略。