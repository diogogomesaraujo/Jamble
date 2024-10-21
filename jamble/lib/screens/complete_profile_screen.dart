import 'package:flutter/cupertino.dart';
import 'package:frontend/services/complete_profile.dart'; // Import CompleteProfileService
import 'package:flutter_svg/flutter_svg.dart';

const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class CompleteProfileScreen extends StatefulWidget {
  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  
  bool isLoading = false;
  String errorMessage = '';
  bool isCompleteProfileLoading = false;
  bool isCompleteProfileButtonPressed = false;
  
  final CompleteProfileService profileService = CompleteProfileService(); // Use CompleteProfileService

  @override
  void dispose() {
    _usernameController.dispose(); // Dispose controller when screen is destroyed
    super.dispose();
  }

  // Complete profile by updating the username
  Future<void> _completeProfile() async {
    final String username = _usernameController.text;

    if (username.isEmpty || username.length < 3) {
      setState(() {
        errorMessage = 'Username must be at least 3 characters long';
      });
      return;
    }

    setState(() {
      isLoading = true;
      isCompleteProfileLoading = true;
      errorMessage = '';
    });

    try {
      final success = await profileService.completeProfile(username: username);

      if (success) {
        _navigateToMainPage(); // Navigate to the main page on success
      } else {
        setState(() {
          errorMessage = 'Profile update failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
        isCompleteProfileLoading = false;
      });
    }
  }

  // Navigate to the main page after completing the profile
  void _navigateToMainPage() {
    Navigator.pushReplacementNamed(context, '/edit-profile');
  }

  void _onCompleteProfileButtonPressed(bool isPressed) {
    setState(() {
      isCompleteProfileButtonPressed = isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/flower.svg',
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Complete your profile!",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              color: darkRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Choose your username to start jambling about your favourite songs with your friends!",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: darkRed.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField("Username", _usernameController),
                    SizedBox(height: 30),
                    AnimatedOpacity(
                      opacity: errorMessage.isNotEmpty ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildCompleteProfileButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: darkRed,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: "Enter $label",
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          placeholderStyle: TextStyle(
            color: darkRed.withOpacity(0.5),
          ),
          style: TextStyle(color: darkRed),
          decoration: BoxDecoration(
            border: Border.all(color: grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteProfileButton() {
    return GestureDetector(
      onTapDown: (_) => _onCompleteProfileButtonPressed(true),
      onTapUp: (_) => _onCompleteProfileButtonPressed(false),
      onTapCancel: () => _onCompleteProfileButtonPressed(false),
      onTap: _completeProfile, // Trigger profile completion when button is pressed
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isCompleteProfileButtonPressed ? peach.withOpacity(0.8) : peach,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: peach.withOpacity(0.8),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: isCompleteProfileLoading
              ? CupertinoActivityIndicator()
              : Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: white100,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
