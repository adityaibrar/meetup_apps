import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable text field dengan styling konsisten.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? prefixText;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20)
            : null,
        suffixIcon: suffix,
      ),
    );
  }
}
