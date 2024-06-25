import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import 'package:kurban_app/src/models/person.dart';
import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/providers/group_provider.dart';
import 'package:kurban_app/src/services/group_storage.dart';


class GroupFormScreen extends StatefulWidget {
  final Group? group;
  final int? groupIndex;

  const GroupFormScreen({super.key, this.group, this.groupIndex});

  @override
  _GroupFormScreenState createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _surnameControllers = [];
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _numPartControllers = [];
  final List<int?> _attachedToIndexes = [];

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _groupNameController.text = widget.group!.groupName;
      for (var member in widget.group!.members) {
        _nameControllers.add(TextEditingController(text: member.name));
        _surnameControllers.add(TextEditingController(text: member.surname));
        _numPartControllers.add(TextEditingController(text: member.numPart));
        if (member is StandalonePerson) {
          _phoneControllers.add(TextEditingController(text: member.phoneNumber));
          _attachedToIndexes.add(null);
        } else if (member is AttachedPerson) {
          _phoneControllers.add(TextEditingController());
          _attachedToIndexes.add(widget.group!.members.indexOf(member.attachedTo));
        }
      }
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _surnameControllers) {
      controller.dispose();
    }
    for (var controller in _numPartControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addStandalonePersonField() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _surnameControllers.add(TextEditingController());
      _numPartControllers.add(TextEditingController(text: '1'));
      _phoneControllers.add(TextEditingController());
      _attachedToIndexes.add(null);
    });
  }

  void _addAttachedPersonField(int attachedToIndex) {
    setState(() {
      _nameControllers.insert(attachedToIndex+1, TextEditingController());
      _surnameControllers.insert(attachedToIndex+1, TextEditingController());
      _numPartControllers.insert(attachedToIndex+1, TextEditingController(text: '1'));
      _phoneControllers.insert(attachedToIndex+1, TextEditingController());
      _attachedToIndexes.insert(attachedToIndex+1, attachedToIndex);

      for (var i = 0; i < _attachedToIndexes.length; i++) {
        if (_attachedToIndexes[i] !=null && _attachedToIndexes[i]! > attachedToIndex){
          _attachedToIndexes[i] = _attachedToIndexes[i] == null ? null : _attachedToIndexes[i]! + 1;
        }  
      }
    });
  }

  void _removeMember(int index) {

    setState(() {
      _nameControllers.removeAt(index);
      _surnameControllers.removeAt(index);
      _numPartControllers.removeAt(index);
      _phoneControllers.removeAt(index);
      _attachedToIndexes.removeAt(index);
      
       // Decrement all indexes in _attachedToIndexes that are greater than the removed index
    for (int i = 0; i < _attachedToIndexes.length; i++) {
      if (_attachedToIndexes[i] != null &&_attachedToIndexes[i]! > index) {
        _attachedToIndexes[i] = _attachedToIndexes[i]!-1;
      }
    }

    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final groupName = _groupNameController.text;
      final members = <dynamic>[];

      for (int i = 0; i < _nameControllers.length; i++) {
        final name = _nameControllers[i].text;
        final surname = _surnameControllers[i].text;
        final numPart = _numPartControllers[i].text;
        final phoneNumber = _phoneControllers[i].text;
        final attachedToIndex = _attachedToIndexes[i];

        // print("index: $i");
        // print("name: $name");
        // print("surname: $surname");
        // print("numPart: $numPart");
        // print("phoneNumber: $phoneNumber");
        // print("attachedToIndex: $attachedToIndex");
        
        if (attachedToIndex == null) {
          if(phoneNumber == ''){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lütfen bir telefon numarası girin')),
            );
          return; 
          }
          members.add(StandalonePerson(name: name, surname: surname, phoneNumber: phoneNumber, numPart: numPart));
        } else {
          
          final attachedTo = members[attachedToIndex];
          members.add(AttachedPerson(name: name, surname: surname, attachedTo: attachedTo, numPart: numPart));
        }
      }

      final group = Group(groupName: groupName, members: members);

      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      if (widget.group == null) {
        groupProvider.addGroup(group);
      } else {
        groupProvider.editGroup(widget.groupIndex!, group);
      }

      // Save the updated group list to SharedPreferences
      GroupStorage().saveGroups(groupProvider.groups);
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group == null ? 'Yenı Hisse' : 'Hisse yı Derle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: const Color.fromARGB(255, 230, 230, 230),
              child: Container(
                padding: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(labelText: 'Hisse ismi'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen bir isim gırınız';
                    }
                    return null;
                  },
                ),
              ),
            ),
            ..._buildMemberFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int totalNumPart = 0;
                for (var part in _numPartControllers) {
                  totalNumPart += int.parse(part.text);
                }
                if (_nameControllers.length >= 7 || totalNumPart >= 7) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sınıra Ulaşıldı'),
                        content: const Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Tamam'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _addStandalonePersonField();
                }
              },
              child: const Text('Kişi Ekle'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Hisse yı Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMemberFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _nameControllers.length; i++) {
      fields.add(
        Card(
          // margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8), 
          color: const Color.fromARGB(255, 230, 230, 230),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameControllers[i],
                  decoration: const InputDecoration(labelText: 'Isim'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir isim girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _surnameControllers[i],
                  decoration: const InputDecoration(labelText: 'Soy isim'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir soy isim girin';
                    }
                    return null;
                  },
                ), 
                TextFormField(
                  controller: _numPartControllers[i],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hisse sayısı'),
                  onChanged: (n) {
                    if (n.isNotEmpty) {
                      int totalNumPart = 0;
                      for (var part in _numPartControllers) {
                        if (kDebugMode) {
                          print(part.text);
                        }
                        totalNumPart += int.parse(part.text);
                      }
                      if (totalNumPart > 7) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Sınıra Ulaşıldı'),
                                content: const Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz.'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              );
                            },
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen hisse sayısını girin';
                    }
                    int totalNumPart = 0;
                    for (var part in _numPartControllers) {
                      totalNumPart += int.parse(part.text);
                    }
                    if (totalNumPart > 7) {
                      return 'Hisse sayısı 7ı geçemez';
                    }
                    return null;
                  },
                ), 
                if (_attachedToIndexes[i] == null)
                  IntlPhoneField(
                    controller: _phoneControllers[i],
                    showCountryFlag: false,
                    initialCountryCode: 'BE',
                    decoration: const InputDecoration(
                      labelText: 'Telefon numarası',
                    ),
                    validator: (value) {
                      if (value == null || value.number.isEmpty) {
                        return 'Lütfen telefon numarasını girin';
                      } 
                      return null;
                    }
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_attachedToIndexes[i] != null)
                      const SizedBox(height: 40,),
                      if (_attachedToIndexes[i] == null)
                      ElevatedButton(
                        onPressed: () {
                          int totalNumPart = 0;
                          for (var part in _numPartControllers) {
                            totalNumPart += int.parse(part.text);
                          }
                          if (_nameControllers.length >= 7 || totalNumPart >= 7) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Sınıra Ulaşıldı'),
                                  content: const Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Tamam'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _addAttachedPersonField(i);
                          }
                        },
                        child: const Text('Yeni bağlı kişi ekle'),
                      ),
                      const SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: () {
                          if (_attachedToIndexes.contains(i)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Uyarı'),
                                  content: const Text('Bu üye birine bağlı, kaldırılamaz'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Tamam'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                    ),
                                    // TextButton(
                                    //   child: Text('Evet'),
                                    //   onPressed: () {
                                    //     Navigator.of(context).pop(); // Close the dialog
                                    //     _removeMember(i); // Perform the removal after confirmation
                                    //   },
                                    // ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _removeMember(i); // Directly remove the member if not in _attachedToIndexes
                          }
                        },
                        child: const Text('Kişi yi Sil'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return fields;
  }
}
