import 'package:flutter/material.dart';
import 'package:kurban_app/src/group_form_screen.dart';

import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/person_form_screen.dart';
import 'package:kurban_app/src/providers/group_provider.dart';
import 'package:kurban_app/src/services/generate_pdf.dart';
import 'package:kurban_app/src/models/person.dart';
import 'package:kurban_app/src/services/group_storage.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Group group;
  final int groupIndex;

  const GroupDetailsScreen({super.key, required this.group, required this.groupIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) { 
        if (groupIndex >= groupProvider.groups.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return Container(); // Return an empty container while navigating back
        }
        final group = groupProvider.groups[groupIndex];
        return Scaffold(
          appBar: AppBar(
            title: Text(group.groupName),
            actions: [
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
                      builder: (context) => GroupFormScreen(group: group, groupIndex: groupIndex),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  groupProvider.deleteGroup(groupIndex);
                  GroupStorage().saveGroups(groupProvider.groups);
                },
              ),
              IconButton(
                icon: const Icon(Icons.video_call),
                onPressed: () => pickAndShareVideo(group),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: group.members.length,
            itemBuilder: (context, index) {
              final member = group.members[index];
              if (member is StandalonePerson) {
                return Card(
                  color: const Color.fromARGB(255, 235, 235, 235),
                  child: ListTile(
                    title: Text('${member.name} ${member.surname}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telefon numarası: ${member.phoneNumber}'),
                        // const SizedBox(height: 5,),
                        Text('Hisse sayısı: ${member.numPart}/7'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonFormScreen(group: group, personIndex: index, groupIndex: groupIndex),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else if (member is AttachedPerson) {
                return Card(
                  color: const Color.fromARGB(255, 235, 235, 235),
                  child: ListTile(
                    title: Text('${member.name} ${member.surname}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aralık yapan: ${member.attachedTo.name} ${member.attachedTo.surname}'),
                        // const SizedBox(height: 5,),
                        Text('Hisse sayısı: ${member.numPart}/7')
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonFormScreen(group: group, personIndex: index, groupIndex: groupIndex),
                            ),
                          );
                        },
                      ),
                  ),
                );
              }
              return Container();
            },
          ),
        );
      }
    );
  }  
}

void pickAndShareVideo(Group group) {
  // Implement your video picking and sharing logic here
}
