// ignore_for_file: use_build_context_synchronously

import 'package:app/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:app/api/signup.dart';
import 'package:app/utils/snackbar.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final TextEditingController usrnameController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Title
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Create an account to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // Name Input Field
              TextField(
                controller: usrnameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: fnameController,
                decoration: InputDecoration(
                  labelText: 'First name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: lnameController,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email Input Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Phone Number Input Field
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Password Input Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final username = usrnameController.text;
                    final firstName = fnameController.text;
                    final lastName = lnameController.text;
                    final email = emailController.text;
                    final phoneNumber = phoneController.text;
                    final password = passwordController.text;

                    // Await the result of the registration API call
                    final bool result = await registerUser(username, firstName,
                        lastName, email, phoneNumber, password);

                    // If the registration is successful, navigate to login
                    if (result) {
                      showCustomSnackbar(
                          context, "Sign Up Successful", Colors.blue,
                          seconds: 1);
                      Navigator.pushNamed(context, MyRoutes.loginRoute);
                    } else {
                      // Handle failure (e.g., show a Snackbar or dialog)
                      showCustomSnackbar(
                          context, "An error occured!", Colors.red);
                    }
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Spacer(),

              // Login Option
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.loginRoute);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
