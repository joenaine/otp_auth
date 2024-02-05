import 'package:flutter/material.dart';
import 'package:otp_auth/presentation/core/app_colors.dart';

class RegisterStepIndicatorWidget extends StatelessWidget {
  const RegisterStepIndicatorWidget({
    Key? key,
    this.activeIndex = 1,
  }) : super(key: key);
  final int? activeIndex;

  @override
  Widget build(BuildContext context) {
    List<int> steps = [1, 2, 3];
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps
            .asMap()
            .map((i, value) => MapEntry(
                i,
                Row(
                  children: [
                    CircleIndicatorWidget(
                      text: value,
                      bgColor: value == activeIndex
                          ? AppColors.yellow
                          : AppColors.lightGrey,
                    ),
                    if (i != 2)
                      Container(
                        width: 44,
                        height: 2,
                        color: AppColors.lightGrey,
                      )
                  ],
                )))
            .values
            .toList());
  }
}

class CircleIndicatorWidget extends StatelessWidget {
  const CircleIndicatorWidget(
      {Key? key, required this.text, this.bgColor = AppColors.lightGrey})
      : super(key: key);
  final int text;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Text(text.toString()),
    );
  }
}
