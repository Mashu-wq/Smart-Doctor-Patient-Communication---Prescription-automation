import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/splash/presentation/splash_provider.dart';
import 'package:medisafe/features/role_selection/presentation/role_selection_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashState.when(
        data: (value) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen()),
            );
          });
        },
        loading: () {},
        error: (error, stack) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen()),
            );
          });
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.appColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/splash.png", width: 250, height: 250),
            const SizedBox(height: 10),
            Pacifico(
                text: "Medisafe", size: 35.0, color: AppColors.buttonColor),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
