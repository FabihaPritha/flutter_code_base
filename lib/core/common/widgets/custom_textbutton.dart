import 'package:flutter/material.dart';
import 'package:flutter_code_base/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.buttonText,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required  this.buttonAction,
  });

  final String buttonText;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback buttonAction;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        backgroundColor: backgroundColor, // Colors.white
        foregroundColor: foregroundColor, // Colors.green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(width: 1, color: borderColor),
        ),
      ),
      onPressed: buttonAction,
      child: Text(
        buttonText,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: foregroundColor,
          lineHeight: 11,
        ),
      ),
    );
  }
}

// Usage of the CustomTextButton with navigation action
