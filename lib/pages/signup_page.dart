import 'package:e_commerce_app/pages/login_page.dart';
import 'package:e_commerce_app/services/database.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/pages/bottomnav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_app/services/shared_pref.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    try {      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';
      final avatarUrl =
          "https://ui-avatars.com/api/?name=$firstLetter&background=0D8ABC&color=fff&size=128";

      sharedPreferencesHelper.saveUserId(uid);
      sharedPreferencesHelper.saveUserEmail(email);
      sharedPreferencesHelper.saveUserName(name);
      sharedPreferencesHelper.saveUserAvatar(avatarUrl);
      final userInfoMap = {
        "name": name,
        "email": email,
        "id": uid,
        "image": avatarUrl,
      };

      await DatabaseMethods().addUserDetails(userInfoMap, uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryBlue,
          content: const Text(
            'Registration successful!',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottomnav()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Registration failed: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(message, style: const TextStyle(fontSize: 20.0)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Registration error: $e',
              style: const TextStyle(fontSize: 20.0),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/login.png"),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Sign Up",
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Full Name", style: AppWidget.semiBoldTextFieldStyle()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                  decoration: InputDecoration(
                    hintText: "Enter your full name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Email", style: AppWidget.semiBoldTextFieldStyle()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Password", style: AppWidget.semiBoldTextFieldStyle()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
                  decoration: InputDecoration(
                    hintText: "Create a password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(22.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppWidget.lightTextFieldStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
