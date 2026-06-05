import 'package:flutter/material.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/widgets/top_bar.dart';
import 'package:pinput/pinput.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  TextEditingController pinController = TextEditingController();
  String? pinError;

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

      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Create Secret PIN"),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: Column(
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

                            SizedBox(height: 12),

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
                            ),

                            SizedBox(height: 12),

                            GreenButton(
                              text: 'Submit',
                              onPressed: () async {
                               print("resdsd");
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ),
            )
          ],
        )
      )
    );
  }
}