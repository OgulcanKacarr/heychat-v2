import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextfieldWidgets extends StatefulWidget {
  final TextEditingController controller;
  final String hint_text;
  final Icon prefix_icon;
  final bool is_password;
  final TextInputType keyboard_type;

  CustomTextfieldWidgets({
    required this.controller,
    required this.hint_text,
    required this.prefix_icon,
    this.is_password = false,
    required this.keyboard_type,
  });

  @override
  _CustomTextfieldWidgetsState createState() => _CustomTextfieldWidgetsState();
}

class _CustomTextfieldWidgetsState extends State<CustomTextfieldWidgets> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboard_type,
      obscureText: _isObscure && widget.is_password,
      cursorColor: Colors.tealAccent,
      decoration: InputDecoration(
        label: Text(widget.hint_text),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        prefixIcon: widget.prefix_icon,
        suffixIcon: widget.is_password
            ? IconButton(
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          icon: Icon(Icons.remove_red_eye),
        )
            : null,
      ),

    );
  }
}
