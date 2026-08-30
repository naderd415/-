import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelKey;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelKey,
    required this.prefixIcon,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.suffixIcon,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = context.isRtl;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: context.translate(labelKey),
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark ? Colors.tealAccent : Colors.teal,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              color: isDark ? Colors.tealAccent : Colors.teal,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        ),
      ),
    );
  }
}
