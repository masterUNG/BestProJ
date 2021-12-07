import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowTextFormField extends StatelessWidget {
  final String hide;
  final IconData iconData;
  final double width;
  final String? Function(String?)? funcValidate;
  final Function(String?)? funcSave;
  final TextInputType? textInputType;
  final List<TextInputFormatter> textInputFormatters;
  const ShowTextFormField({
    Key? key,
    required this.hide,
    required this.iconData,
    required this.width,
    required this.funcValidate,
    required this.funcSave,
    required this.textInputFormatters,
    this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: width,
      child: TextFormField(
        inputFormatters: textInputFormatters,
        keyboardType: textInputType ?? TextInputType.text,
        onSaved: funcSave,
        validator: funcValidate,
        decoration: InputDecoration(
          prefixIcon: Icon(iconData),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          hintText: hide,
        ),
      ),
    );
  }
}
