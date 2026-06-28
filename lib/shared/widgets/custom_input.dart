import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  // NOVA PROPRIEDADE
  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onSubmitted,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,

          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon)
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
