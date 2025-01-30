import 'package:get/get.dart';
import 'package:todo_app/presentation/onboarding/onboarding_screen.dart';
import 'package:todo_app/presentation/auth/signup_screen.dart';
import 'package:todo_app/presentation/auth/signin_screen.dart';
import 'package:todo_app/presentation/home/home_screen.dart';
import 'package:todo_app/presentation/auth/verify_email_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignUpScreen(),
    ),
    GetPage(
      name: Routes.SIGNIN,
      page: () => SignInScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.VERIFY_EMAIL,
      page: () => VerifyEmailScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
} 