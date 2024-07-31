class PatientModel {
  final String uid;
  final String name;
  final String disease;
  final int recoveryTimeInDays;
  final String recoveryChecklist;
  final String email;
  final String exerciseType;
  final String password;

  PatientModel({
    required this.uid,
    required this.name,
    required this.disease,
    required this.recoveryTimeInDays,
    required this.recoveryChecklist,
    required this.email,
    required this.exerciseType,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'disease': disease,
      'email' : email,
      'exerciseType' : exerciseType,
      'password' : password,
      'recoveryTimeInDays': recoveryTimeInDays,
      'recoveryChecklist': recoveryChecklist,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'],
      name: map['name'],
      disease: map['disease'],
      email: map['email'],
      exerciseType: map['exerciseType'],
      password: map['password'],
      recoveryTimeInDays: map['recoveryTimeInDays'],
      recoveryChecklist: map['recoveryChecklist'],
      
    );
  }
}
