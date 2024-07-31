class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin', 'doctor', 'patient'
  final String name;
  final String? disease;
  final int? recoveryTimeInDays;
  final String? recoveryChecklist;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.disease,
    this.recoveryTimeInDays,
    this.recoveryChecklist,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'disease': disease,
      'recoveryTimeInDays': recoveryTimeInDays,
      'recoveryChecklist': recoveryChecklist,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      role: map['role'],
      name: map['name'],
      disease: map['disease'],
      recoveryTimeInDays: map['recoveryTimeInDays'],
      recoveryChecklist: map['recoveryChecklist'],
    );
  }
}
