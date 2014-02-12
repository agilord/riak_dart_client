///
//  Generated code. Do not modify.
///
library riak_kv;

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import 'riak.pb.dart';

class RpbGetClientIdResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetClientIdResp')
    ..a(1, 'clientId', GeneratedMessage.QY)
  ;

  RpbGetClientIdResp() : super();
  RpbGetClientIdResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetClientIdResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetClientIdResp clone() => new RpbGetClientIdResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get clientId => getField(1);
  void set clientId(List<int> v) { setField(1, v); }
  bool hasClientId() => hasField(1);
  void clearClientId() => clearField(1);
}

class RpbSetClientIdReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbSetClientIdReq')
    ..a(1, 'clientId', GeneratedMessage.QY)
  ;

  RpbSetClientIdReq() : super();
  RpbSetClientIdReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbSetClientIdReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbSetClientIdReq clone() => new RpbSetClientIdReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get clientId => getField(1);
  void set clientId(List<int> v) { setField(1, v); }
  bool hasClientId() => hasField(1);
  void clearClientId() => clearField(1);
}

class RpbGetReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'key', GeneratedMessage.QY)
    ..a(3, 'r', GeneratedMessage.OU3)
    ..a(4, 'pr', GeneratedMessage.OU3)
    ..a(5, 'basicQuorum', GeneratedMessage.OB)
    ..a(6, 'notfoundOk', GeneratedMessage.OB)
    ..a(7, 'ifModified', GeneratedMessage.OY)
    ..a(8, 'head', GeneratedMessage.OB)
    ..a(9, 'deletedvclock', GeneratedMessage.OB)
    ..a(10, 'timeout', GeneratedMessage.OU3)
    ..a(11, 'sloppyQuorum', GeneratedMessage.OB)
    ..a(12, 'nVal', GeneratedMessage.OU3)
  ;

  RpbGetReq() : super();
  RpbGetReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetReq clone() => new RpbGetReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  int get r => getField(3);
  void set r(int v) { setField(3, v); }
  bool hasR() => hasField(3);
  void clearR() => clearField(3);

  int get pr => getField(4);
  void set pr(int v) { setField(4, v); }
  bool hasPr() => hasField(4);
  void clearPr() => clearField(4);

  bool get basicQuorum => getField(5);
  void set basicQuorum(bool v) { setField(5, v); }
  bool hasBasicQuorum() => hasField(5);
  void clearBasicQuorum() => clearField(5);

  bool get notfoundOk => getField(6);
  void set notfoundOk(bool v) { setField(6, v); }
  bool hasNotfoundOk() => hasField(6);
  void clearNotfoundOk() => clearField(6);

  List<int> get ifModified => getField(7);
  void set ifModified(List<int> v) { setField(7, v); }
  bool hasIfModified() => hasField(7);
  void clearIfModified() => clearField(7);

  bool get head => getField(8);
  void set head(bool v) { setField(8, v); }
  bool hasHead() => hasField(8);
  void clearHead() => clearField(8);

  bool get deletedvclock => getField(9);
  void set deletedvclock(bool v) { setField(9, v); }
  bool hasDeletedvclock() => hasField(9);
  void clearDeletedvclock() => clearField(9);

  int get timeout => getField(10);
  void set timeout(int v) { setField(10, v); }
  bool hasTimeout() => hasField(10);
  void clearTimeout() => clearField(10);

  bool get sloppyQuorum => getField(11);
  void set sloppyQuorum(bool v) { setField(11, v); }
  bool hasSloppyQuorum() => hasField(11);
  void clearSloppyQuorum() => clearField(11);

  int get nVal => getField(12);
  void set nVal(int v) { setField(12, v); }
  bool hasNVal() => hasField(12);
  void clearNVal() => clearField(12);
}

class RpbGetResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbGetResp')
    ..m(1, 'content', () => new RpbContent(), () => new PbList<RpbContent>())
    ..a(2, 'vclock', GeneratedMessage.OY)
    ..a(3, 'unchanged', GeneratedMessage.OB)
  ;

  RpbGetResp() : super();
  RpbGetResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbGetResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbGetResp clone() => new RpbGetResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<RpbContent> get content => getField(1);

  List<int> get vclock => getField(2);
  void set vclock(List<int> v) { setField(2, v); }
  bool hasVclock() => hasField(2);
  void clearVclock() => clearField(2);

  bool get unchanged => getField(3);
  void set unchanged(bool v) { setField(3, v); }
  bool hasUnchanged() => hasField(3);
  void clearUnchanged() => clearField(3);
}

class RpbPutReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbPutReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'key', GeneratedMessage.OY)
    ..a(3, 'vclock', GeneratedMessage.OY)
    ..a(4, 'content', GeneratedMessage.QM, () => new RpbContent(), () => new RpbContent())
    ..a(5, 'w', GeneratedMessage.OU3)
    ..a(6, 'dw', GeneratedMessage.OU3)
    ..a(7, 'returnBody', GeneratedMessage.OB)
    ..a(8, 'pw', GeneratedMessage.OU3)
    ..a(9, 'ifNotModified', GeneratedMessage.OB)
    ..a(10, 'ifNoneMatch', GeneratedMessage.OB)
    ..a(11, 'returnHead', GeneratedMessage.OB)
    ..a(12, 'timeout', GeneratedMessage.OU3)
    ..a(13, 'asis', GeneratedMessage.OB)
    ..a(14, 'sloppyQuorum', GeneratedMessage.OB)
    ..a(15, 'nVal', GeneratedMessage.OU3)
  ;

  RpbPutReq() : super();
  RpbPutReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbPutReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbPutReq clone() => new RpbPutReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  List<int> get vclock => getField(3);
  void set vclock(List<int> v) { setField(3, v); }
  bool hasVclock() => hasField(3);
  void clearVclock() => clearField(3);

  RpbContent get content => getField(4);
  void set content(RpbContent v) { setField(4, v); }
  bool hasContent() => hasField(4);
  void clearContent() => clearField(4);

  int get w => getField(5);
  void set w(int v) { setField(5, v); }
  bool hasW() => hasField(5);
  void clearW() => clearField(5);

  int get dw => getField(6);
  void set dw(int v) { setField(6, v); }
  bool hasDw() => hasField(6);
  void clearDw() => clearField(6);

  bool get returnBody => getField(7);
  void set returnBody(bool v) { setField(7, v); }
  bool hasReturnBody() => hasField(7);
  void clearReturnBody() => clearField(7);

  int get pw => getField(8);
  void set pw(int v) { setField(8, v); }
  bool hasPw() => hasField(8);
  void clearPw() => clearField(8);

  bool get ifNotModified => getField(9);
  void set ifNotModified(bool v) { setField(9, v); }
  bool hasIfNotModified() => hasField(9);
  void clearIfNotModified() => clearField(9);

  bool get ifNoneMatch => getField(10);
  void set ifNoneMatch(bool v) { setField(10, v); }
  bool hasIfNoneMatch() => hasField(10);
  void clearIfNoneMatch() => clearField(10);

  bool get returnHead => getField(11);
  void set returnHead(bool v) { setField(11, v); }
  bool hasReturnHead() => hasField(11);
  void clearReturnHead() => clearField(11);

  int get timeout => getField(12);
  void set timeout(int v) { setField(12, v); }
  bool hasTimeout() => hasField(12);
  void clearTimeout() => clearField(12);

  bool get asis => getField(13);
  void set asis(bool v) { setField(13, v); }
  bool hasAsis() => hasField(13);
  void clearAsis() => clearField(13);

  bool get sloppyQuorum => getField(14);
  void set sloppyQuorum(bool v) { setField(14, v); }
  bool hasSloppyQuorum() => hasField(14);
  void clearSloppyQuorum() => clearField(14);

  int get nVal => getField(15);
  void set nVal(int v) { setField(15, v); }
  bool hasNVal() => hasField(15);
  void clearNVal() => clearField(15);
}

class RpbPutResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbPutResp')
    ..m(1, 'content', () => new RpbContent(), () => new PbList<RpbContent>())
    ..a(2, 'vclock', GeneratedMessage.OY)
    ..a(3, 'key', GeneratedMessage.OY)
  ;

  RpbPutResp() : super();
  RpbPutResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbPutResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbPutResp clone() => new RpbPutResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<RpbContent> get content => getField(1);

  List<int> get vclock => getField(2);
  void set vclock(List<int> v) { setField(2, v); }
  bool hasVclock() => hasField(2);
  void clearVclock() => clearField(2);

  List<int> get key => getField(3);
  void set key(List<int> v) { setField(3, v); }
  bool hasKey() => hasField(3);
  void clearKey() => clearField(3);
}

class RpbDelReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbDelReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'key', GeneratedMessage.QY)
    ..a(3, 'rw', GeneratedMessage.OU3)
    ..a(4, 'vclock', GeneratedMessage.OY)
    ..a(5, 'r', GeneratedMessage.OU3)
    ..a(6, 'w', GeneratedMessage.OU3)
    ..a(7, 'pr', GeneratedMessage.OU3)
    ..a(8, 'pw', GeneratedMessage.OU3)
    ..a(9, 'dw', GeneratedMessage.OU3)
    ..a(10, 'timeout', GeneratedMessage.OU3)
    ..a(11, 'sloppyQuorum', GeneratedMessage.OB)
    ..a(12, 'nVal', GeneratedMessage.OU3)
  ;

  RpbDelReq() : super();
  RpbDelReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbDelReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbDelReq clone() => new RpbDelReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  int get rw => getField(3);
  void set rw(int v) { setField(3, v); }
  bool hasRw() => hasField(3);
  void clearRw() => clearField(3);

  List<int> get vclock => getField(4);
  void set vclock(List<int> v) { setField(4, v); }
  bool hasVclock() => hasField(4);
  void clearVclock() => clearField(4);

  int get r => getField(5);
  void set r(int v) { setField(5, v); }
  bool hasR() => hasField(5);
  void clearR() => clearField(5);

  int get w => getField(6);
  void set w(int v) { setField(6, v); }
  bool hasW() => hasField(6);
  void clearW() => clearField(6);

  int get pr => getField(7);
  void set pr(int v) { setField(7, v); }
  bool hasPr() => hasField(7);
  void clearPr() => clearField(7);

  int get pw => getField(8);
  void set pw(int v) { setField(8, v); }
  bool hasPw() => hasField(8);
  void clearPw() => clearField(8);

  int get dw => getField(9);
  void set dw(int v) { setField(9, v); }
  bool hasDw() => hasField(9);
  void clearDw() => clearField(9);

  int get timeout => getField(10);
  void set timeout(int v) { setField(10, v); }
  bool hasTimeout() => hasField(10);
  void clearTimeout() => clearField(10);

  bool get sloppyQuorum => getField(11);
  void set sloppyQuorum(bool v) { setField(11, v); }
  bool hasSloppyQuorum() => hasField(11);
  void clearSloppyQuorum() => clearField(11);

  int get nVal => getField(12);
  void set nVal(int v) { setField(12, v); }
  bool hasNVal() => hasField(12);
  void clearNVal() => clearField(12);
}

class RpbListBucketsReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbListBucketsReq')
    ..a(1, 'timeout', GeneratedMessage.OU3)
    ..a(2, 'stream', GeneratedMessage.OB)
    ..hasRequiredFields = false
  ;

  RpbListBucketsReq() : super();
  RpbListBucketsReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbListBucketsReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbListBucketsReq clone() => new RpbListBucketsReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  int get timeout => getField(1);
  void set timeout(int v) { setField(1, v); }
  bool hasTimeout() => hasField(1);
  void clearTimeout() => clearField(1);

  bool get stream => getField(2);
  void set stream(bool v) { setField(2, v); }
  bool hasStream() => hasField(2);
  void clearStream() => clearField(2);
}

class RpbListBucketsResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbListBucketsResp')
    ..p(1, 'buckets', GeneratedMessage.PY)
    ..a(2, 'done', GeneratedMessage.OB)
    ..hasRequiredFields = false
  ;

  RpbListBucketsResp() : super();
  RpbListBucketsResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbListBucketsResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbListBucketsResp clone() => new RpbListBucketsResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<List<int>> get buckets => getField(1);

  bool get done => getField(2);
  void set done(bool v) { setField(2, v); }
  bool hasDone() => hasField(2);
  void clearDone() => clearField(2);
}

class RpbListKeysReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbListKeysReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'timeout', GeneratedMessage.OU3)
  ;

  RpbListKeysReq() : super();
  RpbListKeysReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbListKeysReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbListKeysReq clone() => new RpbListKeysReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  int get timeout => getField(2);
  void set timeout(int v) { setField(2, v); }
  bool hasTimeout() => hasField(2);
  void clearTimeout() => clearField(2);
}

class RpbListKeysResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbListKeysResp')
    ..p(1, 'keys', GeneratedMessage.PY)
    ..a(2, 'done', GeneratedMessage.OB)
    ..hasRequiredFields = false
  ;

  RpbListKeysResp() : super();
  RpbListKeysResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbListKeysResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbListKeysResp clone() => new RpbListKeysResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<List<int>> get keys => getField(1);

  bool get done => getField(2);
  void set done(bool v) { setField(2, v); }
  bool hasDone() => hasField(2);
  void clearDone() => clearField(2);
}

class RpbMapRedReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbMapRedReq')
    ..a(1, 'request', GeneratedMessage.QY)
    ..a(2, 'contentType', GeneratedMessage.QY)
  ;

  RpbMapRedReq() : super();
  RpbMapRedReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbMapRedReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbMapRedReq clone() => new RpbMapRedReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get request => getField(1);
  void set request(List<int> v) { setField(1, v); }
  bool hasRequest() => hasField(1);
  void clearRequest() => clearField(1);

  List<int> get contentType => getField(2);
  void set contentType(List<int> v) { setField(2, v); }
  bool hasContentType() => hasField(2);
  void clearContentType() => clearField(2);
}

class RpbMapRedResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbMapRedResp')
    ..a(1, 'phase', GeneratedMessage.OU3)
    ..a(2, 'response', GeneratedMessage.OY)
    ..a(3, 'done', GeneratedMessage.OB)
    ..hasRequiredFields = false
  ;

  RpbMapRedResp() : super();
  RpbMapRedResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbMapRedResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbMapRedResp clone() => new RpbMapRedResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  int get phase => getField(1);
  void set phase(int v) { setField(1, v); }
  bool hasPhase() => hasField(1);
  void clearPhase() => clearField(1);

  List<int> get response => getField(2);
  void set response(List<int> v) { setField(2, v); }
  bool hasResponse() => hasField(2);
  void clearResponse() => clearField(2);

  bool get done => getField(3);
  void set done(bool v) { setField(3, v); }
  bool hasDone() => hasField(3);
  void clearDone() => clearField(3);
}

class RpbIndexReq_IndexQueryType extends ProtobufEnum {
  static const RpbIndexReq_IndexQueryType eq = const RpbIndexReq_IndexQueryType._(0, 'eq');
  static const RpbIndexReq_IndexQueryType range = const RpbIndexReq_IndexQueryType._(1, 'range');

  static const List<RpbIndexReq_IndexQueryType> values = const <RpbIndexReq_IndexQueryType> [
    eq,
    range,
  ];

