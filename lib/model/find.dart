class Find {
  int year;
  int month;
  List<String> tags;
  String model;
  String lens;
  String nick;

  Find({
    required this.year,
    required this.month,
    required this.tags,
    required this.model,
    required this.lens,
    required this.nick,
  });

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
}
