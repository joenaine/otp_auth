import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_auth/application/auth/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:otp_auth/presentation/core/app_colors.dart';
import 'package:otp_auth/presentation/pages/common_widgets/app_hide_keyboard_widget.dart';
import 'package:otp_auth/presentation/pages/sign_in/widgets/input_number_sign_in_textfield.dart';
import 'package:otp_auth/presentation/pages/sign_in/widgets/register_step_indicator_widget.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      builder: (context, state) {
        return state.isInProgress
            ? BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
                listenWhen: (p, c) =>
                    p.failureMessageOption != c.failureMessageOption,
                listener: (context, state) {
                  state.failureMessageOption.fold(
                    () {},
                    (authFailure) {
                      BotToast.showText(
                        text: authFailure.when(
                          serverError: () => "Server Error",
                          tooManyRequests: () => "Too Many Requests",
                          deviceNotSupported: () => "Device Not Supported",
                          smsTimeOut: () => "Sms Timeout",
                          sessionExpired: () => "Session Expired",
                          invalidVerificationCode: () =>
                              "Invalid Verification Code",
                        ),
                      );
                      context.read<PhoneNumberSignInCubit>().reset();
                      AutoRouter.of(context).popUntilRoot();
                    },
                  );
                },
                child: const Scaffold(
                  body: CircularProgressIndicator(),
                ),
              )
            : AppHideKeyBoardWidget(
                child: CupertinoPageScaffold(
                  resizeToAvoidBottomInset: false,
                  navigationBar: const CupertinoNavigationBar(
                    backgroundColor: Colors.white,
                    border: Border(bottom: BorderSide.none),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const RegisterStepIndicatorWidget(
                          activeIndex: 1,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Регистрация',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 34),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Введите номер телефона\nдля регистрации',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                        const InputNumberSignInTextField(),
                        MaterialButton(
                          color: AppColors.darkGrey,
                          onPressed: () {
                            context
                                .read<PhoneNumberSignInCubit>()
                                .signInWithPhoneNumber();
                          },
                          child: const Text('Отправить смс-код'),
                        )
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}

class CustomAppBarWidget extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const CustomAppBarWidget({super.key, this.isLeading = true});
  final bool? isLeading;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
