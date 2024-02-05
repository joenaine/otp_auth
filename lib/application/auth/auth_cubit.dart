import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_auth/domain/auth/auth_user_model.dart';
import 'package:otp_auth/domain/auth/i_auth_service.dart';
import 'package:otp_auth/injection.dart';
part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

@LazySingleton()
class AuthCubit extends Cubit<AuthState> {
  late final IAuthService _authService;
  late StreamSubscription<AuthUserModel>? _authUserSubscription;

  AuthCubit() : super(AuthState.empty()) {
    _authService = getIt<IAuthService>();
    _authUserSubscription =
        _authService.authStateChanges.listen(_listenAuthStateChangesStream);
  }

  @override
  Future<void> close() async {
    await _authUserSubscription?.cancel();
    return super.close();
  }

  Future<void> _listenAuthStateChangesStream(AuthUserModel authUser) async {
    if (authUser == AuthUserModel.empty()) {
      emit(state.copyWith(userModel: authUser, isUserLoggedIn: false));
    } else {
      emit(state.copyWith(userModel: authUser, isUserLoggedIn: true));
    }
  }

  Future<void> signOut() async {
    _authService.signOut();
  }
}
