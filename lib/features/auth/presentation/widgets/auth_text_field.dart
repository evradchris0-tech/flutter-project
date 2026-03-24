import 'package:flutter/material.dart';

/// Champ de texte stylisé réutilisable pour les formulaires d'authentification.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText     = false,
    this.keyboardType    = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.enabled         = true,
    this.autofocus       = false,
    this.autocorrect     = false,
  });

  final TextEditingController     controller;
  final String                    label;
  final String?                   hint;
  final IconData?                 prefixIcon;
  final Widget?                   suffixIcon;
  final bool                      obscureText;
  final TextInputType             keyboardType;
  final TextInputAction           textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)?    onFieldSubmitted;
  final bool                      enabled;
  final bool                      autofocus;
  final bool                      autocorrect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller:      controller,
      obscureText:     obscureText,
      keyboardType:    keyboardType,
      textInputAction: textInputAction,
      validator:       validator,
      onFieldSubmitted: onFieldSubmitted,
      enabled:         enabled,
      autofocus:       autofocus,
      autocorrect:     autocorrect,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary)
            : null,
        suffixIcon: suffixIcon,
        filled:     true,
        fillColor:  colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical:   18,
        ),
      ),
    );
  }
}
