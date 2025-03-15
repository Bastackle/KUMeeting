import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/services/user_service.dart';
import 'package:project/widgets/alert.dart';
import 'package:project/widgets/confirm.dart';
import 'package:project/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic> userDetail = {};
  String? docId;
  final TextEditingController phoneController = TextEditingController();

  Future<void> _fetchdata() async {
    if(user==null) return;

    UserService().getUserData(user!.email!).listen((snapshot){
      if(snapshot != null) {
        setState(() {
          docId = snapshot.id;
          userDetail = snapshot.data() as Map<String, dynamic>;
          phoneController.text = userDetail['phoneNumber'] ?? '';

          String facultyId = userDetail['facultyId'] ?? '';
          if(facultyId.isNotEmpty){
            UserService().getFacultiesById(facultyId).then((facultySnapshot){
              if(facultySnapshot.exists){
                setState(() {
                  Map<String, dynamic> facultyData = facultySnapshot.data() as Map<String, dynamic>;
                  String facultyName = facultyData['facultyName'] ?? '';
                  userDetail['faculty'] = facultyName;
                  print(facultyName);
                  print(userDetail['faculty']);
                });
              } else {
                print('Faculty not found');
              }
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchdata();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async{
    if (user==null) return;

    final phone = phoneController.text.trim();
    if(phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)){
      AlertBox.showErrorDialog(context, 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง');
      return;
    }

    try{
      await UserService().updateUserPhone(docId!, phone);
      setState(() {
        userDetail['phoneNumber'] = phone;
      });
      AlertBox.showErrorDialog(context, 'บันทึกข้อมูลเรียบร้อย');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e');
      AlertBox.showErrorDialog(context, 'เกิดข้อผิดพลาดในการบันทึกข้อมูล');
    }
  }

  void _showConfirmPopup(BuildContext mainContext) {
    showDialog(
      context: mainContext,
      builder: (BuildContext dialogContext) {
        return ConfirmPopup(
          title: 'ต้องการออกจากระบบหรือไม่',
          onYes: () {
            print('ออกจากระบบ');
            Navigator.of(dialogContext).pop();
            Navigator.of(mainContext).pop();
            _authService.signOut();
          },
          onNo: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if(userDetail.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          title: Text(
            'Account Overviews',
            style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 25,
            ),
          ),

          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20,),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(userDetail['profileImage']),
                ),
                SizedBox(height: 30),
                _buildReadOnlyField('รหัสประจำตัว', userDetail['userId'] ?? '', FluentIcons.person_circle_28_regular),
                _buildReadOnlyField('ชื่อ - นามสกุล', userDetail['fullname'] ?? '', FluentIcons.person_24_filled),
                _buildReadOnlyField('สถานภาพ', userDetail['role'] ?? '', FluentIcons.status_24_filled),
                _buildReadOnlyField('คณะ', userDetail['faculty'] ?? '', FluentIcons.building_24_filled),
                _buildReadOnlyField('อีเมล', userDetail['email'] ?? '', FluentIcons.mail_24_filled),
                _buildEditableField('เบอร์โทรศัพท์', phoneController, Icons.phone),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'บันทึกการเปลี่ยนแปลง',
                    style: TextStyle(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmPopup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    print(value);
    TextEditingController controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontFamily: "Mitr",
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          fontSize: 20,
        ),
        readOnly: true,
        decoration: InputDecoration(
          fillColor: Colors.white.withOpacity(0.1),
          filled: true,
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "Mitr",
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          prefixIcon: Icon(icon,size: 25,color: Colors.grey.shade500,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "Mitr",
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            fontSize: 20,
          ),
          hintText: 'กรอก $label',
          hintStyle: TextStyle(
            fontFamily: "Mitr",
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          prefixIcon: Icon(icon, color: Colors.grey,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor),
          ),
        ),
        style: TextStyle(
          fontFamily: "Mitr",
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }
}
