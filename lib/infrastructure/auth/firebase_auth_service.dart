import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_auth/domain/auth/auth_user_model.dart';
import 'package:otp_auth/domain/auth/auth_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:otp_auth/domain/auth/i_auth_service.dart';

@LazySingleton(as: IAuthService)
class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth;
  FirebaseAuthService(this._firebaseAuth);

  @override
  Stream<AuthUserModel> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) {
        return AuthUserModel.empty();
      } else {
        return AuthUserModel(
            id: user.uid,
            phoneNumber: user.phoneNumber!,
            email: user.email ?? '',
            photo: user.photoURL ?? '');
      }
    });
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<Either<AuthFailure, Tuple2<String, int?>>> signInWithPhoneNumber(
      {required String phoneNumber,
      required Duration timeout,
      required int? resendToken}) async* {
    final StreamController<Either<AuthFailure, Tuple2<String, int?>>>
        streamController =
        StreamController<Either<AuthFailure, Tuple2<String, int?>>>();

    await _firebaseAuth.verifyPhoneNumber(
        forceResendingToken: resendToken,
        timeout: timeout,
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          //Android only
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        codeSent: (verificationId, forceResendingToken) {
          streamController
              .add(right(tuple2(verificationId, forceResendingToken)));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        verificationFailed: (error) {
          late final Either<AuthFailure, Tuple2<String, int?>> result;
          if (error.code == 'too-many-requests') {
            result = left(const AuthFailure.tooManyRequests());
          } else if (error.code == 'app-not-authorized') {
            result = left(const AuthFailure.deviceNotSupported());
          } else {
            result = left(const AuthFailure.serverError());
          }
          streamController.add(result);
        });
    yield* streamController.stream;
  }

  @override
  Future<Either<AuthFailure, Unit>> verifySmsCode(
      {required String smsCode, required String verificationId}) async {
    try {
      final PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

      await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      return right(unit);
    } on FirebaseAuthException catch (error) {
      if (error.code == "session_expired") {
        return left(const AuthFailure.sessionExpired());
      } else if (error.code == "ınvalıd-verıfıcatıon-code" ||
          error.code == "invalid-verification-code") {
        return left(const AuthFailure.invalidVerificationCode());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }
}
