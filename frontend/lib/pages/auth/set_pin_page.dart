import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/widgets/top_bar.dart';
import 'package:pinput/pinput.dart';
import 'package:sona/api/auth/api_auth.dart';
import 'package:sona/pages/auth/login_page.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/widgets/loading_animation.dart';

class SetPinPage extends ConsumerStatefulWidget {
  final bool isFromGoogle;
  
  
  const SetPinPage({super.key, this.isFromGoogle = false});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends ConsumerState<SetPinPage> {
  TextEditingController pinController = TextEditingController();
  String? pinError;
  bool isLoading = false;

  final defaultPinTheme = PinTheme(
    width: 54,
    height: 48,
    textStyle: const TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.bold,
      color: Color(0xFF003A3F),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFF003A3F),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    )
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const TopBar(title: "Create Secret PIN"),
          
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        reverse: true,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                                    
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 75,
                                          height: 75,
                                    
                                          decoration: BoxDecoration(
                                            color: Color(0xFF003A3F),
                                    
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                    
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                    
                                              child: const Icon(
                                                Icons.lock_outline,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                                
                                            ),
                                          ),
                                        ),
                                    
                                        SizedBox(height: 12),
                                    
                                        Text(
                                          'Create Secret PIN',
                                          style: const TextStyle(
                                            color: Color(0xFF003A3F),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    
                                        SizedBox(height: 48),
                                    
                                        Text(
                                          'Enter a 4-digit PIN',
                                          style: const TextStyle(
                                            color: Color(0xFF003A3F),
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                    
                                        SizedBox(height: 12),
                                    
                                        Pinput(
                                          controller: pinController,
                                          defaultPinTheme: defaultPinTheme,
                                          length: 4,
                                          obscureText: true,
                                          keyboardType: TextInputType.number,
                                          onCompleted: (_) {
                                            FocusScope.of(context).unfocus();
                                          },
                                        ), 
                                        if (pinError != null) 
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              pinError!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                    
                                        SizedBox(height: 48),
                                    
                                        GreenButton(
                                          text: 'Submit',
                                          onPressed: () async {
                                            if(pinController.text.length != 4) {
                                              setState(() {
                                                pinError = "PIN must be 4 digits";
                                              });
                                              return;
                                            }
                          
                                            setState(() {
                                              isLoading = true;
                                              pinError = null;
                                            });
                          
                                            try {
                                              final token = ref.read(tokenProvider);
                                      
                                              if (token == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Session expired"),
                                                  ),
                                                );
                                                return;
                                              }
                                      
                                              final success = await ApiAuth().setPin(
                                                token,
                                                pinController.text,
                                                isFromGoogle: widget.isFromGoogle,
                                              );
                                      
                                              if (success) {
                                                if(widget.isFromGoogle) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("PIN saved successfully"),
                                                    ),
                                                  );
                                      
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                                    (route) => false,
                                                  );
                                                } else {
                                                  await ref.read(tokenProvider.notifier).clearToken();
                                      
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("PIN saved successfully, please login again"),
                                                    ),
                                                  );
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                                    (route) => false,
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Failed to save PIN"),
                                                  ),
                                                );
                                              }
                          
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                      );
                    }
                  ),
                )
              ],
            )
          ),
          if(isLoading)
            Container(
              color: AppTheme.deepTeal.withOpacity(0.4),
              child: const LoadingAnimation(),
            ),
        ],
      )
    );
  }
}