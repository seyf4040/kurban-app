import 'package:flutter/material.dart';
import 'package:kurban_app/GroupStorage.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Delete all data button
        ElevatedButton(
          onPressed: () {
            GroupStorage().clearGroups();
          },
          child: Text('Verileri Sil'),
        ),
      ],
    );
  }
}