  static final Map<int, RpbIndexReq_IndexQueryType> _byValue = ProtobufEnum.initByValue(values);
  static RpbIndexReq_IndexQueryType valueOf(int value) => _byValue[value];

  const RpbIndexReq_IndexQueryType._(int v, String n) : super(v, n);
}

class RpbIndexReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbIndexReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'index', GeneratedMessage.QY)
    ..e(3, 'qtype', GeneratedMessage.QE, () => RpbIndexReq_IndexQueryType.eq, (var v) => RpbIndexReq_IndexQueryType.valueOf(v))
    ..a(4, 'key', GeneratedMessage.OY)
    ..a(5, 'rangeMin', GeneratedMessage.OY)
    ..a(6, 'rangeMax', GeneratedMessage.OY)
    ..a(7, 'returnTerms', GeneratedMessage.OB)
    ..a(8, 'stream', GeneratedMessage.OB)
    ..a(9, 'maxResults', GeneratedMessage.OU3)
    ..a(10, 'continuation', GeneratedMessage.OY)
    ..a(11, 'timeout', GeneratedMessage.OU3)
    ..a(12, 'unused', GeneratedMessage.OY)
    ..a(13, 'termRegex', GeneratedMessage.OY)
    ..a(14, 'paginationSort', GeneratedMessage.OB)
  ;

  RpbIndexReq() : super();
  RpbIndexReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbIndexReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbIndexReq clone() => new RpbIndexReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get index => getField(2);
  void set index(List<int> v) { setField(2, v); }
  bool hasIndex() => hasField(2);
  void clearIndex() => clearField(2);

  RpbIndexReq_IndexQueryType get qtype => getField(3);
  void set qtype(RpbIndexReq_IndexQueryType v) { setField(3, v); }
  bool hasQtype() => hasField(3);
  void clearQtype() => clearField(3);

  List<int> get key => getField(4);
  void set key(List<int> v) { setField(4, v); }
  bool hasKey() => hasField(4);
  void clearKey() => clearField(4);

  List<int> get rangeMin => getField(5);
  void set rangeMin(List<int> v) { setField(5, v); }
  bool hasRangeMin() => hasField(5);
  void clearRangeMin() => clearField(5);

  List<int> get rangeMax => getField(6);
  void set rangeMax(List<int> v) { setField(6, v); }
  bool hasRangeMax() => hasField(6);
  void clearRangeMax() => clearField(6);

  bool get returnTerms => getField(7);
  void set returnTerms(bool v) { setField(7, v); }
  bool hasReturnTerms() => hasField(7);
  void clearReturnTerms() => clearField(7);

  bool get stream => getField(8);
  void set stream(bool v) { setField(8, v); }
  bool hasStream() => hasField(8);
  void clearStream() => clearField(8);

  int get maxResults => getField(9);
  void set maxResults(int v) { setField(9, v); }
  bool hasMaxResults() => hasField(9);
  void clearMaxResults() => clearField(9);

  List<int> get continuation => getField(10);
  void set continuation(List<int> v) { setField(10, v); }
  bool hasContinuation() => hasField(10);
  void clearContinuation() => clearField(10);

  int get timeout => getField(11);
  void set timeout(int v) { setField(11, v); }
  bool hasTimeout() => hasField(11);
  void clearTimeout() => clearField(11);

  List<int> get unused => getField(12);
  void set unused(List<int> v) { setField(12, v); }
  bool hasUnused() => hasField(12);
  void clearUnused() => clearField(12);

  List<int> get termRegex => getField(13);
  void set termRegex(List<int> v) { setField(13, v); }
  bool hasTermRegex() => hasField(13);
  void clearTermRegex() => clearField(13);

  bool get paginationSort => getField(14);
  void set paginationSort(bool v) { setField(14, v); }
  bool hasPaginationSort() => hasField(14);
  void clearPaginationSort() => clearField(14);
}

class RpbIndexResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbIndexResp')
    ..p(1, 'keys', GeneratedMessage.PY)
    ..m(2, 'results', () => new RpbPair(), () => new PbList<RpbPair>())
    ..a(3, 'continuation', GeneratedMessage.OY)
    ..a(4, 'done', GeneratedMessage.OB)
    ..hasRequiredFields = false
  ;

  RpbIndexResp() : super();
  RpbIndexResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbIndexResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbIndexResp clone() => new RpbIndexResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<List<int>> get keys => getField(1);

  List<RpbPair> get results => getField(2);

  List<int> get continuation => getField(3);
  void set continuation(List<int> v) { setField(3, v); }
  bool hasContinuation() => hasField(3);
  void clearContinuation() => clearField(3);

  bool get done => getField(4);
  void set done(bool v) { setField(4, v); }
  bool hasDone() => hasField(4);
  void clearDone() => clearField(4);
}

class RpbCSBucketReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCSBucketReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'startKey', GeneratedMessage.QY)
    ..a(3, 'endKey', GeneratedMessage.OY)
    ..a(4, 'startIncl', GeneratedMessage.OB, () => true)
    ..a(5, 'endIncl', GeneratedMessage.OB)
    ..a(6, 'continuation', GeneratedMessage.OY)
    ..a(7, 'maxResults', GeneratedMessage.OU3)
    ..a(8, 'timeout', GeneratedMessage.OU3)
  ;

  RpbCSBucketReq() : super();
  RpbCSBucketReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCSBucketReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCSBucketReq clone() => new RpbCSBucketReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get startKey => getField(2);
  void set startKey(List<int> v) { setField(2, v); }
  bool hasStartKey() => hasField(2);
  void clearStartKey() => clearField(2);

  List<int> get endKey => getField(3);
  void set endKey(List<int> v) { setField(3, v); }
  bool hasEndKey() => hasField(3);
  void clearEndKey() => clearField(3);

  bool get startIncl => getField(4);
  void set startIncl(bool v) { setField(4, v); }
  bool hasStartIncl() => hasField(4);
  void clearStartIncl() => clearField(4);

  bool get endIncl => getField(5);
  void set endIncl(bool v) { setField(5, v); }
  bool hasEndIncl() => hasField(5);
  void clearEndIncl() => clearField(5);

  List<int> get continuation => getField(6);
  void set continuation(List<int> v) { setField(6, v); }
  bool hasContinuation() => hasField(6);
  void clearContinuation() => clearField(6);

  int get maxResults => getField(7);
  void set maxResults(int v) { setField(7, v); }
  bool hasMaxResults() => hasField(7);
  void clearMaxResults() => clearField(7);

  int get timeout => getField(8);
  void set timeout(int v) { setField(8, v); }
  bool hasTimeout() => hasField(8);
  void clearTimeout() => clearField(8);
}

class RpbCSBucketResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCSBucketResp')
    ..m(1, 'objects', () => new RpbIndexObject(), () => new PbList<RpbIndexObject>())
    ..a(2, 'continuation', GeneratedMessage.OY)
    ..a(3, 'done', GeneratedMessage.OB)
  ;

  RpbCSBucketResp() : super();
  RpbCSBucketResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCSBucketResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCSBucketResp clone() => new RpbCSBucketResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<RpbIndexObject> get objects => getField(1);

  List<int> get continuation => getField(2);
  void set continuation(List<int> v) { setField(2, v); }
  bool hasContinuation() => hasField(2);
  void clearContinuation() => clearField(2);

  bool get done => getField(3);
  void set done(bool v) { setField(3, v); }
  bool hasDone() => hasField(3);
  void clearDone() => clearField(3);
}

