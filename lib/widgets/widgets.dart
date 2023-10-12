import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType inputType;
  final String? Function(String?)? validation;
  final BuildContext context;

  PasswordField({
    required this.controller,
    required this.hint,
    required this.inputType,
    required this.validation,
    required this.context,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      decoration: _decoration(widget.hint, context),
      obscureText: passwordVisible,
      validator: widget.validation,
      // Add a suffix icon to toggle password visibility
    );
  }

  InputDecoration _decoration(hintTexts, context) {
    return InputDecoration(
      prefixIcon: Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            passwordVisible = !passwordVisible;
          });
        },
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          )),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          )),
      hintText: hintTexts,
    );
  }
}

class CustomWidgets {
  static InkWell loginButton(BuildContext context, VoidCallback onTap,
      bool isLoading, String btnName) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    btnName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

TextFormField textFormField(
  TextEditingController controller,
  String hint,
  bool obscure,
  TextInputType inputType,
  String? Function(String?)? validation,
  BuildContext context,
  IconData icon,
) {
  return TextFormField(
    controller: controller,
    keyboardType: inputType,
    decoration: decoration(hint, context, obscure, controller, icon),
    obscureText: obscure,
    validator: validation,
  );
}

InputDecoration decoration(hintTexts, context, bool obscure, controller, icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(
        Radius.circular(25),
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(
        Radius.circular(25),
      ),
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        )),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        )),
    hintText: hintTexts,
  );
}
