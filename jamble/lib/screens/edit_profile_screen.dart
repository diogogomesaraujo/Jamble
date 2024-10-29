import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/favourite_albums.dart';
import '../services/edit_profile.dart';
import '../modals/album_search_modal.dart';
import '../modals/artist_search_modal.dart';

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

  bool hasSpotifyId = false;
  String _userImage = '';
  String _userWallpaper = '';
  List<Album> _favoriteAlbums =
      List.generate(5, (_) => Album.empty()); // Initialize with empty albums
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final username = await _secureStorage.read(key: 'user_username');
    final email = await _secureStorage.read(key: 'user_email');
    final description =
        await _secureStorage.read(key: 'user_small_description');
    final userImage = await _secureStorage.read(key: 'user_image');
    final userWallpaper = await _secureStorage.read(key: 'user_wallpaper');
    final spotifyId = await _secureStorage.read(key: 'user_spotify_id');

    List<Album> albumList = [];
    try {
      albumList = await FavouriteAlbumsService().getFavoriteAlbums();
    } catch (e) {
      _showNotificationBanner(
          "Error loading albums: ${e.toString()}", Colors.red);
    }

    setState(() {
      _usernameController.text = username ?? '';
      _emailController.text = email ?? '';
      _descriptionController.text = description ?? '';
      _userImage = userImage ?? '';
      _userWallpaper = userWallpaper ?? '';
      _favoriteAlbums = albumList.isNotEmpty
          ? albumList
          : List.generate(5, (_) => Album.empty());
      hasSpotifyId = spotifyId != null && spotifyId.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                      color: grey,
                    ),
                    Positioned(
                      bottom: -50,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    ArtistSearchModal(
                                  onArtistSelected: (selectedArtistImageUrl) {
                                    if (selectedArtistImageUrl != null) {
                                      setState(() {
                                        _userImage = selectedArtistImageUrl;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                            child: Container(
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
                                image: _userImage.isNotEmpty &&
                                        _userImage != 'default_image_url'
                                    ? DecorationImage(
                                        image: NetworkImage(_userImage),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _userImage.isEmpty ||
                                      _userImage == 'default_image_url'
                                  ? Icon(
                                      EvaIcons.personOutline,
                                      size: 50,
                                      color: darkRed.withOpacity(0.3),
                                    )
                                  : null,
                            ),
                          ),
                          // Camera button overlaying the profile picture
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Handle camera button action
                              },
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70),

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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField("Username", _usernameController),
                      SizedBox(height: 20),
                      _buildInputField("Email Address", _emailController),
                      SizedBox(height: 20),
                      _buildInputField("Password", _passwordController,
                          obscureText: true),
                      SizedBox(height: 20),
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
          // Save changes button
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
          // Circular sticky back button on top of everything
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // White background for the button
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    EvaIcons.arrowBack,
                    color: darkRed, // Icon color to match your theme
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        final album = _favoriteAlbums[index];

        return GestureDetector(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => AlbumSearchModal(
                onAlbumSelected: (selectedAlbum) {
                  setState(() {
                    _favoriteAlbums[index] = selectedAlbum ??
                        Album.empty(); // Reset to empty if null
                  });
                },
                favouriteAlbums: _favoriteAlbums,
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.13,
            height: MediaQuery.of(context).size.width * 0.13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: album.id == 'empty' ? grey : null,
              image: album.id != 'empty'
                  ? DecorationImage(
                      image: NetworkImage(album.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: album.id == 'empty'
                ? Icon(
                    CupertinoIcons.add,
                    color: darkRed.withOpacity(0.5),
                    size: 18,
                  )
                : null,
          ),
        );
      }),
    );
  }

  void _saveProfile() async {
    try {
      final List<String> favoriteAlbumIds = _favoriteAlbums
          .where((album) => album.id != 'empty') // Filter out empty albums
          .map((album) => album.id)
          .toList();

      await _editProfileService.editUserProfile(
        username: _usernameController.text,
        email: hasSpotifyId ? "" : _emailController.text,
        password: hasSpotifyId ? "" : _passwordController.text,
        description: _descriptionController.text,
        userImage: _userImage,
        userWallpaper: _userWallpaper,
        favoriteAlbums: favoriteAlbumIds,
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
      Navigator.of(context).pop();
    });
  }
}
