class Person {
  String name;
  String surname;
  String numPart;

  Person({required this.name, required this.surname, required this.numPart});
}

class StandalonePerson extends Person {
  String phoneNumber;
  

  StandalonePerson({required super.name, required super.surname, required this.phoneNumber, required super.numPart});

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is StandalonePerson &&
        other.name == name &&
        other.surname == surname &&
        other.phoneNumber == phoneNumber;
  }
}

class AttachedPerson extends Person {
  StandalonePerson attachedTo;

  AttachedPerson({required super.name, required super.surname, required this.attachedTo, required super.numPart});

}