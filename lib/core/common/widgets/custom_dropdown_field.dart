// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_code_base/core/common/styles/global_text_style.dart';
import 'package:flutter_code_base/core/utils/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isEnabled;
  final Color borderColor;
  final Color? dropdownColor;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.isEnabled = true,
    this.borderColor = AppColors.defaultBorderColor, // default light grey
    this.dropdownColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: DropdownButtonFormField<T>(
        
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  style: getTextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        dropdownColor: dropdownColor,
        icon: const Icon(
          Icons.keyboard_arrow_down, // 👈 custom down arrow
          color: Colors.black54,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ), // 👈 border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ), // 👈 same color on focus
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
