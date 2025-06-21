class Values {
  Map<String, int>? year;
  Map<String, int>? month;
  Map<String, int>? tags;
  Map<String, int>? email;
  Map<String, int>? nick;
  Map<String, int>? model;
  Map<String, int>? lens;

  Values({
    required this.year,
    required this.month,
    required this.tags,
    required this.email,
    required this.nick,
    required this.model,
    required this.lens,
  });

  factory Values.fromMap(Map<String, dynamic> map) {
    return Values(
      year: (map['year'] as Map?)?.cast<String, int>(),
      month: (map['month'] as Map?)?.cast<String, int>(),
      tags: (map['tags'] as Map?)?.cast<String, int>(),
      email: (map['email'] as Map?)?.cast<String, int>(),
      nick: (map['nick'] as Map?)?.cast<String, int>(),
      model: (map['model'] as Map?)?.cast<String, int>(),
      lens: (map['lens'] as Map?)?.cast<String, int>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'tags': tags,
      'email': email,
      'nick': nick,
      'model': model,
      'lens': lens,
    };
  }
}
