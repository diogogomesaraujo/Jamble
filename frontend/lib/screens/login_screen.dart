import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginSelected = true; // Track whether "Login" or "Create Account" is selected

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Use SingleChildScrollView to fix overflow on smaller screens
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Adjust the maxWidth for larger screens
                minHeight: MediaQuery.of(context).size.height, // Ensures the height matches the screen
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flower SVG aligned to the left
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'assets/flower.svg', // Ensure to reference the correct asset path
                        height: 80, // Adjust the size according to your design
                      ),
                    ),
                    SizedBox(height: 20), // Space between flower and title

                    // Title
                    Text(
                      'Stay engaged',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color(0xFF3E111B), // Updated title color
                      ),
                    ),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                      child: Text(
                        'The best way to get the most out of our app is to participate actively.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF7D7E83), // Subtitle color from your palette
                        ),
                      ),
                    ),

                    // Tab bar (Login / Create Account) with full-width bottom border
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoginSelected = true;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isLoginSelected ? Color(0xFFFEA57D) : Colors.transparent,
                                    width: 2.0, // Orange line width when selected
                                  ),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isLoginSelected ? Color(0xFF3E111B) : Color(0xFF7D7E83), // Colors for selected/unselected
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoginSelected = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: !isLoginSelected ? Color(0xFFFEA57D) : Colors.transparent,
                                    width: 2.0, // Orange line width when selected
                                  ),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: !isLoginSelected ? Color(0xFF3E111B) : Color(0xFF7D7E83), // Colors for selected/unselected
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    
                    // Email Label
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF3E111B),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Email Input Field (Styled to match the Figma design)
                    CupertinoTextField(
                      placeholder: 'Sample@domain.com',
                      keyboardType: TextInputType.emailAddress,
                      placeholderStyle: TextStyle(
                        color: Color(0xFFD9D9D9), // Lighter placeholder color
                        fontFamily: 'Inter',
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjust padding to match design
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF3E111B), // Set the text color to match Figma design (dark text)
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: CupertinoColors.white, // Background color
                        border: Border.all(
                          color: Color(0xFFE0E0E0), // Light grey border
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password Label
                    Text(
                      'Password',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF3E111B),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Password Input Field (Styled to match the Figma design)
                    CupertinoTextField(
                      placeholder: 'Sample@domain.com',
                      obscureText: true,
                      placeholderStyle: TextStyle(
                        color: Color(0xFFD9D9D9), // Lighter placeholder color
                        fontFamily: 'Inter',
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjust padding to match design
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF3E111B), // Set the text color to match Figma design (dark text)
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: CupertinoColors.white, // Background color
                        border: Border.all(
                          color: Color(0xFFE0E0E0), // Light grey border
                        ),
                      ),
                    ),

                    // Login Button (matching input box size)
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Make the button match the width of input fields
                      child: CupertinoButton(
                        color: Color(0xFFFEA57D), // Updated login button color
                        borderRadius: BorderRadius.circular(8),
                        onPressed: () {
                          // Implement login logic
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Lora', // Lora Bold for login button
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),

                    // "Or" Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(color: Color(0xFFD9D9D9)), // Updated divider color
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF7D7E83), // Subtitle gray color
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Color(0xFFD9D9D9)), // Updated divider color
                          ),
                        ],
                      ),
                    ),

                    // Continue with Spotify Button (filled background)
                    SizedBox(
                      width: double.infinity, // Full-width Spotify button
                      child: CupertinoButton(
                        color: Color(0xFFF0F0F0), // Light filled background for Spotify button
                        borderRadius: BorderRadius.circular(8),
                        padding: EdgeInsets.all(16),
                        onPressed: () {
                          // Implement Spotify login logic
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.spotify,
                              color: Color(0xFF1DB954),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Continue With Spotify',
                              style: TextStyle(
                                fontFamily: 'Lora', // Lora Bold for Spotify button
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
