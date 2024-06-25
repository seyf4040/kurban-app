import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/providers/group_provider.dart';
import 'package:kurban_app/src/services/generate_pdf.dart';
import 'package:kurban_app/src/services/group_storage.dart';
import 'package:kurban_app/src/group_detail_screen.dart';
import 'package:kurban_app/src/group_form_screen.dart';



class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

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
      if (kDebugMode) {
        print("Error in _loadGroups: $e");
      }
    }
  }

  Future<void> _loadGroups() async {
      final groups = await GroupStorage().loadGroups();
      Provider.of<GroupProvider>(context, listen: false).setGroups(groups.cast<Group>());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadGroupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print("Snapshot error: ${snapshot.error}");
          }
          return const Scaffold(
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
                 appBar: AppBar(
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.print),
                      onPressed: () => GeneratePdf().showPrintAllDialog(context, groupProvider.groups),
                    ),
                ],),
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
                          side: const BorderSide(color: Colors.grey, width: 2),
                          
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
                              builder: (context) => GroupDetailsScreen(group: group, groupIndex: index,),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print),
                              onPressed: () => GeneratePdf().showPrintDialog(context, group),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
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
                              icon: const Icon(Icons.delete),
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
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GroupFormScreen()),
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
