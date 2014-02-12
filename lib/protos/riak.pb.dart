///
//  Generated code. Do not modify.
///
library riak;

import 'package:protobuf/protobuf.dart';

class RpbErrorResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbErrorResp')
    ..a(1, 'errmsg', GeneratedMessage.QY)
    ..a(2, 'errcode', GeneratedMessage.QU3)
  ;

  RpbErrorResp() : super();
  RpbErrorResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbErrorResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbErrorResp clone() => new RpbErrorResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get errmsg => getField(1);
  void set errmsg(List<int> v) { setField(1, v); }
  bool hasErrmsg() => hasField(1);
  void clearErrmsg() => clearField(1);

  int get errcode => getField(2);
  void set errcode(int v) { setField(2, v); }
  bool hasErrcode() => hasField(2);
  void clearErrcode() => clearField(2);
}

class RpbGetServerInfoResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetServerInfoResp')
    ..a(1, 'node', GeneratedMessage.OY)
    ..a(2, 'serverVersion', GeneratedMessage.OY)
    ..hasRequiredFields = false
  ;

  RpbGetServerInfoResp() : super();
  RpbGetServerInfoResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetServerInfoResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetServerInfoResp clone() => new RpbGetServerInfoResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get node => getField(1);
  void set node(List<int> v) { setField(1, v); }
  bool hasNode() => hasField(1);
  void clearNode() => clearField(1);

  List<int> get serverVersion => getField(2);
  void set serverVersion(List<int> v) { setField(2, v); }
  bool hasServerVersion() => hasField(2);
  void clearServerVersion() => clearField(2);
}

class RpbPair extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbPair')
    ..a(1, 'key', GeneratedMessage.QY)
    ..a(2, 'value', GeneratedMessage.OY)
  ;

  RpbPair() : super();
  RpbPair.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbPair.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbPair clone() => new RpbPair()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get key => getField(1);
  void set key(List<int> v) { setField(1, v); }
  bool hasKey() => hasField(1);
  void clearKey() => clearField(1);

  List<int> get value => getField(2);
  void set value(List<int> v) { setField(2, v); }
  bool hasValue() => hasField(2);
  void clearValue() => clearField(2);
}

class RpbGetBucketReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetBucketReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
  ;

  RpbGetBucketReq() : super();
  RpbGetBucketReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetBucketReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetBucketReq clone() => new RpbGetBucketReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);
}

class RpbGetBucketResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetBucketResp')
    ..a(1, 'props', GeneratedMessage.QM, () => new RpbBucketProps(), () => new RpbBucketProps())
  ;

  RpbGetBucketResp() : super();
  RpbGetBucketResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetBucketResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetBucketResp clone() => new RpbGetBucketResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  RpbBucketProps get props => getField(1);
  void set props(RpbBucketProps v) { setField(1, v); }
  bool hasProps() => hasField(1);
  void clearProps() => clearField(1);
}

class RpbSetBucketReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbSetBucketReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'props', GeneratedMessage.QM, () => new RpbBucketProps(), () => new RpbBucketProps())
  ;

  RpbSetBucketReq() : super();
  RpbSetBucketReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbSetBucketReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbSetBucketReq clone() => new RpbSetBucketReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  RpbBucketProps get props => getField(2);
  void set props(RpbBucketProps v) { setField(2, v); }
  bool hasProps() => hasField(2);
  void clearProps() => clearField(2);
}

class RpbResetBucketReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbResetBucketReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
  ;

  RpbResetBucketReq() : super();
  RpbResetBucketReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbResetBucketReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbResetBucketReq clone() => new RpbResetBucketReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);
}

class RpbModFun extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbModFun')
    ..a(1, 'module', GeneratedMessage.QY)
    ..a(2, 'function', GeneratedMessage.QY)
  ;

  RpbModFun() : super();
  RpbModFun.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbModFun.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbModFun clone() => new RpbModFun()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get module => getField(1);
  void set module(List<int> v) { setField(1, v); }
  bool hasModule() => hasField(1);
  void clearModule() => clearField(1);

  List<int> get function => getField(2);
  void set function(List<int> v) { setField(2, v); }
  bool hasFunction() => hasField(2);
  void clearFunction() => clearField(2);
}

