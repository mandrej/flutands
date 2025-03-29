class PhotoMetadata {
  final String date;
  final int focalLength;
  final int iso;
  final String thumb;
  final int year;
  final String shutter;
  final List<int> dim;
  final String lens;
  final String url;
  final List<String> tags;
  final String nick;
  final double aperture;
  final String filename;
  final int month;
  final int size;
  final String model;
  final List<String> text;
  final int day;
  final String headline;
  final String email;
  final bool flash;

  PhotoMetadata({
    required this.filename,
    required this.headline,
    required this.email,
    required this.nick,
    required this.url,
    required this.thumb,
    required this.size,
    required this.dim,
    required this.tags,

    required this.year,
    required this.month,
    required this.day,

    required this.date,
    required this.focalLength,
    required this.iso,
    required this.shutter,
    required this.lens,
    required this.aperture,
    required this.model,
    required this.text,
    required this.flash,
  });

  factory PhotoMetadata.fromMap(Map<String, dynamic> map) {
    return PhotoMetadata(
      date: map['date'] as String,
      focalLength: map['focal_length'] as int,
      iso: map['iso'] as int,
      thumb: map['thumb'] as String,
      year: map['year'] as int,
      shutter: map['shutter'] as String,
      dim: List<int>.from(map['dim']),
      lens: map['lens'] as String,
      url: map['url'] as String,
      tags: List<String>.from(map['tags']),
      nick: map['nick'] as String,
      aperture: (map['aperture'] as num).toDouble(),
      filename: map['filename'] as String,
      month: map['month'] as int,
      size: map['size'] as int,
      model: map['model'] as String,
      text: List<String>.from(map['text']),
      day: map['day'] as int,
      headline: map['headline'] as String,
      email: map['email'] as String,
      flash: map['flash'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'focal_length': focalLength,
      'iso': iso,
      'thumb': thumb,
      'year': year,
      'shutter': shutter,
      'dim': dim,
      'lens': lens,
      'url': url,
      'tags': tags,
      'nick': nick,
      'aperture': aperture,
      'filename': filename,
      'month': month,
      'size': size,
      'model': model,
      'text': text,
      'day': day,
      'headline': headline,
      'email': email,
      'flash': flash,
    };
  }
}

class Counter {
  final String field;
  final int count;
  final String value;

  Counter({required this.field, required this.count, required this.value});

  factory Counter.fromMap(Map<String, dynamic> map) {
    return Counter(
      field: map['field'] as String,
      count: map['count'] as int,
      value: map['value'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'field': field, 'count': count, 'value': value};
  }
}
