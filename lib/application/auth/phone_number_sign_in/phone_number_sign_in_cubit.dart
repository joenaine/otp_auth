import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_auth/domain/auth/auth_failure.dart';
import 'package:otp_auth/domain/auth/i_auth_service.dart';
import 'package:otp_auth/injection.dart';

part 'phone_number_sign_in_state.dart';
part 'phone_number_sign_in_cubit.freezed.dart';

@Injectable()
class PhoneNumberSignInCubit extends Cubit<PhoneNumberSignInState> {
  StreamSubscription<Either<AuthFailure, Tuple2<String, int?>>>?
      _phoneNumberSignInSubscription;
  late final IAuthService _authService;
  final Duration verificationCodeTimeout = const Duration(seconds: 60);

  PhoneNumberSignInCubit() : super(PhoneNumberSignInState.empty()) {
    _authService = getIt<IAuthService>();
  }

  void phoneNumberChanged({required String phoneNumber}) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void updateNextButtonStatus({required bool isPhoneNumberInputValidated}) {
    emit(state.copyWith(
        isPhoneNumberInputValidated: isPhoneNumberInputValidated));
  }

  void smsCodeChanged({required String smsCode}) {
    emit(state.copyWith(smsCode: smsCode));
  }

  void reset() {
    emit(state.copyWith(
      failureMessageOption: none(),
      verificationIdOption: none(),
      phoneNumber: "",
      smsCode: "",
      isInProgress: false,
      isPhoneNumberInputValidated: false,
    ));
  }

  void verifySmsCode() {
    if (state.isInProgress) {
      return;
    }
    state.verificationIdOption.fold(
      () {},
      (String verificationId) async {
        emit(state.copyWith(
          isInProgress: true,
          failureMessageOption: none(),
        ));

        final Either<AuthFailure, Unit> failureOrSuccess =
            await _authService.verifySmsCode(
                smsCode: state.smsCode, verificationId: verificationId);

        failureOrSuccess.fold(
          (AuthFailure failure) {
            emit(state.copyWith(
              failureMessageOption: some(failure),
              isInProgress: false,
            ));
          },
          (Unit _) {
            emit(state.copyWith(isInProgress: false));
          },
        );
      },
    );
  }

  void signInWithPhoneNumber() {
    if (state.isInProgress) {
      return;
    }
    emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

    _phoneNumberSignInSubscription?.cancel();

    _phoneNumberSignInSubscription = _authService
        .signInWithPhoneNumber(
          phoneNumber: state.phoneNumber,
          timeout: verificationCodeTimeout,
          resendToken:
              state.phoneNumber != state.phoneNumberAndResendTokenPair.value1
                  ? null
                  : state.phoneNumberAndResendTokenPair.value2,
        )
        .listen(
          (Either<AuthFailure, Tuple2<String, int?>> failureOrVerificationId) =>
              failureOrVerificationId.fold(
            (AuthFailure authFailure) {
              emit(state.copyWith(
                  failureMessageOption: some(authFailure),
                  isInProgress: false));
            },
            (Tuple2<String, int?> verificationIdResendTokenPair) {
              emit(state.copyWith(
                  verificationIdOption:
                      some(verificationIdResendTokenPair.value1),
                  isInProgress: false,
                  phoneNumberAndResendTokenPair: tuple2(state.phoneNumber,
                      verificationIdResendTokenPair.value2)));
            },
          ),
        );
  }

  @override
  Future<void> close() {
    _phoneNumberSignInSubscription?.cancel();
    return super.close();
  }
}
