import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kurban_app/GroupProvider.dart';
import 'package:kurban_app/GroupStorage.dart';
import 'package:provider/provider.dart';
import 'models.dart';

class GroupFormScreen extends StatefulWidget {
  final Group? group;
  final int? groupIndex;

  GroupFormScreen({this.group, this.groupIndex});

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
    });
  }

  void _removeMemberField(int index) {
    setState(() {
      _nameControllers.removeAt(index);
      _surnameControllers.removeAt(index);
      _numPartControllers.removeAt(index);
      _phoneControllers.removeAt(index);
      _attachedToIndexes.removeAt(index);
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

        if (attachedToIndex == null) {
          if(phoneNumber == ''){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lütfen bir telefon numarası girin')),
            );
          return; 
          }
          members.add(StandalonePerson(name: name, surname: surname, phoneNumber: phoneNumber, numPart: numPart));
        } else {
          final attachedToIndex = _attachedToIndexes[i];
          final attachedTo = attachedToIndex! >= 0 ? members[attachedToIndex] : null;
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
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Hisse ismi'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lutfen bir isim gırınız';
                }
                return null;
              },
            ),
            ..._buildMemberFields(),
            SizedBox(height: 20),
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
                        title: Text('Sınıra Ulaşıldı'),
                        content: Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Tamam'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _addStandalonePersonField();
                }
              },
              child: Text('Kişi Ekle'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Hisse yı Kaydet'),
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
          color: Color.fromARGB(255, 230, 230, 230),
          child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameControllers[i],
                  decoration: InputDecoration(labelText: 'Isim'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir isim girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _surnameControllers[i],
                  decoration: InputDecoration(labelText: 'Soy isim'),
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
                  decoration: InputDecoration(labelText: 'Hisse sayısı'),
                  onChanged: (n) {
                    if (n.isNotEmpty) {
                      int totalNumPart = 0;
                      for (var part in _numPartControllers) {
                        print(part.text);
                        totalNumPart += int.parse(part.text);
                      }
                      if (totalNumPart > 7) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Sınıra Ulaşıldı'),
                                content: Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz.'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Tamam'),
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
                    decoration: InputDecoration(
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
                      SizedBox(height: 40,),
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
                                  title: Text('Sınıra Ulaşıldı'),
                                  content: Text('Bir hisse ye 7den fazla kişi veya parça ekleyemezsiniz'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Tamam'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _addAttachedPersonField(i);
                          }
                        },
                        child: Text('Yeni bağlı kişi ekle'),
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: () => _removeMemberField(i),
                        child: Text('Kişi yi Sil'),
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
