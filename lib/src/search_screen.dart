import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kurban_app/src/models/person.dart';
import 'package:kurban_app/src/providers/group_provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _searchResults = [];

  void _search(String query) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = groupProvider.groups
        .expand((group) => group.members.map((member) {
          return {
            'group': group.groupName,
            'member': member,
            'numParts': member.numPart, // Assuming numPart is an integer or a parsable string
          };
        }))
        .where((result) {
          final member = result['member'];
          if (member is StandalonePerson) {
            return member.name.toLowerCase().contains(query.toLowerCase()) ||
                member.surname.toLowerCase().contains(query.toLowerCase()) ||
                member.phoneNumber.toLowerCase().contains(query.toLowerCase());
          } else if (member is AttachedPerson) {
            return member.name.toLowerCase().contains(query.toLowerCase()) ||
                member.surname.toLowerCase().contains(query.toLowerCase());
          }
          return false;
        })
        .toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _search(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                final member = result['member'];
                final groupName = result['group'];
                final numParts = result['numParts'];

                return Card(
                  color: const Color.fromARGB(255, 200, 200, 200),
                  child: ListTile(
                    title: Text('${member.name} ${member.surname}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        member is AttachedPerson 
                            ? Text('Attached to: ${member.attachedTo.name} ${member.attachedTo.surname}, Phone: ${member.attachedTo.phoneNumber}')
                            : Text('Phone: ${member.phoneNumber}'),
                        Text('Group: $groupName'),
                        Text('Parts: $numParts'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
