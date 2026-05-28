import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/widgets/input_box.dart';
import 'package:sona/api/auth/api_auth.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/providers/app_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),

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
                  color: Color(0xFF003A3F),
                ),
              ),

              const SizedBox(height: 39),

              InputBox(
                label: 'EMAIL',
                placeholder: 'Enter your email',
                controller: controllerEmail,
                errorText: emailError,
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
                    emailError = null;
                    passwordError = null;
                  });
                  
                  final result = await ApiAuth().login(
                    controllerEmail.text,
                    controllerPassword.text,
                  );
                  
                  if(result['token'] != null)
                  {
                    await ref.read(tokenProvider.notifier).setToken(result['token']);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      )
                    );
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

                }
              ),

              const SizedBox(height: 11),
              
              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed: () {
                    print('Forgot Password clicked');
                  },

                  child: const Text(
                    'Forgot Password',

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0077A1),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 55),

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

                  onTap: () {
                    print('Google');
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

              const SizedBox(height: 55),

              const Text(
                'Don\'t have an account? Sign Up',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA29EB6),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
