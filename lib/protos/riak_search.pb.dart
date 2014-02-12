///
//  Generated code. Do not modify.
///
library riak_search;

import 'package:protobuf/protobuf.dart';
import 'riak.pb.dart';

class RpbSearchDoc extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbSearchDoc')
    ..m(1, 'fields', () => new RpbPair(), () => new PbList<RpbPair>())
    ..hasRequiredFields = false
  ;

  RpbSearchDoc() : super();
  RpbSearchDoc.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbSearchDoc.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbSearchDoc clone() => new RpbSearchDoc()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<RpbPair> get fields => getField(1);
}

class RpbSearchQueryReq extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbSearchQueryReq')
    ..a(1, 'q', GeneratedMessage.QY)
    ..a(2, 'index', GeneratedMessage.QY)
    ..a(3, 'rows', GeneratedMessage.OU3)
    ..a(4, 'start', GeneratedMessage.OU3)
    ..a(5, 'sort', GeneratedMessage.OY)
    ..a(6, 'filter', GeneratedMessage.OY)
    ..a(7, 'df', GeneratedMessage.OY)
    ..a(8, 'op', GeneratedMessage.OY)
    ..p(9, 'fl', GeneratedMessage.PY)
    ..a(10, 'presort', GeneratedMessage.OY)
  ;

  RpbSearchQueryReq() : super();
  RpbSearchQueryReq.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbSearchQueryReq.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbSearchQueryReq clone() => new RpbSearchQueryReq()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<int> get q => getField(1);
  void set q(List<int> v) { setField(1, v); }
  bool hasQ() => hasField(1);
  void clearQ() => clearField(1);

  List<int> get index => getField(2);
  void set index(List<int> v) { setField(2, v); }
  bool hasIndex() => hasField(2);
  void clearIndex() => clearField(2);

  int get rows => getField(3);
  void set rows(int v) { setField(3, v); }
  bool hasRows() => hasField(3);
  void clearRows() => clearField(3);

  int get start => getField(4);
  void set start(int v) { setField(4, v); }
  bool hasStart() => hasField(4);
  void clearStart() => clearField(4);

  List<int> get sort => getField(5);
  void set sort(List<int> v) { setField(5, v); }
  bool hasSort() => hasField(5);
  void clearSort() => clearField(5);

  List<int> get filter => getField(6);
  void set filter(List<int> v) { setField(6, v); }
  bool hasFilter() => hasField(6);
  void clearFilter() => clearField(6);

  List<int> get df => getField(7);
  void set df(List<int> v) { setField(7, v); }
  bool hasDf() => hasField(7);
  void clearDf() => clearField(7);

  List<int> get op => getField(8);
  void set op(List<int> v) { setField(8, v); }
  bool hasOp() => hasField(8);
  void clearOp() => clearField(8);

  List<List<int>> get fl => getField(9);

  List<int> get presort => getField(10);
  void set presort(List<int> v) { setField(10, v); }
  bool hasPresort() => hasField(10);
  void clearPresort() => clearField(10);
}

class RpbSearchQueryResp extends GeneratedMessage {
  static final BuilderInfo _i = new BuilderInfo('RpbSearchQueryResp')
    ..m(1, 'docs', () => new RpbSearchDoc(), () => new PbList<RpbSearchDoc>())
    ..a(2, 'maxScore', GeneratedMessage.OF)
    ..a(3, 'numFound', GeneratedMessage.OU3)
    ..hasRequiredFields = false
  ;

  RpbSearchQueryResp() : super();
  RpbSearchQueryResp.fromBuffer(List<int> i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RpbSearchQueryResp.fromJson(String i, [ExtensionRegistry r = ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RpbSearchQueryResp clone() => new RpbSearchQueryResp()..mergeFromMessage(this);
  BuilderInfo get info_ => _i;

  List<RpbSearchDoc> get docs => getField(1);

  double get maxScore => getField(2);
  void set maxScore(double v) { setField(2, v); }
  bool hasMaxScore() => hasField(2);
  void clearMaxScore() => clearField(2);

  int get numFound => getField(3);
  void set numFound(int v) { setField(3, v); }
  bool hasNumFound() => hasField(3);
  void clearNumFound() => clearField(3);
}

