import 'dart:convert';

class Record {
  String filename;
  String headline;
  List<String> tags;
  String email;
  String nick;
  String url;
  String thumb;
  String date;
  int year;
  int month;
  int day;
  int size;
  String model;
  String lens;
  int focalLength;
  int aperture;
  String shutter;
  int iso;
  bool flash;
  String loc;
  List<String> text;

  Record({
    required this.filename,
    required this.headline,
    this.tags = const [],
    required this.email,
    required this.nick,
    required this.url,
    required this.thumb,
    required this.date,
    required this.year,
    required this.month,
    required this.day,
    required this.size,
    this.model = '',
    this.lens = '',
    this.focalLength = 0,
    this.aperture = 0,
    this.shutter = '',
    this.iso = 0,
    this.flash = false,
    this.loc = '',
    this.text = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'headline': headline,
      'tags': tags,
      'email': email,
      'nick': nick,
      'url': url,
      'thumb': thumb,
      'date': date,
      'year': year,
      'month': month,
      'day': day,
      'size': size,
      'model': model,
      'lens': lens,
      'focalLength': focalLength,
      'aperture': aperture,
      'shutter': shutter,
      'iso': iso,
      'flash': flash,
      'loc': loc,
      'text': text,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      filename: map['filename'] ?? '',
      headline: map['headline'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      email: map['email'] ?? '',
      nick: map['nick'] ?? '',
      url: map['url'] ?? '',
      thumb: map['thumb'] ?? '',
      date: map['date'] ?? '',
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      day: map['day'] ?? 0,
      size: map['size'] ?? 0,
      model: map['model'] ?? '',
      lens: map['lens'] ?? '',
      focalLength: map['focalLength'] ?? 0,
      aperture: map['aperture'] ?? 0,
      shutter: map['shutter'] ?? '',
      iso: map['iso'] ?? 0,
      flash: map['flash'] ?? false,
      loc: map['loc'] ?? '',
      text: List<String>.from(map['text'] ?? []),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Record.fromJson(String source) {
    return Record.fromMap(jsonDecode(source));
  }
}
