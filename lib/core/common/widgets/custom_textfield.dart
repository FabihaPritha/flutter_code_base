import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_base/core/common/styles/global_text_style.dart';
import 'package:flutter_code_base/core/utils/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A robust, reusable custom text field.
///
/// Key improvements over the original version:
/// - Stateful to avoid recreating the TextEditingController on rebuilds (this fixes
///   the "backspace deletes 1 char only / weird deletion behavior" problem when
///   parent widgets rebuild).
/// - Supports both controlled and uncontrolled password visibility (if
///   [isPasswordVisible] is provided, the parent controls visibility; if null,
///   the widget manages it internally).
/// - Preserves/disposes an internally created controller correctly.
/// - Adds common useful properties: inputFormatters, maxLines, minLines, maxLength,
///   readOnly, autofocus, textAlign and padding.
class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool isPasswordField;
  final bool? isPasswordVisible;
  final VoidCallback? onIconPressed;
  final IconData? icon;
  final Color? suffixIconColor;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool readOnly;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.isPasswordField = false,
    this.isPasswordVisible,
    this.onIconPressed,
    this.icon,
    this.suffixIconColor,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _effectiveController;
  late bool _ownsController;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _effectiveController = widget.controller ?? TextEditingController();
    _obscureText = widget.isPasswordField
        ? !(widget.isPasswordVisible ?? false)
        : false;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _effectiveController.dispose();
      _ownsController = widget.controller == null;
      _effectiveController = widget.controller ?? TextEditingController();
    }

    if (widget.isPasswordField && widget.isPasswordVisible != null) {
      _obscureText = !widget.isPasswordVisible!;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentPad =
        widget.contentPadding ??
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h);

    return TextField(
      controller: _effectiveController,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPasswordField ? _obscureText : false,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      textAlign: widget.textAlign,
      style:
          widget.textStyle ??
          getTextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            lineHeight: 12.sp,
          ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.borderColor ?? AppColors.textPrimary,
        ),
        hintText: widget.hintText,
        hintStyle: getTextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: widget.backgroundColor ?? Colors.white,
        contentPadding: contentPad,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.defaultBorderColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.defaultBorderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.defaultBorderColor,
            width: 2.0,
          ),
        ),
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  if (widget.isPasswordVisible == null) {
                    setState(() => _obscureText = !_obscureText);
                  }
                  widget.onIconPressed?.call();
                },
                tooltip: _obscureText ? 'Show password' : 'Hide password',
              )
            : (widget.icon != null
                  ? Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        widget.icon,
                        color: widget.suffixIconColor ?? Colors.grey,
                      ),
                    )
                  : null),
      ),
    );
  }
}
