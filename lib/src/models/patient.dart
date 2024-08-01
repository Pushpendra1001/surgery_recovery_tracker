class PatientModel {
  final String uid;
  final String name;
  final String email;
  final String disease;
  final int recoveryTimeInDays;
  final String recoveryChecklist;
  final String exerciseType;
  final String password;
  final String hospital;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> dailyTasks;

  PatientModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.disease,
    required this.recoveryTimeInDays,
    required this.recoveryChecklist,
    required this.exerciseType,
    required this.password,
    required this.hospital,
    required this.startDate,
    required this.endDate,
    required this.dailyTasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'disease': disease,
      'recoveryTimeInDays': recoveryTimeInDays,
      'recoveryChecklist': recoveryChecklist,
      'exerciseType': exerciseType,
      'password': password,
      'hospital': hospital,
      'startDate': startDate,
      'endDate': endDate,
      'dailyTasks': dailyTasks,
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
      hospital: map['hospital'],
      startDate: map['startDate'].toDate(),
      endDate: map['endDate'].toDate(),
      dailyTasks: List<String>.from(map['dailyTasks']),
      
      
    );
  }
}
