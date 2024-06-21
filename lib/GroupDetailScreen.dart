import 'package:flutter/material.dart';
import 'package:kurban_app/SelectVideo.dart';
import 'models.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Group group;

  GroupDetailsScreen({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('${member.name} ${member.surname}'),
                      subtitle: Text('Telefon numarası: ${member.phoneNumber}'),
                    ),
                  ),
                  Expanded(child: Text('Hisse sayısı: ${member.numPart}/7')),
                ],
              ),
            );
          } else if (member is AttachedPerson) {
            return Card(
              color: const Color.fromARGB(255, 235, 235, 235),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('${member.name} ${member.surname}'),
                      subtitle: Text('Aralık yapan: ${member.attachedTo.name} ${member.attachedTo.surname}'),
                    ),
                  ),
                  Expanded(child: Text('Hisse sayısı: ${member.numPart}/7'))
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
