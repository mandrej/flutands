import 'dart:convert';

class Find {
  int? year;
  int? month;
  List<String>? tags;
  String? model;
  String? lens;
  String? nick;

  Find({this.year, this.month, this.tags, this.model, this.lens, this.nick});

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'tags': tags,
      'model': model,
      'lens': lens,
      'nick': nick,
    };
  }

  factory Find.fromMap(Map<String, dynamic> map) {
    return Find(
      year: map['year'] as int,
      month: map['month'] as int,
      tags: List<String>.from(map['tags'] as List),
      model: map['model'] as String,
      lens: map['lens'] as String,
      nick: map['nick'] as String,
    );
  }

  static Find from(Object object) {
    if (object is Find) {
      return object;
    } else if (object is Map<String, dynamic>) {
      return Find.fromMap(object);
    } else {
      throw ArgumentError('Cannot convert object to Find');
    }
  }

  String toJson() {
    return '{"year":$year,"month":$month,"tags":${tags != null ? tags!.map((e) => '"$e"').toList() : []},"model":"$model","lens":"$lens","nick":"$nick"}';
  }

  factory Find.fromJson(String source) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(
      jsonDecode(source) as Map,
    );
    return Find.fromMap(map);
  }
}