class RpbCommitHook extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCommitHook')
    ..a(1, 'modfun', GeneratedMessage.OM, () => new RpbModFun(), () => new RpbModFun())
    ..a(2, 'name', GeneratedMessage.OY)
  ;

  RpbCommitHook() : super();
  RpbCommitHook.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCommitHook.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCommitHook clone() => new RpbCommitHook()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  RpbModFun get modfun => getField(1);
  void set modfun(RpbModFun v) { setField(1, v); }
  bool hasModfun() => hasField(1);
  void clearModfun() => clearField(1);

  List<int> get name => getField(2);
  void set name(List<int> v) { setField(2, v); }
  bool hasName() => hasField(2);
  void clearName() => clearField(2);
}

class RpbBucketProps_RpbReplMode extends ProtobufEnum {
  static const RpbBucketProps_RpbReplMode FALSE = const RpbBucketProps_RpbReplMode._(0, 'FALSE');
  static const RpbBucketProps_RpbReplMode REALTIME = const RpbBucketProps_RpbReplMode._(1, 'REALTIME');
  static const RpbBucketProps_RpbReplMode FULLSYNC = const RpbBucketProps_RpbReplMode._(2, 'FULLSYNC');
  static const RpbBucketProps_RpbReplMode TRUE = const RpbBucketProps_RpbReplMode._(3, 'TRUE');

  static const List<RpbBucketProps_RpbReplMode> values = const <RpbBucketProps_RpbReplMode> [
    FALSE,
    REALTIME,
    FULLSYNC,
    TRUE,
  ];

  static final Map<int, RpbBucketProps_RpbReplMode> _byValue = ProtobufEnum.initByValue(values);
  static RpbBucketProps_RpbReplMode valueOf(int value) => _byValue[value];

  const RpbBucketProps_RpbReplMode._(int v, String n) : super(v, n);
}

