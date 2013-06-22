// Copyright (c) 2012-2013, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

/** Data holder with format, header and index metadata. */
class Content {

  /** Media type e.g. 'text/plain'. */
  final ContentType type;

  /** Data format e.g. 'text' or 'stream'. */
  final DataFormat  format;

  /** The data entry, instance of String, Map or Stream. */
  final dynamic     data;

  /** Header metadata. */
  final MetaData    header;

  /** Secondary index. */
  final MetaData    index;

  String            get asText   => format.isText ? data : null;
  Map               get asJson   => format.isJson ? data : null;
  Stream<List<int>> get asStream => format.isStream ? data : null;

  Content._(this.type, this.format, this.data, this.header, this.index);

  /** Creates a text content. */
  factory Content.text(String text,
      { ContentType type, MetaData header, MetaData index }) =>
          new Content._(type == null ? MediaType.TEXT_PLAIN : type,
              DataFormat.TEXT, text, header, index);

  /** Creates a JSON content from a Map. */
  factory Content.json(Map map, { MetaData header, MetaData index }) =>
      new Content._(MediaType.JSON, DataFormat.JSON, map, header, index);

  /** Creates a stream-based content. */
  factory Content.stream(Stream<List<int>> stream,
      { ContentType type, MetaData header, MetaData index }) =>
          new Content._(type == null ? MediaType.BINARY : type,
              DataFormat.STREAM, stream, header, index);
}

/** Common metadata format for header and secondary index. */
class MetaData {
  final Map<String, Iterable<String>> _map;

  Iterator<String> getKeys() => _map.keys.iterator;
  Iterator<String> getValues(String key) => _map[key].iterator;

  MetaData._(this._map);
}

/** Helper methods and fields to match different media/content types. */
class MediaType {
  static final JSON = new ContentType("application", "json");
  static final TEXT_PLAIN = new ContentType("text", "plain");
  static final TEXT_HTML = new ContentType("text", "html");
  static final BINARY = new ContentType("application", "octet-stream");

  static bool isText(ContentType type) =>
      type.primaryType == "text";

  static bool isJson(ContentType type) =>
      typeEquals(type, JSON);

  static bool isBinary(ContentType type) =>
      typeEquals(type, BINARY);

  static typeEquals(ContentType a, ContentType b) {
    return a == b || (a.primaryType == b.primaryType && a.subType == b.subType);
  }
}

/**
 * Data format enum, describing the data format, helping implementation methods
 * how to handle the data.
 */
class DataFormat {
  final String code;
  const DataFormat(this.code);

  static final TEXT   = const DataFormat("text");
  static final JSON   = const DataFormat("json");
  static final STREAM = const DataFormat("stream");

  bool get isText   => this == TEXT;
  bool get isJson   => this == JSON;
  bool get isStream => this == STREAM;
}

/** Builds header metadata. */
class HeaderBuilder {
  Map<String, List<String>> _map = new LinkedHashMap();

  add(String name, String value) {
    if (name == null || value == null || name.isEmpty || value.isEmpty) {
      return;
    }
    List<String> list = _map[name];
    if (list == null) {
      list = new List();
      _map[name] = list;
    }
    list.add(value);
  }

  addString(String name, String value) => add(name, value);

  addDate(String name, DateTime dateTime, [ String sep ]) =>
      add(name, DateTimeUtils.date(dateTime, sep));

  addTime(String name, DateTime dateTime, [ String sep ]) =>
      add(name, DateTimeUtils.time(dateTime, sep));

  addTimestamp(String name, DateTime dateTime,
      { String dateSeparator, String timeSeparator, String dtSep }) =>
          add(name, DateTimeUtils.timestamp(dateTime,
              dateSeparator:dateSeparator,
              timeSeparator:timeSeparator, dtSep:dtSep));

  MetaData build() {
    if (_map == null) {
      throw "build already called on this object";
    }
    MetaData md = new MetaData._(_map);
    _map = null;
    return md;
  }
}

/** Builds secondary index metadata. */
class IndexBuilder {

  final HeaderBuilder _builder = new HeaderBuilder();

  addInt(String name, int value) =>
      _builder.add("${name}_int", value.toString());
  addInts(String name, List<int> values) =>
      values.forEach((x) { addInt(name, x); });

  addString(String name, String value) =>
      _builder.add("${name}_bin", value);
  addStrings(String name, List<String> values) =>
      values.forEach((x) { addString(name, x); });

  addDate(String name, DateTime dateTime, [ String sep ]) =>
      addString(name, DateTimeUtils.date(dateTime, sep));

  addTime(String name, DateTime dateTime, [ String sep ]) =>
      addString(name, DateTimeUtils.time(dateTime, sep));

  addTimestamp(String name, DateTime dateTime,
      { String dateSeparator, String timeSeparator, String dtSep }) =>
          addString(name, DateTimeUtils.timestamp(dateTime,
              dateSeparator:dateSeparator,
              timeSeparator:timeSeparator, dtSep:dtSep));

  MetaData build() => _builder.build();
}

/** Some date-related helper method. */
class DateTimeUtils {

  String _d3(int n) {
    if (n >= 100) { return "$n"; }
    if (n >= 10) { return "0$n"; }
    return "00$n";
  }

  String _d2(int n) {
    if (n >= 10) { return "$n"; }
    return "0$n";
  }

  static String date(DateTime dateTime, [ String sep ]) {
    if (dateTime == null) { return null; }
    StringBuffer sb = new StringBuffer();
    sb.write(dateTime.year);
    if (sep != null) { sb.write(sep); }
    sb.write(_d2(dateTime.month));
    if (sep != null) { sb.write(sep); }
    sb.write(_d2(dateTime.day));
    return sb.toString();
  }

  static String time(DateTime dateTime, [ String sep ]) {
    if (dateTime == null) { return null; }
    StringBuffer sb = new StringBuffer();
    sb.write(_d2(dateTime.hour));
    if (sep != null) { sb.write(sep); }
    sb.write(_d2(dateTime.minute));
    if (sep != null) { sb.write(sep); }
    sb.write(_d2(dateTime.second));
    sb.write(".");
    sb.write(_d3(dateTime.millisecond));
    return sb.toString();
  }

  static String timestamp(DateTime dateTime,
      { String dateSeparator, String timeSeparator, String dtSep }) {
    if (dateTime == null) { return null; }
    StringBuffer sb = new StringBuffer();
    sb.write(date(dateTime, dateSeparator));
    if (dtSep != null) { sb.write(dtSep); }
    sb.write(time(dateTime, timeSeparator));
    return sb.toString();
  }
}
