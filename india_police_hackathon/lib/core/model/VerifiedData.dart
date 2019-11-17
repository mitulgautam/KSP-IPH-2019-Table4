import 'package:flutter/material.dart';

class VerifiedData {
  List<String> _images;
  List<String> _accuracy;
  String _total;

  VerifiedData({List<String> images, List<String> accuracy, String total}) {
    this._images = images;
    this._accuracy = accuracy;
    this._total = total;
  }

  String get total => _total;

  set total(String value) {
    _total = value;
  }

  List<String> get images => _images;

  set images(List<String> value) {
    _images = value;
  }

  List<String> get accuracy => _accuracy;

  VerifiedData.fromJson(Map<String, dynamic> json) {
    var image = json['image'];
    var acc = json['accuracy'];
    total = json['result'];
    if (image.toString().length > 2) {
      print(image.toString().split(","));
      print(acc);
      image = image.toString().substring(1, image.toString().length - 1);
      acc = acc.toString().substring(1, acc.toString().length - 1);
      images = image.toString().split(',');
      accuracy = acc.toString().split(',');
      print(image.toString().split(","));
    }
  }

  set accuracy(List<String> value) {
    _accuracy = value;
  }
}
