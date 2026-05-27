import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isConfidential;
  final TextEditingController? controller;
  final String? errorText;

  const InputBox({
    super.key,
    required this.label,
    required this.placeholder,
    this.isConfidential = false,
    this.controller,
    this.errorText,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  bool isFocused = false;
  bool isHidden = true;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() 
  {
    super.initState();

    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          widget.label,

          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF505050),
          ),
        ),

        const SizedBox(height: 8),

        AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: hasError ? const Color(0xFFCE031B) 
                    : isFocused ? const Color(0xFF00727C) : Colors.transparent,

              width: 2,
            ),

            boxShadow: [
              BoxShadow(
                color: hasError
                  ? const Color(0x66CE031B)
                  : Colors.black12,

                blurRadius: 8,

                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: TextField(
            focusNode: focusNode,
            controller: widget.controller,

            obscureText: widget.isConfidential ? isHidden : false,

            decoration: InputDecoration(
              hintText: widget.placeholder,

              hintStyle: const TextStyle(
                color: Color(0xFFA29EB6),
                fontSize: 14,
              ),

              border: InputBorder.none,

              contentPadding: 
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),

                suffixIcon: widget.isConfidential
                  ? IconButton(
                    onPressed: () {
                      setState(() {
                        isHidden = !isHidden;
                      });
                    },

                    icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  )
                  : null,
            ),
          ),
        ),

        //kalau ada error, semua widget dimasukin ke list children, lalu tampilkan error
        if(hasError) ...
        [
          const SizedBox(height: 6),

          Text(
            widget.errorText!,
            style: const TextStyle(
              color: Color(0xFFE53935),
              fontSize: 12,
            ),
          ),
        ]
      ],
    );
  }
}
