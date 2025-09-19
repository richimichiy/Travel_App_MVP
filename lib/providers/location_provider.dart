import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  bool _showTopBrazil = true;
  bool _showStates = false;
  bool _showRioTop10 = false;

  bool get showTopBrazil => _showTopBrazil;
  bool get showStates => _showStates;
  bool get showRioTop10 => _showRioTop10;

  void toggleTopBrazil() {
    _showTopBrazil = !_showTopBrazil;
    notifyListeners();
  }

  void toggleStates() {
    _showStates = !_showStates;
    notifyListeners();
  }

  void toggleRioTop10() {
    _showRioTop10 = !_showRioTop10;
    if (_showRioTop10) {
      _showTopBrazil = false; // Hide Brazil when Rio is active
    }
    notifyListeners();
  }
}
