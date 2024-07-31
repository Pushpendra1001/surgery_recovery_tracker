// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:surgery_recovery_tracker/src/models/user.dart';
// import 'package:surgery_recovery_tracker/src/services/auth_service.dart';
// import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';


// class RegistrationScreen extends StatefulWidget {
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final AuthService _auth = AuthService();
//   final FirestoreService _db = FirestoreService();

//   final _formKey = GlobalKey<FormState>();
//   String email = '';
//   String password = '';
//   String role = 'patient'; // default role
//   String name = '';
//   String phone = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Email'),
//               onChanged: (val) {
//                 setState(() => email = val);
//               },
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//               onChanged: (val) {
//                 setState(() => password = val);
//               },
//             ),
//             DropdownButtonFormField(
//               value: role,
//               items: ['patient', 'doctor'].map((role) {
//                 return DropdownMenuItem(
//                   value: role,
//                   child: Text(role),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 setState(() => role = val as String);
//               },
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   User? user = await _auth.registerWithEmailAndPassword(email, password);
//                   if (user != null) {
//                     UserModel userModel = UserModel(uid: user.uid, email: email, role: role , name: name, phone: phone);
//                     await _db.setUserData(user.uid, userModel.toMap());
//                     // Navigate to another screen
//                   }
//                 }
//               },
//               child: Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