class RpbBucketProps extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbBucketProps')
    ..a(1, 'nVal', GeneratedMessage.OU3)
    ..a(2, 'allowMult', GeneratedMessage.OB)
    ..a(3, 'lastWriteWins', GeneratedMessage.OB)
    ..m(4, 'precommit', () => new RpbCommitHook(), () => new PbList<RpbCommitHook>())
    ..a(5, 'hasPrecommit', GeneratedMessage.OB)
    ..m(6, 'postcommit', () => new RpbCommitHook(), () => new PbList<RpbCommitHook>())
    ..a(7, 'hasPostcommit', GeneratedMessage.OB)
    ..a(8, 'chashKeyfun', GeneratedMessage.OM, () => new RpbModFun(), () => new RpbModFun())
    ..a(9, 'linkfun', GeneratedMessage.OM, () => new RpbModFun(), () => new RpbModFun())
    ..a(10, 'oldVclock', GeneratedMessage.OU3)
    ..a(11, 'youngVclock', GeneratedMessage.OU3)
    ..a(12, 'bigVclock', GeneratedMessage.OU3)
    ..a(13, 'smallVclock', GeneratedMessage.OU3)
    ..a(14, 'pr', GeneratedMessage.OU3)
    ..a(15, 'r', GeneratedMessage.OU3)
    ..a(16, 'w', GeneratedMessage.OU3)
    ..a(17, 'pw', GeneratedMessage.OU3)
    ..a(18, 'dw', GeneratedMessage.OU3)
    ..a(19, 'rw', GeneratedMessage.OU3)
    ..a(20, 'basicQuorum', GeneratedMessage.OB)
    ..a(21, 'notfoundOk', GeneratedMessage.OB)
    ..a(22, 'backend', GeneratedMessage.OY)
    ..a(23, 'search', GeneratedMessage.OB)
    ..e(24, 'repl', GeneratedMessage.OE, () => RpbBucketProps_RpbReplMode.FALSE, (var v) => RpbBucketProps_RpbReplMode.valueOf(v))
  ;

  RpbBucketProps() : super();
  RpbBucketProps.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbBucketProps.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbBucketProps clone() => new RpbBucketProps()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  int get nVal => getField(1);
  void set nVal(int v) { setField(1, v); }
  bool hasNVal() => hasField(1);
  void clearNVal() => clearField(1);

  bool get allowMult => getField(2);
  void set allowMult(bool v) { setField(2, v); }
  bool hasAllowMult() => hasField(2);
  void clearAllowMult() => clearField(2);

  bool get lastWriteWins => getField(3);
  void set lastWriteWins(bool v) { setField(3, v); }
  bool hasLastWriteWins() => hasField(3);
  void clearLastWriteWins() => clearField(3);

  List<RpbCommitHook> get precommit => getField(4);

  bool get hasPrecommit => getField(5);
  void set hasPrecommit(bool v) { setField(5, v); }
  bool hasHasPrecommit() => hasField(5);
  void clearHasPrecommit() => clearField(5);

  List<RpbCommitHook> get postcommit => getField(6);

  bool get hasPostcommit => getField(7);
  void set hasPostcommit(bool v) { setField(7, v); }
  bool hasHasPostcommit() => hasField(7);
  void clearHasPostcommit() => clearField(7);

  RpbModFun get chashKeyfun => getField(8);
  void set chashKeyfun(RpbModFun v) { setField(8, v); }
  bool hasChashKeyfun() => hasField(8);
  void clearChashKeyfun() => clearField(8);

  RpbModFun get linkfun => getField(9);
  void set linkfun(RpbModFun v) { setField(9, v); }
  bool hasLinkfun() => hasField(9);
  void clearLinkfun() => clearField(9);

  int get oldVclock => getField(10);
  void set oldVclock(int v) { setField(10, v); }
  bool hasOldVclock() => hasField(10);
  void clearOldVclock() => clearField(10);

  int get youngVclock => getField(11);
  void set youngVclock(int v) { setField(11, v); }
  bool hasYoungVclock() => hasField(11);
  void clearYoungVclock() => clearField(11);

  int get bigVclock => getField(12);
  void set bigVclock(int v) { setField(12, v); }
  bool hasBigVclock() => hasField(12);
  void clearBigVclock() => clearField(12);

  int get smallVclock => getField(13);
  void set smallVclock(int v) { setField(13, v); }
  bool hasSmallVclock() => hasField(13);
  void clearSmallVclock() => clearField(13);

  int get pr => getField(14);
  void set pr(int v) { setField(14, v); }
  bool hasPr() => hasField(14);
  void clearPr() => clearField(14);

  int get r => getField(15);
  void set r(int v) { setField(15, v); }
  bool hasR() => hasField(15);
  void clearR() => clearField(15);

  int get w => getField(16);
  void set w(int v) { setField(16, v); }
  bool hasW() => hasField(16);
  void clearW() => clearField(16);

  int get pw => getField(17);
  void set pw(int v) { setField(17, v); }
  bool hasPw() => hasField(17);
  void clearPw() => clearField(17);

  int get dw => getField(18);
  void set dw(int v) { setField(18, v); }
  bool hasDw() => hasField(18);
  void clearDw() => clearField(18);

  int get rw => getField(19);
  void set rw(int v) { setField(19, v); }
  bool hasRw() => hasField(19);
  void clearRw() => clearField(19);

  bool get basicQuorum => getField(20);
  void set basicQuorum(bool v) { setField(20, v); }
  bool hasBasicQuorum() => hasField(20);
  void clearBasicQuorum() => clearField(20);

  bool get notfoundOk => getField(21);
  void set notfoundOk(bool v) { setField(21, v); }
  bool hasNotfoundOk() => hasField(21);
  void clearNotfoundOk() => clearField(21);

  List<int> get backend => getField(22);
  void set backend(List<int> v) { setField(22, v); }
  bool hasBackend() => hasField(22);
  void clearBackend() => clearField(22);

  bool get search => getField(23);
  void set search(bool v) { setField(23, v); }
  bool hasSearch() => hasField(23);
  void clearSearch() => clearField(23);

  RpbBucketProps_RpbReplMode get repl => getField(24);
  void set repl(RpbBucketProps_RpbReplMode v) { setField(24, v); }
  bool hasRepl() => hasField(24);
  void clearRepl() => clearField(24);
}

