import 'package:flutter/material.dart';
import 'package:surgery_recovery_tracker/src/models/patient.dart';
import 'package:surgery_recovery_tracker/src/screens/auth/loginPage.dart';
import 'package:surgery_recovery_tracker/src/screens/doctor/patient_list_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/create_doctor_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/create_patients_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/view_doctor_screen.dart';
import 'package:surgery_recovery_tracker/src/screens/hospital/view_patients_screen.dart';
import 'package:surgery_recovery_tracker/src/services/auth_service.dart';

import 'package:surgery_recovery_tracker/src/services/firestore_service.dart';
import 'package:surgery_recovery_tracker/src/utils/elevated_btn.dart';

class AdminDashboard extends StatelessWidget {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CustomElevatedButton(buttonText: "View Doctors", onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDoctorsScreen()));
          }, height: 50, width: MediaQuery.of(context).size.width - 20),
          CustomElevatedButton(buttonText: "View Patients", onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPatientsScreen()));
          }, height: 50, width: MediaQuery.of(context).size.width - 20),
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomElevatedButton(buttonText: "Add Doctor", onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDoctorScreen()));
          }, height: 50, width: (MediaQuery.of(context).size.width - 50) / 2),
          CustomElevatedButton(buttonText: "Add Patient", onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePatientScreen()));
          }, height: 50, width: (MediaQuery.of(context).size.width - 50) / 2),
        ],
       ),
          Expanded(
            child: StreamBuilder<List<PatientModel>>(
              stream: _db.getPatients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                List<PatientModel> patients = snapshot.data!;
                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    PatientModel patient = patients[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailScreen( patientId: patient.uid))),
                        child: ListTile(
                          title: Text(patient.name),
                          subtitle: Text(patient.disease),
                          trailing: Icon(Icons.arrow_forward),       
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
