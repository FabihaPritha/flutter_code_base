import 'package:flutter/material.dart';
import 'package:flutter_code_base/core/common/styles/global_text_style.dart';
import 'package:flutter_code_base/core/utils/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double? height;

  // Constructor to make the button reusable with optional parameters
  const CustomButton({
    super.key,
    this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.onPressed,
    this.borderRadius = 12.0, // Default border radius is 12
    this.height, // Optional height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 50.0, // Default height if not provided
        width: double.infinity, // Make the width infinity (full width)
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.defaultColor, // Default background color if none provided
          borderRadius: BorderRadius.circular(borderRadius), // Border radius set to 12
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.0) // Border color optional
              : null,
        ),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: getTextStyle(
                    color: textColor ?? Colors.white, // Default text color is white
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : Container(), // If no text is provided, show an empty container
        ),
      ),
    );
  }
}
