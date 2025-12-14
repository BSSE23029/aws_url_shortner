import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StealthInput extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged; // Added for live validation

  const StealthInput({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<StealthInput> createState() => _StealthInputState();
}

class _StealthInputState extends State<StealthInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dynamic Ink Color (Black in Light Mode, White in Dark Mode)
    final mainColor = theme.colorScheme.onSurface;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      style: TextStyle(color: mainColor, fontSize: 16),
      cursorColor: mainColor,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: mainColor.withValues(alpha: 0.5)),
        prefixIcon: Icon(
          widget.icon,
          // color: mainColor.withValues(alpha: 0.7),
          color: mainColor.withValues(alpha: 1),
          size: 22,
        ),

        // The Eye Toggle
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? PhosphorIconsBold.eye
                      : PhosphorIconsBold.eyeSlash,
                  color: mainColor.withValues(alpha: 0.5),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,

        // Stealth Borders
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
      validator: widget.validator,
    );
  }
}
