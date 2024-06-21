import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kurban_app/GroupDetailScreen.dart';
import 'package:kurban_app/GroupFormScreen.dart';
import 'package:kurban_app/GroupListScreen.dart';
import 'package:kurban_app/GroupProvider.dart';
import 'package:kurban_app/GroupStorage.dart';
import 'package:kurban_app/SettingsScreen.dart';
import 'package:provider/provider.dart';

import 'models.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GroupProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadGroupsFuture;

  int _currentIndex = 0;

  final List<Widget> _pages = [
    GroupListScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hisse Derleme')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }    
}
