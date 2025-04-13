import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/authentication/doctor/presentation/controllers/doctor_login_controller.dart';
import 'package:medisafe/features/authentication/doctor/presentation/screens/doctor_registration_screen.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctors_main_screen.dart';

class DoctorLoginScreen extends ConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DoctorLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(doctorLoginController);

    ref.listen<AsyncValue<void>>(doctorLoginController, (previous, next) {
      if (next is AsyncData<void>) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorMainScreen()),
        );
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}")),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isWeb ? 450 : double.infinity, // Limits width on web
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/2.png",
                        height: isWeb ? 200 : 180, // Adjusts image size for web
                      ),
                      const SizedBox(height: 20),
                      Pacifico(text: "Doctor Login", size: 30.0),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _emailController, 'Your Email', Icons.email, false),
                      const SizedBox(height: 10),
                      _buildTextField(
                          _passwordController, 'Password', Icons.lock, true),
                      const SizedBox(height: 20),
                      loginState.maybeWhen(
                        loading: () => const CircularProgressIndicator(),
                        orElse: () => SizedBox(
                          width: double.infinity, // Full width button
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await ref
                                    .read(doctorLoginController.notifier)
                                    .signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            child: Pacifico(
                              text: "Login",
                              size: 20.0,
                              color: AppColors.buttonTextColor,
                            ),
                          ),
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
                        onPressed: () {},
                        child: Pacifico(text: "Forget Password?", size: 16.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Pacifico(
                              text: "Don't have an account?", size: 14.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DoctorRegistrationScreen()));
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
      IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isPassword ? TextInputType.text : TextInputType.emailAddress,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: const Icon(Icons.visibility_off),
                onPressed: () {},
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isPassword
              ? 'Please enter your password'
              : 'Please enter a valid email';
        }
        if (!isPassword && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
