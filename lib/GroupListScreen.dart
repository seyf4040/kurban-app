import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kurban_app/GroupDetailScreen.dart';
import 'package:kurban_app/GroupFormScreen.dart';
import 'package:kurban_app/GroupProvider.dart';
import 'package:kurban_app/GroupStorage.dart';
import 'package:kurban_app/SettingsScreen.dart';
import 'package:provider/provider.dart';

import 'models.dart';


class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late Future<void> _loadGroupsFuture;

  @override
  void initState() {
    super.initState();
    try {
      _loadGroupsFuture = _loadGroups();
    } catch (e) {
      print("Error in _loadGroups: $e");
    }
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await GroupStorage().loadGroups();
      Provider.of<GroupProvider>(context, listen: false).setGroups(groups.cast<Group>());
    } catch (e) {
      print("Error in _loadGroups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadGroupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          print("Snapshot error: ${snapshot.error}");
          return Scaffold(
            body: Center(child: Text('Error loading groups')),
          );
        } else {
          return Consumer<GroupProvider>(
            builder: (context, groupProvider, child) {
              var totalNumParts = [];
              for (var group in groupProvider.groups) {
                var tmp = 0;
                for (var member in group.members) {
                  tmp += int.parse(member.numPart);
                }
                totalNumParts.add(tmp);
              }

              return Scaffold(
                body: ListView.builder(
                  itemCount: groupProvider.groups.length,
                  itemBuilder: (context, index) {
                    final group = groupProvider.groups[index];
                    return Card(
                      child: ListTile(
                        // titleTextStyle: TextStyle(color: Color.fromRGBO(r, g, b, opacity)),
                        // subtitleTextStyle: TextStyle(),
                        tileColor: const Color.fromRGBO(200, 200, 200, 0.8),
                        minVerticalPadding: 8,
                        horizontalTitleGap: 8,
                        // contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey, width: 2),
                          
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: Text(group.groupName)),
                            Expanded(child: Text('${totalNumParts[index]}/7')),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailsScreen(group: group),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupFormScreen(group: group, groupIndex: index),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                groupProvider.deleteGroup(index);
                                GroupStorage().saveGroups(groupProvider.groups);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupFormScreen()),
                    );
                  },
                ),
                
              );
            },
          );
        }
      },
    );
  }
}
