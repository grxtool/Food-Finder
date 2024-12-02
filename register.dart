import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodfinderproject/reusable_widget/my_button.dart';
import 'package:foodfinderproject/reusable_widget/my_textfield.dart';

class Register extends StatefulWidget {
  final VoidCallback onTap;

  const Register({required this.onTap, super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool termsAccepted = false;
  bool isPasswordValid = false; // Track password validity

  // Sign user up method
  void signUserUp() async {
    // Check if any field is empty
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showErrorDialog("Please fill up the form.");
      return;
    }

    // Check if terms are accepted
    if (!termsAccepted) {
      showErrorDialog("Please accept the terms and conditions.");
      return;
    }

    // Check if password is valid
    if (!isPasswordValid) {
      showErrorDialog("Password must be at least 8 characters and contain numbers.");
      return;
    }

    // Show loading dialog while signing up
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check if the passwords match
      if (passwordController.text == confirmPasswordController.text) {
        // Check if email is already in use before creating a user
        List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailController.text);
        if (signInMethods.isNotEmpty) {
          Navigator.of(context).pop(); // Close loading dialog
          showErrorDialog("This email is already registered. Please log in instead.");
          return;
        }

        // Create the user with email and password
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Close loading dialog once sign-up is successful
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        showErrorDialog("Passwords do not match.");
        return;
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      showErrorDialog(e.message ?? "An error occurred.");
    }
  }

  // Show error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Check password validity
  void validatePassword(String password) {
    setState(() {
      // Password must be at least 8 characters and contain at least one number
      isPasswordValid = password.length >= 8 && RegExp(r'[0-9]').hasMatch(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:
            Container(
              child: Stack(
                children: [
                  Image(
                    image:const AssetImage('assets/bg5.gif'),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    
                    ),
      
      
                               SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.only(top: 100),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        // Logo and FOODFINDER text in a Stack
        Stack(
          clipBehavior: Clip.none, // Ensures children outside bounds are not clipped
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/reicons.png',
                height: 190,
                width: 190,
                fit: BoxFit.cover,
              ),
            ),
            const Positioned(
              bottom: -10, // Adjusted for closer placement without clipping
              child: Text(
                'FOODFINDER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0), // Shadow position
                      blurRadius: 3.0,          // Shadow blur
                      color: Colors.black38,    // Shadow color
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30), 

              // Email textfield with icon
              MyTextfield(
                controller: emailController,
                hinText: 'Email',
                obsecureText: false,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 10),

              // Password textfield with visibility toggle
              MyTextfield(
                controller: passwordController,
                hinText: 'Password',
                obsecureText: !isPasswordVisible,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                // Correctly use onChanged for password validation
                onChanged: (value) {
                  validatePassword(value); // Pass the typed value to validatePassword
                },
              ),

              const SizedBox(height: 5),
              // Password validation message only when the password is invalid
              if (!isPasswordValid)
                const Text(
                  'Use 8 or more characters with a mix of letters & numbers.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              const SizedBox(height: 10),

              // Confirm password textfield with visibility toggle
              MyTextfield(
                controller: confirmPasswordController,
                hinText: 'Confirm Password',
                obsecureText: !isConfirmPasswordVisible,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Terms and conditions checkbox
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10)),
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value!;
                      });
                    },
                  ),
                  const Text('I accept the terms and conditions', 
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, 
                  ),
                  ),
                ],
              ),

              // Sign up button
              MyButton(onTap: signUserUp),
              const SizedBox(height: 50),

              // Login prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login Now',
                      style: TextStyle(
                        color: Colors.blue,
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
                ]
              ),
    ),
    );
  }
}  

