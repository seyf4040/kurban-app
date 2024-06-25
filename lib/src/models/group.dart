import 'package:kurban_app/src/models/person.dart';

class Group {
  String groupName;
  List<dynamic> members; // Can be StandalonePerson or AttachedPerson

  Group({required this.groupName, required this.members});

  num get length => members.length;
  
  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'members': members.map((member) {
        if (member is StandalonePerson) {
          return {
            'type': 'StandalonePerson',
            'name': member.name,
            'surname': member.surname,
            'phoneNumber': member.phoneNumber,
            'numPart': member.numPart,
          };
        } else if (member is AttachedPerson) {
          return {
            'type': 'AttachedPerson',
            'name': member.name,
            'surname': member.surname,
            'attachedTo': members.indexOf(member.attachedTo),
            'numPart': member.numPart,
          };
        }
        return {};
      }).toList(),
    };
  }

  static Group fromJson(Map<String, dynamic> json) {
    final members = <dynamic>[];
    for (var memberJson in json['members']) {
      if (memberJson['type'] == 'StandalonePerson') {
        members.add(StandalonePerson(
          name: memberJson['name'],
          surname: memberJson['surname'],
          phoneNumber: memberJson['phoneNumber'],
          numPart: memberJson['numPart'],
        ));
      } else if (memberJson['type'] == 'AttachedPerson') {
        members.add(AttachedPerson(
          name: memberJson['name'],
          surname: memberJson['surname'],
          attachedTo: StandalonePerson(
            name: json['members'][memberJson['attachedTo']]['name'],
            surname: json['members'][memberJson['attachedTo']]['surname'],
            phoneNumber: json['members'][memberJson['attachedTo']]['phoneNumber'],
            numPart: json['members'][memberJson['attachedTo']]['numPart'],
          ), // We'll resolve this after creating all members
          numPart: memberJson['numPart'],
        ));
      }
    }
    return Group(
      groupName: json['groupName'],
      members: members,
    );
  }

}

