import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Define colors based on the provided palette
const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isSpotifyConnected = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Wallpaper and avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Wallpaper
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                      color: grey,
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 80,
                        color: darkRed.withOpacity(0.5),
                      ),
                    ),
                    // Avatar overlapping the wallpaper
                    Positioned(
                      bottom: -50,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: grey,
                              border: Border.all(color: white100, width: 4), // White border
                            ),
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 50,
                              color: darkRed.withOpacity(0.5),
                            ),
                          ),
                          // Camera icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: peach,
                                boxShadow: [
                                  BoxShadow(
                                    color: grey.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.camera,
                                  color: white100,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 40,
                      left: 20,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                            color: white100,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: grey.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color: darkRed,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70), // Gap to account for the avatar overlap

                // Edit Profile section title
                Center(
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: darkRed,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned text
                    children: [
                      // Username
                      Text(
                        "Username",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      CupertinoTextField(
                        controller: _usernameController,
                        placeholder: "Username",
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
                      SizedBox(height: 20),

                      // Email
                      Text(
                        "Email Address",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: "Email",
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
                      SizedBox(height: 20),

                      // Description
                      Text(
                        "Description",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      CupertinoTextField(
                        controller: _descriptionController,
                        placeholder: "Description",
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
                      SizedBox(height: 20),

                      // Password
                      Text(
                        "Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      CupertinoTextField(
                        controller: _passwordController,
                        obscureText: true, // Hide password input
                        placeholder: "Password",
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
                      SizedBox(height: 20),

                      // Spotify connection toggle
                      Text(
                        "Connect to Spotify",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      SizedBox(height: 10),
                      CupertinoSwitch(
                        value: isSpotifyConnected,
                        onChanged: (bool value) {
                          setState(() {
                            isSpotifyConnected = value;
                          });
                        },
                        activeColor: peach,
                      ),
                      SizedBox(height: 20),

                      // Favourite Albums section
                      Text(
                        "Favourite Albums",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Row for album containers with square dimensions and adjusted spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Stretch across the screen
                        children: List.generate(5, (index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.16, // Set width to ensure square shape
                            height: MediaQuery.of(context).size.width * 0.16, // Set height equal to width for square
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), // Make sure the corners are rounded like in the image
                              border: Border.all(color: grey),
                              color: grey.withOpacity(0.2),
                            ),
                            child: Icon(
                              CupertinoIcons.add, // Use the plus icon
                              color: darkRed.withOpacity(0.5),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Save changes button (sticky at the bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withOpacity(0.9), // Slight background to separate from content
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [peach, peach.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: peach.withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  onPressed: () {
                    // Save changes logic
                  },
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Save Changes",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white100,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  color: null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}