class RpbIndexObject extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbIndexObject')
    ..a(1, 'key', GeneratedMessage.QY)
    ..a(2, 'object', GeneratedMessage.QM, () => new RpbGetResp(), () => new RpbGetResp())
  ;

  RpbIndexObject() : super();
  RpbIndexObject.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbIndexObject.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbIndexObject clone() => new RpbIndexObject()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get key => getField(1);
  void set key(List<int> v) { setField(1, v); }
  bool hasKey() => hasField(1);
  void clearKey() => clearField(1);

  RpbGetResp get object => getField(2);
  void set object(RpbGetResp v) { setField(2, v); }
  bool hasObject() => hasField(2);
  void clearObject() => clearField(2);
}

class RpbContent extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbContent')
    ..a(1, 'value', GeneratedMessage.QY)
    ..a(2, 'contentType', GeneratedMessage.OY)
    ..a(3, 'charset', GeneratedMessage.OY)
    ..a(4, 'contentEncoding', GeneratedMessage.OY)
    ..a(5, 'vtag', GeneratedMessage.OY)
    ..m(6, 'links', () => new RpbLink(), () => new PbList<RpbLink>())
    ..a(7, 'lastMod', GeneratedMessage.OU3)
    ..a(8, 'lastModUsecs', GeneratedMessage.OU3)
    ..m(9, 'usermeta', () => new RpbPair(), () => new PbList<RpbPair>())
    ..m(10, 'indexes', () => new RpbPair(), () => new PbList<RpbPair>())
    ..a(11, 'deleted', GeneratedMessage.OB)
  ;

  RpbContent() : super();
  RpbContent.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbContent.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbContent clone() => new RpbContent()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get value => getField(1);
  void set value(List<int> v) { setField(1, v); }
  bool hasValue() => hasField(1);
  void clearValue() => clearField(1);

  List<int> get contentType => getField(2);
  void set contentType(List<int> v) { setField(2, v); }
  bool hasContentType() => hasField(2);
  void clearContentType() => clearField(2);

  List<int> get charset => getField(3);
  void set charset(List<int> v) { setField(3, v); }
  bool hasCharset() => hasField(3);
  void clearCharset() => clearField(3);

  List<int> get contentEncoding => getField(4);
  void set contentEncoding(List<int> v) { setField(4, v); }
  bool hasContentEncoding() => hasField(4);
  void clearContentEncoding() => clearField(4);

  List<int> get vtag => getField(5);
  void set vtag(List<int> v) { setField(5, v); }
  bool hasVtag() => hasField(5);
  void clearVtag() => clearField(5);

  List<RpbLink> get links => getField(6);

  int get lastMod => getField(7);
  void set lastMod(int v) { setField(7, v); }
  bool hasLastMod() => hasField(7);
  void clearLastMod() => clearField(7);

  int get lastModUsecs => getField(8);
  void set lastModUsecs(int v) { setField(8, v); }
  bool hasLastModUsecs() => hasField(8);
  void clearLastModUsecs() => clearField(8);

  List<RpbPair> get usermeta => getField(9);

  List<RpbPair> get indexes => getField(10);

  bool get deleted => getField(11);
  void set deleted(bool v) { setField(11, v); }
  bool hasDeleted() => hasField(11);
  void clearDeleted() => clearField(11);
}

class RpbLink extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbLink')
    ..a(1, 'bucket', GeneratedMessage.OY)
    ..a(2, 'key', GeneratedMessage.OY)
    ..a(3, 'tag', GeneratedMessage.OY)
    ..hasRequiredFields = false
  ;

  RpbLink() : super();
  RpbLink.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbLink.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbLink clone() => new RpbLink()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  List<int> get tag => getField(3);
  void set tag(List<int> v) { setField(3, v); }
  bool hasTag() => hasField(3);
  void clearTag() => clearField(3);
}

class RpbCounterUpdateReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCounterUpdateReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'key', GeneratedMessage.QY)
    ..a(3, 'amount', GeneratedMessage.QS6, () => makeLongInt(0))
    ..a(4, 'w', GeneratedMessage.OU3)
    ..a(5, 'dw', GeneratedMessage.OU3)
    ..a(6, 'pw', GeneratedMessage.OU3)
    ..a(7, 'returnvalue', GeneratedMessage.OB)
  ;

  RpbCounterUpdateReq() : super();
  RpbCounterUpdateReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCounterUpdateReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCounterUpdateReq clone() => new RpbCounterUpdateReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  Int64 get amount => getField(3);
  void set amount(Int64 v) { setField(3, v); }
  bool hasAmount() => hasField(3);
  void clearAmount() => clearField(3);

  int get w => getField(4);
  void set w(int v) { setField(4, v); }
  bool hasW() => hasField(4);
  void clearW() => clearField(4);

  int get dw => getField(5);
  void set dw(int v) { setField(5, v); }
  bool hasDw() => hasField(5);
  void clearDw() => clearField(5);

  int get pw => getField(6);
  void set pw(int v) { setField(6, v); }
  bool hasPw() => hasField(6);
  void clearPw() => clearField(6);

  bool get returnvalue => getField(7);
  void set returnvalue(bool v) { setField(7, v); }
  bool hasReturnvalue() => hasField(7);
  void clearReturnvalue() => clearField(7);
}

class RpbCounterUpdateResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCounterUpdateResp')
    ..a(1, 'value', GeneratedMessage.OS6, () => makeLongInt(0))
    ..hasRequiredFields = false
  ;

  RpbCounterUpdateResp() : super();
  RpbCounterUpdateResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCounterUpdateResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCounterUpdateResp clone() => new RpbCounterUpdateResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  Int64 get value => getField(1);
  void set value(Int64 v) { setField(1, v); }
  bool hasValue() => hasField(1);
  void clearValue() => clearField(1);
}

class RpbCounterGetReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCounterGetReq')
    ..a(1, 'bucket', GeneratedMessage.QY)
    ..a(2, 'key', GeneratedMessage.QY)
    ..a(3, 'r', GeneratedMessage.OU3)
    ..a(4, 'pr', GeneratedMessage.OU3)
    ..a(5, 'basicQuorum', GeneratedMessage.OB)
    ..a(6, 'notfoundOk', GeneratedMessage.OB)
  ;

  RpbCounterGetReq() : super();
  RpbCounterGetReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCounterGetReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCounterGetReq clone() => new RpbCounterGetReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get bucket => getField(1);
  void set bucket(List<int> v) { setField(1, v); }
  bool hasBucket() => hasField(1);
  void clearBucket() => clearField(1);

  List<int> get key => getField(2);
  void set key(List<int> v) { setField(2, v); }
  bool hasKey() => hasField(2);
  void clearKey() => clearField(2);

  int get r => getField(3);
  void set r(int v) { setField(3, v); }
  bool hasR() => hasField(3);
  void clearR() => clearField(3);

  int get pr => getField(4);
  void set pr(int v) { setField(4, v); }
  bool hasPr() => hasField(4);
  void clearPr() => clearField(4);

  bool get basicQuorum => getField(5);
  void set basicQuorum(bool v) { setField(5, v); }
  bool hasBasicQuorum() => hasField(5);
  void clearBasicQuorum() => clearField(5);

  bool get notfoundOk => getField(6);
  void set notfoundOk(bool v) { setField(6, v); }
  bool hasNotfoundOk() => hasField(6);
  void clearNotfoundOk() => clearField(6);
}

class RpbCounterGetResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbCounterGetResp')
    ..a(1, 'value', GeneratedMessage.OS6, () => makeLongInt(0))
    ..hasRequiredFields = false
  ;

  RpbCounterGetResp() : super();
  RpbCounterGetResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbCounterGetResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbCounterGetResp clone() => new RpbCounterGetResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  Int64 get value => getField(1);
  void set value(Int64 v) { setField(1, v); }
  bool hasValue() => hasField(1);
  void clearValue() => clearField(1);
}

