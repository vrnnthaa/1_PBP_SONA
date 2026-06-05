import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/auth/api_user.dart';

enum PinState {
  enterCurrent,
  enterNew,
  confirmNew,
}

class ChangePinPage extends ConsumerStatefulWidget {
  final String token;

  const ChangePinPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  PinState _currentState = PinState.enterCurrent;
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';

  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the input fields on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Handle custom back action to navigate to previous PIN state
  void _handleBack() {
    if (_isLoading) return;

    setState(() {
      _errorText = null;
      if (_currentState == PinState.confirmNew) {
        _currentState = PinState.enterNew;
        _pinController.text = _newPin;
      } else if (_currentState == PinState.enterNew) {
        _currentState = PinState.enterCurrent;
        _pinController.text = _currentPin;
      } else {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _handleSubmit() async {
    final enteredPin = _pinController.text;

    // Validation: Check if PIN is empty or incomplete
    if (enteredPin.isEmpty || enteredPin.length < 4) {
      setState(() {
        if (_currentState == PinState.enterCurrent) {
          _errorText = 'You must enter your current PIN';
        } else if (_currentState == PinState.enterNew) {
          _errorText = 'You must enter a new PIN';
        } else {
          _errorText = 'You must confirm your new PIN';
        }
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    if (_currentState == PinState.enterCurrent) {
      // Step 1: Save current PIN and transition to New PIN screen
      _currentPin = enteredPin;
      setState(() {
        _currentState = PinState.enterNew;
        _pinController.clear();
      });
      _focusNode.requestFocus();
    } else if (_currentState == PinState.enterNew) {
      // Step 2: Save new PIN and transition to Confirm PIN screen
      _newPin = enteredPin;
      setState(() {
        _currentState = PinState.confirmNew;
        _pinController.clear();
      });
      _focusNode.requestFocus();
    } else if (_currentState == PinState.confirmNew) {
      // Step 3: Validate confirmation PIN matches and update via backend API
      _confirmPin = enteredPin;

      if (_confirmPin != _newPin) {
        setState(() {
          _errorText = 'The new confirmation PIN does not match the new PIN';
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final apiUser = ApiUser();
      final response = await apiUser.changePin(widget.token, _currentPin, _newPin);

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN updated successfully!'),
              backgroundColor: AppTheme.primary,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          // If the backend indicates incorrect old/current PIN, transition back to enterCurrent state
          setState(() {
            _currentState = PinState.enterCurrent;
            _pinController.text = _currentPin;
            _errorText = 'Your current PIN is incorrect';
          });
          _focusNode.requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic text based on current pin state
    String titleText = '';
    String subtitleText = '';

    switch (_currentState) {
      case PinState.enterCurrent:
        titleText = 'Enter your current PIN';
        subtitleText = 'Enter your previously registered PIN';
        break;
      case PinState.enterNew:
        titleText = 'Enter a new PIN';
        subtitleText = 'You must remember your new PIN';
        break;
      case PinState.confirmNew:
        titleText = 'Confirm a new PIN';
        subtitleText = 'You must remember your new PIN';
        break;
    }

    // Custom Pinput themes matching mockup styling
    final defaultPinTheme = PinTheme(
      width: 62,
      height: 62,
      textStyle: GoogleFonts.montserrat(
        fontSize: 24,
        color: AppTheme.primary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: defaultPinTheme.textStyle!.copyWith(
        color: AppTheme.errorRed,
      ),
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.5), width: 1.5),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black.withOpacity(0.1),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
            onPressed: _handleBack,
          ),
          title: const Text(
            'Change Secret PIN',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 19.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated Lock Icon Circle Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title with AnimatedSwitcher for smooth text transitions
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            titleText,
                            key: ValueKey(titleText),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF242833),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            subtitleText,
                            key: ValueKey(subtitleText),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 13.5,
                              color: AppTheme.textTealGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // PIN Input Fields (using custom Pinput)
                        Pinput(
                          length: 4,
                          controller: _pinController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          errorPinTheme: errorPinTheme,
                          forceErrorState: _errorText != null,
                          obscureText: false,
                          showCursor: false,
                          onChanged: (value) {
                            if (_errorText != null) {
                              setState(() {
                                _errorText = null;
                              });
                            }
                          },
                          onCompleted: (pin) {
                            // Automatically call submit when all 4 digits are typed
                            _handleSubmit();
                          },
                        ),

                        // Error message
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            height: _errorText != null ? null : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(
                                _errorText ?? '',
                                style: GoogleFonts.roboto(
                                  color: AppTheme.errorRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        GestureDetector(
                          onTap: _handleSubmit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
