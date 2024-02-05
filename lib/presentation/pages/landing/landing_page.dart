import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_auth/application/auth/auth_cubit.dart';
import 'package:otp_auth/presentation/pages/home/home_page.dart';
import 'package:otp_auth/presentation/pages/sign_in/sign_in_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isUserLoggedIn) {
          return const HomePage();
        } else {
          return const SignInPage();
        }
      },
    );
  }
}
