import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kurban_app/src/models/group.dart';


class GroupStorage {
  static const String _groupsKey = 'groups';

  Future<void> saveGroups(List<Group> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedGroups = groups.map((group) => jsonEncode(group.toJson())).toList();
    await prefs.setStringList(_groupsKey, encodedGroups);
  }

  Future<List> loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedGroups = prefs.getStringList(_groupsKey);

    if (encodedGroups == null) {
      return [];
    }

    return encodedGroups.map((encodedGroup) => Group.fromJson(jsonDecode(encodedGroup))).toList();
  }

  Future<void> clearGroups() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_groupsKey);
  }
}
