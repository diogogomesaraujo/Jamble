import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../services/edit_profile.dart'; // Import the service
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EditProfileService _editProfileService = EditProfileService();

  bool isSpotifyConnected = false;

  // Placeholder image and wallpaper URLs
  String _userImage = '';
  String _userWallpaper = '';
  List<String> _favoriteAlbums = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoPageScaffold(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Wallpaper
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        color: grey,
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
                                color: grey,
                                border: Border.all(color: white100, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
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
                            // Camera icon for uploading avatar
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
                                      color: Colors.black.withOpacity(0.1),
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
                                  color: Colors.black.withOpacity(0.05),
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
                  SizedBox(height: 70), // Space for the avatar

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        _buildInputField("Username", _usernameController),
                        SizedBox(height: 20),

                        // Email
                        _buildInputField("Email Address", _emailController),
                        SizedBox(height: 20),

                        // Description
                        _buildInputField("Description", _descriptionController),
                        SizedBox(height: 20),

                        // Password
                        _buildInputField("Password", _passwordController,
                            obscureText: true),
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

                        // Favorite Albums section
                        Text(
                          "Favorite Albums",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: darkRed,
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildFavoriteAlbumsRow(),
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
                color: Colors.white.withOpacity(0.9),
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
                  ),
                  child: CupertinoButton(
                    onPressed: _saveProfile,
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
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscureText = false}) {
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
          placeholder: label,
          obscureText: obscureText,
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

  Widget _buildFavoriteAlbumsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            // Logic to add or modify favorite albums
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.13,
            height: MediaQuery.of(context).size.width * 0.13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.add,
              color: darkRed.withOpacity(0.5),
              size: 18,
            ),
          ),
        );
      }),
    );
  }

  void _saveProfile() async {
    try {
      await _editProfileService.editUserProfile(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        description: _descriptionController.text,
        userImage: _userImage,
        userWallpaper: _userWallpaper,
        favoriteAlbums: _favoriteAlbums,
      );
      // Notify the user about success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating profile: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
