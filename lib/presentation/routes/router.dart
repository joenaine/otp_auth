// ignore: depend_on_referenced_packages
import 'package:auto_route/auto_route.dart';
import 'package:otp_auth/presentation/pages/home/home_page.dart';
import 'package:otp_auth/presentation/pages/landing/landing_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    // AutoRoute(page: SignInPage),
    // AutoRoute(page: SignInVerificationPage),
    AutoRoute(page: HomePage),
    AutoRoute(page: LandingPage, initial: true),
  ],
)
class $AppRouter {}
