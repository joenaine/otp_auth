import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_auth/application/auth/auth_cubit.dart';
import 'package:otp_auth/application/auth/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:otp_auth/injection.dart';
import 'package:otp_auth/presentation/core/app_colors.dart';
import 'package:otp_auth/presentation/routes/router.gr.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = getIt<AppRouter>();

    final botToastBuilder = BotToastInit();
    final BotToastNavigatorObserver botToastNavigatorObserver =
        BotToastNavigatorObserver();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthCubit>(), lazy: false),
        BlocProvider(
            create: (context) => getIt<PhoneNumberSignInCubit>(), lazy: false),
      ],
      child: Listener(
        onPointerUp: (_) {
          if (Platform.isIOS) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          }
        },
        child: CupertinoApp.router(
          theme: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                  primaryColor: AppColors.dark,
                  textStyle:
                      TextStyle(fontFamily: 'SF', color: AppColors.dark))),
          title: 'Phone Number Sign-In',
          debugShowCheckedModeBanner: false,
          routeInformationParser: appRouter.defaultRouteParser(),
          routerDelegate: appRouter.delegate(
            navigatorObservers: () => [
              botToastNavigatorObserver,
            ],
          ),
          builder: (context, child) {
            return botToastBuilder(context, child);
          },
        ),
      ),
    );
  }
}
