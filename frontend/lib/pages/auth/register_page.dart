import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/widgets/input_box.dart';
import 'package:sona/api/auth/api_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/pages/auth/set_pin_page.dart';
import 'package:sona/widgets/top_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sona/api/auth/sign_in_with_google.dart';
import 'package:sona/pages/home/home_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDateofBirth = TextEditingController();
  TextEditingController controllerTelp = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerConfirmPassword = TextEditingController();

  String? emailError, passwordError, nameError, dateOfBirthError, telpError, confirmError;
  final GoogleAuthService _authService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Create Account"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                                        
                          children: [
                            Text(
                              "Join Sona",
                              style: const TextStyle(
                                color: Color(0xFF003A3F),
                                fontSize: 29,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                                        
                            SizedBox(height: 12),
                                        
                            Text(
                              "Enter your details to start booking your next stay with exclusive member rates.",
                              style: const TextStyle(
                                color: Color(0xFF505050),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                                        
                      const SizedBox(height: 24),
                                        
                      Center(
                        child: Column(
                          children: [
                            InputBox(
                              label: 'FULL NAME',
                              placeholder: 'Enter your full name',
                              controller: controllerName,
                              errorText: nameError,
                            ),
                                        
                            const SizedBox(height: 30),

                            InputBox(
                              label: 'DATE OF BIRTH',
                              placeholder: 'Enter your date of birth',
                              controller: controllerDateofBirth,
                              errorText: dateOfBirthError,
                              isDate: true,
                            ),
                                        
                            const SizedBox(height: 30),
                                        
                            InputBox(
                              label: 'PHONE NUMBER',
                              placeholder: 'Enter your phone number',
                              controller: controllerTelp,
                              errorText: telpError,
                            ),
                                        
                            const SizedBox(height: 30),
                                        
                            InputBox(
                              label: 'EMAIL',
                              placeholder: 'Enter your email',
                              controller: controllerEmail,
                              errorText: emailError,
                            ),
                                        
                            const SizedBox(height: 30),
                                        
                            InputBox(
                              label: 'PASSWORD',
                              placeholder: 'Enter a 6-digit password',
                              controller: controllerPassword,
                              errorText: passwordError,
                              isConfidential: true,
                            ),
                                        
                            const SizedBox(height: 30),
                                        
                            InputBox(
                              label: 'CONFIRM PASSWORD',
                              placeholder: 'Confirm your password',
                              controller: controllerConfirmPassword,
                              errorText: confirmError,
                              isConfidential: true,
                            ),
                                        
                            const SizedBox(height: 30),
                                        
                            GreenButton(
                              text: 'Sign Up',
                              onPressed: () async { 
                                
                                setState(() {
                                  emailError = null;
                                  passwordError = null;
                                  nameError = null;
                                  dateOfBirthError = null;
                                  telpError = null;
                                  confirmError = null;
                                });

                                if (controllerPassword.text != controllerConfirmPassword.text) {
                                  setState(() {
                                    confirmError = "Password confirmation does not match.";
                                  });
                                  return;
                                }
                                
                                final result = await ApiAuth().register(
                                  controllerName.text,
                                  controllerEmail.text,
                                  controllerDateofBirth.text,
                                  controllerTelp.text,
                                  controllerPassword.text,
                                );

                                print(controllerDateofBirth.text);
                                
                                if (result['message'] == 'Register Successful') {
                                  final prefs = await SharedPreferences.getInstance();

                                  await prefs.setString(
                                    'token',
                                    result['token'],
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SetPinPage(
                                      ),
                                    ),
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
                                        
                                    else if (result['field'] == 'name') {
                                      nameError = result['message'];
                                    }
                                        
                                    else if (result['field'] == 'date_of_birth') {
                                      dateOfBirthError = result['message'];
                                    }
                                        
                                    else if (result['field'] == 'telp_no') {
                                      telpError = result['message'];
                                    }
                                        
                                    else
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ?? 'Register gagal',
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                }
                              }
                            ),

                            const SizedBox(height: 55),

                            const Text(
                              'Or sign up with',

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
                                  try {
                                    final result = await _authService.signInWithGoogle();

                                    if (result != null) {
                                      final token = result['token'];
                                      final hasPin = result['has_pin'] == true;

                                      ProviderScope.containerOf(context)
                                      .read(tokenProvider.notifier)
                                      .setToken(token);

                                      if (hasPin) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomePage()),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SetPinPage()),
                                      );
                                    }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Google Sign In gagal")),
                                      );
                                    }
                                  } catch (e, stack) {
                                    print("GOOGLE SIGN IN ERROR: $e");
                                    print(stack);
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

                            const SizedBox(height: 55),
                          ],
                        )
                      )
                    ],
                  ),
                )
              ),
            ),
          ]
        ),
      )
    );
  }
}