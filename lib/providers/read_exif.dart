// import 'package:firebase_core/firebase_core.dart';
// ignore_for_file: prefer_single_quotes

import 'package:firebase_storage/firebase_storage.dart';
import 'package:exif/exif.dart';
// import '../firebase_options.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

Future readExif(filename) async {
  Map<String, dynamic> result = {};
  // final reFilename = RegExp(r'^(.*?)(\.[^.]*)?$');
  // final match = reFilename.firstMatch(filename);
  // if (match == null) {
  //   print('Invalid filename format');
  //   return;
  // }
  // final thumbFielname = '${match[1]}_400x400.jpeg';
  // print(thumbFielname);
  Reference ref = FirebaseStorage.instance.ref().child(filename);
  try {
    const maxSize = 4 * 1024 * 1024;
    final Uint8List? data = await ref.getData(maxSize);

    if (data == null) {
      print('Failed to retrieve data from Firebase Storage');
      return;
    }
    final exif = await readExifFromBytes(data);
    // Data for "images/island.jpg" is returned, use this as needed.
    if (exif.isEmpty) {
      print('No EXIF information found');
      return;
    }

    // for (final entry in exif.entries) {
    //   print("${entry.key}: ${entry.value}");
    // }
    result['model'] = exif['Image Model'].toString();
    result['lens'] = exif['EXIF LensModel'].toString().replaceAll('/', '');
    // 2025:03:30 19:05:04
    var fixDate = exif['EXIF DateTimeOriginal'].toString().replaceAllMapped(
      RegExp(r'(\d{4}):(\d{2}):(\d{2})'),
      (match) => '${match[1]}-${match[2]}-${match[3]}',
    );
    var date = DateTime.parse(fixDate);
    result['date'] = DateFormat('yyyy-MM-dd HH:mm').format(date);
    result['year'] = date.year;
    result['month'] = date.month;
    result['day'] = date.day;

    var r = exif['EXIF FNumber']!.values.toList().first;
    result['aperture'] = r.numerator / r.denominator;
    result['shutter'] = exif['EXIF ExposureTime'].toString();

    /*
    Reading EXIF data from 20250420-DSC_8542.jpg
    Image Make: NIKON CORPORATION
    Image Model: NIKON Z 6_2

    Image Software: Adobe Lightroom 8.2 (Macintosh)
    Image DateTime: 2025:04:20 17:05:29
    Image Artist: MILAN ANDREJEVIC
    Image Copyright: MILAN ANDREJEVIC

    EXIF ExposureTime: 1/200
    EXIF FNumber: 4
    EXIF ExposureProgram: Shutter Priority
    EXIF ISOSpeedRatings: 720

    EXIF ExifVersion: 0231
    EXIF DateTimeOriginal: 2025:04:20 13:49:37
    EXIF DateTimeDigitized: 2025:04:20 13:49:37

    EXIF ShutterSpeedValue: 477741/62500
    EXIF ApertureValue: 4
    EXIF ExposureBiasValue: -1
    EXIF MeteringMode: Pattern

    EXIF Flash: Flash fired, compulsory flash mode, return light detected
    EXIF FocalLength: 51/2

    EXIF FocalLengthIn35mmFilm: 25

    EXIF BodySerialNumber: 6102829
    EXIF LensMake: NIKON
    EXIF LensModel: NIKKOR Z 24-70mm f/4 S
    EXIF LensSerialNumber: 20165475
    */
    // for (final entry in exif.entries) {
    //   print('${entry.key}: ${entry.value}');
    // }
  } on FirebaseException catch (e) {
    print(e);
  }

  print('xxxxxxxxxxxxxx $result');
  return result;
}
