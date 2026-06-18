import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/pages/auth/register_page.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/widgets/input_box.dart';
import 'package:sona/api/auth/api_auth.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/pages/auth/set_pin_page.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/api/auth/sign_in_with_google.dart';
import 'package:sona/widgets/loading_animation.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final GoogleAuthService _authService = GoogleAuthService();
  String? emailError;
  String? passwordError;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
            
                  children: [
            
                    Image.asset(
                      'assets/images/sona_logo_with_text.png',
            
                      height: 100,
                      width: 100,
                    ),
            
                    const SizedBox(height: 55),
            
                    const Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
            
                    const SizedBox(height: 39),
            
                    InputBox(
                      label: 'EMAIL',
                      placeholder: 'Enter your email',
                      controller: controllerEmail,
                      errorText: emailError,
                      keyboardType: TextInputType.emailAddress,
                    ),
            
                    const SizedBox(height: 30),
            
                    InputBox(
                      label: 'PASSWORD',
                      placeholder: 'Enter your password',
                      controller: controllerPassword,
                      isConfidential: true,
                      errorText: passwordError,
                    ),
            
                    const SizedBox(height: 39),
            
                    GreenButton(
                      text: 'Login',
                      onPressed: () async { 
                        
                        setState(() {
                          isLoading = true;
                          emailError = null;
                          passwordError = null;
                        });
            
                        try {
                          final result = await ApiAuth().login(
                            controllerEmail.text,
                            controllerPassword.text,
                          );
                          
                          if(result['token'] != null)
                          {
                            await ref.read(tokenProvider.notifier).setToken(result['token']);
              
                            final hasPin = result['has_pin'] == true;
            
                            if(!hasPin) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetPinPage(isFromGoogle: false, isFromLogin: true),
                                )
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            }
            
                            
                          } else
                          {
                            setState(() {
              
                              if (result['field'] == 'email') {
                                emailError = result['message'];
                              }
              
                              else if (result['field'] == 'password') {
                                passwordError = result['message'];
                              }
              
                              else if (result['field'] == 'both') {
                                emailError = result['message'];
                                passwordError = result['message'];
                              }
              
                              else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ?? 'Login gagal',
                                    ),
                                  ),
                                );
                              }
                            });
                          }
            
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    ),
            
                    const SizedBox(height: 25),
            
                    const Text(
                      'Or sign in with',
            
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA29EB6),
                      ),
                    ),
            
                    const SizedBox(height: 13),
            
                    Container(
                      width: 82,
                      height: 41,
            
                      decoration: BoxDecoration(
                        color: Colors.white,
            
                        borderRadius: BorderRadius.circular(8),
            
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
            
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
            
                        onTap: () async {
            
                          setState(() {
                            isLoading = true;
                          });
            
                          try {
                            final result = await _authService.signInWithGoogle();
                            if (!mounted) return;
            
                            if (result != null) {
                              final token = result['token'];
                              final hasPin = result['has_pin'] == true;
            
                              await ref.read(tokenProvider.notifier).setToken(token);
            
                              if (hasPin) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                  (route) => false,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SetPinPage(isFromGoogle: true),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Google Sign In gagal")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );  
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
            
                        child: Padding(
                          padding: const EdgeInsets.all(8),
            
                          child: 
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 28,
                            width: 28,
                          ),
                        ),
                      ),
                    ),
            
                    const SizedBox(height: 20),
            
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFA29EB6),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0077A1),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          ),

          if(isLoading)
            Container(
              color: AppTheme.deepTeal.withOpacity(0.4),
              child: const LoadingAnimation(),
            ),
        ],
      ),
    );
  }
}
