import 'package:flutter/material.dart';

class StealthInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool isObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const StealthInput({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.isObscure = false,
    this.validator,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // The "Ink" Color (White on Dark, Black on Light)
    final mainColor = isDark ? Colors.white : Colors.black;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isObscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(color: mainColor, fontSize: 16),
      cursorColor: mainColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mainColor.withValues(alpha: 0.5)),
        prefixIcon: Icon(
          icon,
          color: mainColor.withValues(alpha: 0.7),
          size: 22,
        ),

        // Stealth Borders (Dynamic)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: mainColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mainColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }
}
