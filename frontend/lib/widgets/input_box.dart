import 'package:flutter/material.dart';

class InputBox extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isConfidential;
  final bool isDate;
  final TextEditingController? controller;
  final String? errorText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const InputBox({
    super.key,
    required this.label,
    required this.placeholder,
    this.isConfidential = false,
    this.isDate = false,
    this.controller,
    this.errorText,
    this.prefixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  bool isFocused = false;
  bool isHidden = true;

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
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
                  ? const Color(0x22CE031B)
                  : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            focusNode: widget.isDate ? null : focusNode,
            controller: widget.controller,

            onTap: widget.isDate ? () async{
              DateTime? pickedDate = await showDatePicker(
                context: context,

                initialDate: DateTime.now(),

                firstDate: DateTime(1900),

                lastDate: DateTime(2100),

                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF004D57),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF003A3F),
                      ),
                    ),

                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {

                String formattedDate =
    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                widget.controller?.text = formattedDate;

                print("SELECTED DATE RAW: $pickedDate");
                print("SELECTED DATE FORMATTED: $formattedDate");

              }
            }   
            : widget.onTap,
            obscureText: widget.isConfidential ? isHidden : false,
            keyboardType: widget.keyboardType,
            readOnly: widget.isDate || widget.readOnly,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0C3D3E),
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: const TextStyle(
                color: Color(0xFFA29EB6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 8 : 18,
                vertical: 18,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: hasError ? const Color(0xFFCE031B) : const Color(0xFF0C3D3E),
                      size: 20,
                    )
                  : null,
              suffixIcon: hasError
                  ? const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.error,
                        color: Color(0xFFCE031B),
                        size: 22,
                      ),
                    )
                  : widget.isConfidential
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                          },
                          icon: Icon(
                            isHidden  ? Icons.visibility_off : Icons.visibility,
                            color: isFocused ? const Color(0xFF0C3D3E) : const Color(0xFFA29EB6),
                          ),
                        )
                      : widget.isDate 
                  ? const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF00727C),
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
              color: Color(0xFFCE031B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
      ],
    );
  }
}
