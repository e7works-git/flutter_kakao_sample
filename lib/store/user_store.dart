import 'package:flutter/material.dart';

// how to get UserStore Value ? => context.watch<UserStore>().name;

class UserStore extends ChangeNotifier {
  String _name = "";
  int selectedIconIndex = -1;

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  String get name {
    return _name;
  }

  // how to change UserStore Value ? => context.read<UserStore>().changeName(changeName);
  changeName(changeName) {
    name = changeName; // want to change Name
    notifyListeners(); // rerendering
  }

  changeIconIndex(index) {
    selectedIconIndex = index;
    notifyListeners();
  }

  reset() {
    _name = '';
    selectedIconIndex = -1;
    notifyListeners();
  }
}
