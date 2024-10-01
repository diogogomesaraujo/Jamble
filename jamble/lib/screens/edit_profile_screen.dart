import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

// Define colors based on the provided palette
const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFF2F2F2);
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
                      color: grey, // Fully opaque light grey wallpaper
                      child: Icon(
                        EvaIcons.imageOutline,
                        size: 60,
                        color: darkRed.withOpacity(0.3),
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
                              color: grey, // Fully opaque light grey avatar
                              border: Border.all(color: white100, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05), // Subtle shadow
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              EvaIcons.personOutline,
                              size: 50,
                              color: darkRed.withOpacity(0.3),
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
                                    color: Colors.black
                                        .withOpacity(0.1), // More subtle shadow
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  EvaIcons.camera,
                                  color: white100,
                                  size: 16,
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
                                color: Colors.black
                                    .withOpacity(0.05), // Subtle shadow
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            EvaIcons.arrowBackOutline,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Left-aligned text
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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

                      // Spotify connection toggle with subtle shadow
                      Text(
                        "Connect to Spotify",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.01), // Very subtle shadow
                              blurRadius:
                                  6, // Small blur to smooth the shadow without too much spread
                              spreadRadius:
                                  0, // No spread to keep the shadow close to the toggle
                              offset: Offset(0,
                                  1), // Slight downward offset for a smoother effect
                            ),
                          ],
                        ),
                        child: CupertinoSwitch(
                          value: isSpotifyConnected,
                          onChanged: (bool value) {
                            setState(() {
                              isSpotifyConnected = value;
                            });
                          },
                          activeColor: peach,
                        ),
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

                      // Row for album containers with subtle shadows
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Stretch across the screen
                        children: List.generate(5, (index) {
                          return Container(
                            width: MediaQuery.of(context).size.width *
                                0.13, // Smaller size
                            height: MediaQuery.of(context).size.width *
                                0.13, // Smaller size
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              color: grey,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05), // Subtle shadow
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.add,
                              color: darkRed.withOpacity(0.5),
                              size: 18, // Adjusted for smaller container
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
              color: Colors.white.withOpacity(
                  0.9), // Slight background to separate from content
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
                      color: peach.withOpacity(
                          0.2), // More subtle shadow for the button
                      blurRadius: 6,
                      offset: Offset(0, 2),
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
