import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/patient/presentation/controllers/patient_login_controller.dart';
import 'package:medisafe/features/authentication/patient/presentation/screens/patient_registration_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/patient_home_screen.dart';

class PatientLoginScreen extends ConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  PatientLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(patientLoginControllerProvider);

    ref.listen<AsyncValue<void>>(patientLoginControllerProvider,
        (previous, next) {
      if (next is AsyncData && next.value == null) {
        // Navigate to PatientHomeScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
        );
      } else if (next is AsyncError) {
        // Show error if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${next.error}')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detects web layout

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isWeb ? 450 : double.infinity, // Restrict width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/1.png", // Replace with patient image asset
                        height: isWeb
                            ? 220
                            : 180, // Adjust image size for web & mobile
                      ),
                      const SizedBox(height: 20),
                      Pacifico(text: "Patient Login", size: 30.0),
                      const SizedBox(height: 20),
                      _buildTextField(_emailController, 'Your Email',
                          Icons.email, TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      loginState.maybeWhen(
                        loading: () => const CircularProgressIndicator(),
                        orElse: () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ref
                                      .read(patientLoginControllerProvider
                                          .notifier)
                                      .signIn(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const StadiumBorder(),
                                backgroundColor: AppColors.buttonColor,
                              ),
                              child: Pacifico(
                                text: "Login",
                                size: 20.0,
                                color: AppColors.buttonTextColor,
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      loginState.maybeWhen(
                        error: (e, stack) => Text(
                          'Error: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password screen
                        },
                        child: Pacifico(
                          text: "Forgot Password?",
                          size: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Pacifico(text: "Don't have an account?", size: 14.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PatientRegistrationScreen()));
                            },
                            child: OpenSans(
                              text: "Create New Account",
                              size: 16.0,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.buttonColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        hintText: 'Enter your $label',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (keyboardType == TextInputType.emailAddress &&
            !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, obscure, child) {
        return TextFormField(
          controller: _passwordController,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                _obscurePassword.value = !_obscurePassword.value;
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.buttonColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        );
      },
    );
  }
}
