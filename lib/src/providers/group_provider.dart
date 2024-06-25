import 'package:flutter/material.dart';

import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/services/group_storage.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  void setGroups(List<Group> groups) {
    _groups = groups;
    notifyListeners();
  }

  void addGroup(Group group) {
    if (group.members.length <= 7) {
      _groups.add(group);
      notifyListeners();
    } else {
      throw Exception("A group can have at most 7 members");
    }
  }

  void editGroup(int index, Group group) {
    if (group.members.length <= 7) {
      _groups[index] = group;
      notifyListeners();
    } else {
      throw Exception("A group can have at most 7 members");
    }
  }

  void deleteGroup(int index) {
    _groups.removeAt(index);
    notifyListeners();
  }

   Future<void> _saveGroups() async {
    await GroupStorage().saveGroups(_groups);
  }
}