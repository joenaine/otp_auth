import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:otp_auth/application/auth/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:otp_auth/presentation/core/app_colors.dart';
import 'package:otp_auth/presentation/core/app_regex_const.dart';

class InputNumberSignInTextField extends StatefulWidget {
  const InputNumberSignInTextField({super.key});

  @override
  State<InputNumberSignInTextField> createState() =>
      _InputNumberSignInTextFieldState();
}

class _InputNumberSignInTextFieldState
    extends State<InputNumberSignInTextField> {
  late MaskTextInputFormatter _phoneMaskController;
  final PhoneNumber initialPhone = PhoneNumber(isoCode: "TR");

  @override
  void didChangeDependencies() {
    context
        .read<PhoneNumberSignInCubit>()
        .phoneNumberChanged(phoneNumber: initialPhone.phoneNumber ?? "");
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _phoneMaskController = MaskTextInputFormatter(
        mask: AppRegexPattern.phoneKZ,
        filter: {"#": AppRegexPattern.digitRegex});
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final phoneSignInCubit = context.read<PhoneNumberSignInCubit>();
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: CupertinoTextFormFieldRow(
            initialValue: '+7',
            padding: const EdgeInsets.all(16),
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskController],
            cursorColor: AppColors.darkGrey,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(8)),
            onChanged: (value) {
              phoneSignInCubit.phoneNumberChanged(
                phoneNumber: '+7${_phoneMaskController.getUnmaskedText()}',
              );
            },
            validator: (value) => value!.isEmpty ? 'Пусто' : null,
            onFieldSubmitted: (value) {
              if (_formKey.currentState!.validate()) {
                phoneSignInCubit.updateNextButtonStatus(
                    isPhoneNumberInputValidated: true);
              }
            },
          ),
        );
      },
    );
  }
}
