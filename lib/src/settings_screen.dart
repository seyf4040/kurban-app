import 'package:flutter/material.dart';

import 'package:kurban_app/src/services/group_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Delete all data button
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Emin misiniz?'),
                  content: const Text('Bütün veriler silinecek. Hisseler, kişiler ve telefon numaraları.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        GroupStorage().clearGroups();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Evet'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hayır'),
                    ),
                  ],
                );
              }
            );
          },
          child: const Text('Verileri Sil'),
        ),
      ],
    );
  }
}
