import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../services/edit_profile.dart';
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
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final EditProfileService _editProfileService = EditProfileService();

  bool hasSpotifyId = false; // Whether the user has a Spotify ID
  String _userImage = '';
  String _userWallpaper = '';
  List<String> _favoriteAlbums = [];
  bool _isLoading = true; // Loading flag to show loading indicator

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Function to load user information from secure storage
  Future<void> _loadUserInfo() async {
    final username = await _secureStorage.read(key: 'user_username');
    final email = await _secureStorage.read(key: 'user_email');
    final description = await _secureStorage.read(key: 'user_small_description');
    final userImage = await _secureStorage.read(key: 'user_image');
    final userWallpaper = await _secureStorage.read(key: 'user_wallpaper');
    final favoriteAlbumsString = await _secureStorage.read(key: 'user_favorite_albums');
    final spotifyId = await _secureStorage.read(key: 'user_spotify_id'); // Check for spotify_id

    setState(() {
      _usernameController.text = username ?? '';
      _emailController.text = email ?? '';
      _descriptionController.text = description ?? '';
      _userImage = userImage ?? '';
      _userWallpaper = userWallpaper ?? '';
      _favoriteAlbums = favoriteAlbumsString?.split(',') ?? [];

      // Check if spotify_id exists and is not empty
      hasSpotifyId = spotifyId != null && spotifyId.isNotEmpty;

      _isLoading = false; // Loading complete
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100), // Padding to avoid overlapping with the Save button
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
                      _buildInputField("Username", _usernameController),
                      SizedBox(height: 20),
                      
                      // Show email and password only if spotify_id is not present
                      if (!hasSpotifyId) ...[
                        _buildInputField("Email Address", _emailController),
                        SizedBox(height: 20),
                        _buildInputField("Password", _passwordController, obscureText: true),
                        SizedBox(height: 20),
                      ],

                      _buildInputField("Description", _descriptionController),
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
          // Back button (sticky)
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
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false}) {
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
        email: hasSpotifyId ? "" : _emailController.text,  // Email is empty for Spotify accounts
        password: hasSpotifyId ? "" : _passwordController.text,  // Password is empty for Spotify accounts
        description: _descriptionController.text,
        userImage: _userImage,
        userWallpaper: _userWallpaper,
        favoriteAlbums: _favoriteAlbums,
      );
      _showNotificationBanner('Profile updated successfully!', Colors.green);
    } catch (error) {
      _showNotificationBanner('Error updating profile!', Colors.red);
    }
  }

  void _showNotificationBanner(String message, Color backgroundColor) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        backgroundColor == Colors.green
                            ? CupertinoIcons.check_mark_circled
                            : CupertinoIcons.exclamationmark_triangle,
                        color: white100,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: white100,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Dismiss the notification banner after 2 seconds
    });
  }
}
