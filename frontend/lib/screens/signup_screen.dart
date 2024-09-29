import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Define colors based on the provided palette
const Color darkRed = Color(0xFF3E111B);   // 100% opacity
const Color grey = Color(0xFFDDDDDD);      // 100% opacity
const Color peach = Color(0xFFFEA57D);     // 100% opacity
const Color white100 = Color(0xFFFFFFFF);  // 100% opacity

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flower SVG aligned on top of the title and resized
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/flower.svg',
                      height: 50,  // Increased size to match the Figma design
                      width: 50,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Let’s sign you up!",
                      style: TextStyle(
                        fontFamily: 'Poppins',  // Ensure Poppins is used
                        fontWeight: FontWeight.w700,  // Bold weight for Poppins
                        fontSize: 28,  // Adjusted size to match design
                        color: darkRed,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Subtitle
              Text(
                "Create an account to ramble about your favourite jams with your friends!",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',  // Ensure the font is consistent
                  color: darkRed.withOpacity(0.6),  // Using dark red at 60% opacity
                ),
              ),
              SizedBox(height: 30),
              
              // Username field
              Text(
                "Username",
                style: TextStyle(
                  fontFamily: 'Poppins',  // Ensure the font is consistent
                  fontWeight: FontWeight.bold,
                  color: darkRed,  // Using dark red
                ),
              ),
              CupertinoTextField(
                placeholder: "samplename",
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),  // Corrected input text color to dark red
                decoration: BoxDecoration(
                  border: Border.all(color: grey),  // Using grey for border
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 20),
              
              // Email field
              Text(
                "Email Address",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,  // Using dark red
                ),
              ),
              CupertinoTextField(
                placeholder: "Sample@domain.com",
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),  // Corrected input text color to dark red
                decoration: BoxDecoration(
                  border: Border.all(color: grey),  // Using grey for border
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 20),
              
              // Password field
              Text(
                "Password",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,  // Using dark red
                ),
              ),
              CupertinoTextField(
                placeholder: "Password",
                obscureText: true,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),  // Corrected input text color to dark red
                decoration: BoxDecoration(
                  border: Border.all(color: grey),  // Using grey for border
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 30),
              
              // Custom-styled Sign Up Button with Peach Background and correct shadow
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: peach,  // Button background color
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: peach.withOpacity(0.8), // Increase peach shadow intensity
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    onPressed: () {},
                    padding: EdgeInsets.symmetric(vertical: 12),  // Adjusted thickness to be thinner
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: white100,  // White text color
                        fontSize: 14, // Adjusted to match text size
                        fontWeight: FontWeight.normal,  // Slightly bolder text
                      ),
                    ),
                    color: null,  // Transparent button background
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Custom Divider with 'or'
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.0,  // Thicker divider
                      color: darkRed.withOpacity(0.2),  // Dark red with 20% opacity
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: darkRed, // Make "or" dark red
                        fontWeight: FontWeight.bold,  // Bold for "or"
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.0,  // Thicker divider
                      color: darkRed.withOpacity(0.2),  // Dark red with 20% opacity
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Spotify Button
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: white100,  // White background for the button
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: grey.withOpacity(0.7),  // Increased shadow intensity
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50), // Adjusted padding for thin button
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.spotify, color: CupertinoColors.activeGreen),
                        SizedBox(width: 10),
                        Text(
                          "Continue with Spotify",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: darkRed,  // Using dark red for text
                            fontSize: 14, // Matching text size
                          ),
                        ),
                      ],
                    ),
                    color: null,  // Button is transparent to show custom white container
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Sign up text
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Sign up action
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "You don’t have an account yet? ",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: darkRed.withOpacity(0.6),  // Using dark red at 60% opacity
                      ),
                      children: [
                        TextSpan(
                          text: "Sign up!",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: darkRed,  // Bold dark red for 'Sign up!'
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
