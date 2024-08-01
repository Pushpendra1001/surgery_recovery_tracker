// models/doctor.dart

class Doctor {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String hospital;

  Doctor({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.hospital,
  });

  // Factory method to create a Doctor instance from a Firestore document
  factory Doctor.fromFirestore(Map<String, dynamic> data, String uid) {
    return Doctor(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      specialization: data['specialization'] ?? '',
      hospital: data['hospital'] ?? '',
    );
  }

  // Method to convert Doctor instance to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'hospital': hospital,
    };
  }
}
