import 'package:flutter/material.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:kurban_app/src/models/group.dart';
import 'package:kurban_app/src/models/person.dart';
import 'package:kurban_app/src/providers/group_provider.dart';
import 'package:kurban_app/src/services/group_storage.dart';
import 'package:provider/provider.dart';

class PersonFormScreen extends StatefulWidget {
  final Group group;
  final int personIndex;
  final int groupIndex;
  dynamic person;


  PersonFormScreen({super.key, required this.group, required this.personIndex, required this.groupIndex}){
    person = group.members[personIndex];
  }

  @override
  _PersonFormScreenState createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _numPartController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.person.name;
    _surnameController.text = widget.person.surname;
    _numPartController.text = widget.person.numPart;
    if (widget.person is StandalonePerson) {
      _phoneController.text = (widget.person as StandalonePerson).phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _numPartController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final surname = _surnameController.text;
      final numPart = _numPartController.text;
      if (widget.person is StandalonePerson) {
        final phoneNumber = _phoneController.text;
        widget.group.members.replaceRange(widget.personIndex, widget.personIndex+1, [StandalonePerson(
          name: name, 
          surname: surname, 
          phoneNumber: phoneNumber, 
          numPart: numPart)] );
      } else if (widget.person is AttachedPerson) {
        widget.group.members.replaceRange(widget.personIndex, widget.personIndex+1, [AttachedPerson(
          name: name,
          surname: surname,
          attachedTo: (widget.person as AttachedPerson).attachedTo,
          numPart: numPart,
        )]);
      }
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      groupProvider.editGroup(widget.groupIndex, widget.group);
    
      // Save the updated group list to SharedPreferences
      GroupStorage().saveGroups(groupProvider.groups);
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kişiyi Düzenle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Isim'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir isim girin';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Soy isim'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir soy isim girin';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _numPartController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hisse sayısı'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen hisse sayısını girin';
                }
                int numPart = int.parse(value);
                if (numPart > 7) {
                  return 'Hisse sayısı 7ı geçemez';
                }
                return null;
              },
            ),
            if (widget.person is StandalonePerson)
              IntlPhoneField(
                controller: _phoneController,
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
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
