import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:india_police_hackathon/core/model/VerifiedData.dart';

class DashboardProvider extends ChangeNotifier {
  List<String> _resultList = [];
  bool _facebook = false;
  bool _google = false;
  bool _instagram = false;
  bool _localDB = false;
  double _sliderValue = 0.4;
  TextEditingController _name = TextEditingController();
  bool _showResult = false;
  VerifiedData _verifiedData;
  File _image;

  File get image => _image;

  set image(File value) {
    _image = value;
    notifyListeners();
  }

  VerifiedData get verifiedData => _verifiedData;

  set verifiedData(VerifiedData value) {
    _verifiedData = value;
    notifyListeners();
  }

  bool get showResult => _showResult;

  set showResult(bool value) {
    _showResult = value;
    notifyListeners();
  }

  double get sliderValue => _sliderValue;

  set sliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  TextEditingController get name => _name;

  bool get facebook => _facebook;

  clearListResult() {
    resultList = [];
    notifyListeners();
  }

  set facebook(bool value) {
    _facebook = value;
    notifyListeners();
  }

  List<String> get resultList => _resultList;

  addElement(String _) {
    resultList.add(_);
    notifyListeners();
  }

  set resultList(List<String> value) {
    _resultList = value;
    notifyListeners();
  }

  bool get google => _google;

  set google(bool value) {
    _google = value;
    notifyListeners();
  }

  bool get instagram => _instagram;

  set instagram(bool value) {
    _instagram = value;
    notifyListeners();
  }

  bool get localDB => _localDB;

  set localDB(bool value) {
    _localDB = value;
    notifyListeners();
  }
}
