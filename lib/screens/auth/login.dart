import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/widgets/bottomBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ku.png', width: 175,),
                  SizedBox(height: 20),
                  Text(
                    'KUMeeting',
                    style: TextStyle(
                      fontFamily: 'Mitr',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'สะดวก อัตโนมัติ มีประสิทธิภาพ ทุกอุปกรณ์',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      fontFamily: "Mitr",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "เข้าสู่ระบบด้วย Google KU",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Mitr",
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: 275,
                          height: 75,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    User? user = await _authService
                                        .signInWithGoogle(context);
                                    setState(() => _isLoading = false);

                                    if (user != null) {
                                      await Future.delayed(Duration(seconds: 3));
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => BottomBar()),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: Colors.black87,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black26,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.black)
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/images/googleIcon.png', height: 30,),
                                      SizedBox(width: 5),
                                      SizedBox(width: 10),
                                      Text(
                                        "Sign in with Google",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Mitr",
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
