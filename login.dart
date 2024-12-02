import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foodfinderproject/reusable_widget/my_button.dart';
import 'package:foodfinderproject/reusable_widget/my_textfield.dart';
import 'package:foodfinderproject/reusable_widget/square_title.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onTap;

  const LoginPage({required this.onTap, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  // Sign user in with Email and Password
  void signUserIn() async {
    if (usernameController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      showErrorMessage('Please fill up the form');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context); // Close loading dialog if successful
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog

      // Handle different Firebase authentication error codes
      if (e.code == 'invalid-email') {
        showErrorMessage('The email address is not valid.');
      } else if (e.code == 'user-not-found') {
        showErrorMessage('No user found for that email. Please sign up first.');
      } else if (e.code == 'wrong-password') {
        showErrorMessage('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-credential') {
        showErrorMessage('This account is not registered yet or incorrect password');
      } else if (e.code == 'expired-action') {
        showErrorMessage('The authentication token has expired. Please try again.');
      } else if (e.code == 'too-many-requests') {
        showErrorMessage('Too many requests. Please try again later.');
      } else {
        // For any other error, show a generic message
        showErrorMessage(e.message ?? 'An error occurred during login.');
      }
    }
  }

  // Google Sign-In method
Future<void> signInWithGoogle() async {
  try {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Sign out to allow account re-selection
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Trigger Google Sign-In
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the sign-in process
      Navigator.pop(context);
      return;
    }

    // Obtain authentication details from Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Close loading dialog after successful login
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Close loading dialog
    showErrorMessage(e.message ?? 'An error occurred during Google Sign-In');
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    showErrorMessage("Something went wrong. Please try again.");
  }
}

  // Forgot password method
  void forgotPassword() async {
    String email = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Forgot Password"),
          content: TextField(
            onChanged: (value) => email = value.trim(),
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    showErrorMessage("A password reset link has been sent to $email.");
                  } on FirebaseAuthException catch (e) {
                    showErrorMessage(e.message ?? "An error occurred.");
                  }
                } else {
                  showErrorMessage("Please enter a valid email address.");
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // Show error messages in dialog
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image(
            image: const AssetImage('assets/bg5.gif'),
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
                     
                    // Email and password textfields
                    MyTextfield(
                      controller: usernameController,
                      hinText: 'Email',
                      obsecureText: false,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      controller: passwordController,
                      hinText: 'Password',
                      obsecureText: !isPasswordVisible,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Forgot password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: forgotPassword,
                            child:  const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 15, 186, 253),
                                fontWeight: FontWeight.bold
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sign in button
                    MyButton(onTap: signUserIn),
                    const SizedBox(height: 20),

                    // Or continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Google Sign-In
                    GestureDetector(
                      onTap: signInWithGoogle,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleTitle(imagePath: 'assets/google.png'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Sign-up prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Create An Account?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
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
