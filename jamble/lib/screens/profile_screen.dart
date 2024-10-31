import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/favourite_albums.dart';
import 'package:frontend/widgets/top_artists_widget.dart';
import 'package:frontend/widgets/top_songs_widget.dart';

const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFF2F2F2);
const Color peach = Color(0xFFFEA57D);
const Color beige = Color(0xFFF7ECE2);
const Color white100 = Color(0xFFFFFFFF);

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String _username = '';
  String _description = '';
  String _userImage = '';
  List<Album> _favoriteAlbums = [];
  bool _isLoading = true;
  bool _isFirstLoad = true;
  String _selectedOption = 'Jambles';
  bool _hasSpotifyId = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _loadUserInfo();
      _isFirstLoad = false;
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final username = await _secureStorage.read(key: 'user_username');
      final description = await _secureStorage.read(key: 'user_small_description');
      final userImage = await _secureStorage.read(key: 'user_image');
      final spotifyId = await _secureStorage.read(key: 'user_spotify_id');

      // Check if Spotify ID exists and is not empty
      _hasSpotifyId = spotifyId != null && spotifyId.isNotEmpty;

      List<Album> albumList = [];
      try {
        albumList = await FavouriteAlbumsService().getFavoriteAlbums();
      } catch (e) {
        _showNotificationBanner("Error loading albums: ${e.toString()}", Colors.red);
      }

      setState(() {
        _username = '@' + (username ?? 'username');
        _description = description ?? '';
        _userImage = userImage ?? '';
        _favoriteAlbums = albumList.where((album) => album.id != 'empty').toList();
        _isLoading = false;
      });
    } catch (e) {
      _showNotificationBanner("Error loading profile: ${e.toString()}", Colors.red);
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      backgroundColor: beige,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top padding for separation from content above
              SizedBox(height: 80),

              // Profile section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: beige,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Image
                    _buildProfileImage(),
                    
                    // Username
                    SizedBox(height: 16),
                    Text(
                      _username,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: darkRed,
                      ),
                    ),

                    // Description (Subtitle)
                    if (_description.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        _description,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: darkRed.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Favorite Albums Row
                    SizedBox(height: 20),
                    if (_favoriteAlbums.isNotEmpty)
                      _buildFavoriteAlbumsRow(),

                    // Edit Profile Button
                    SizedBox(height: 24),
                    _buildEditProfileButton(),

                    // Toggle for "Jambles" and "On Repeat"
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOptionButton("Jambles"),
                        if (_hasSpotifyId) ...[
                          SizedBox(width: 20),
                          _buildOptionButton("On Repeat"),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Conditional rendering based on selected option
              if (_selectedOption == "On Repeat" && _hasSpotifyId) ...[
                SizedBox(height: 0),
                TopArtistsComponent(),
                SizedBox(height: 0), // Reduced spacing between artists and songs
                TopSongsComponent(),
              ],

              SizedBox(height: 40), // Bottom padding for visual breathing room
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        // Navigate to image selection modal or add edit logic
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
          image: _userImage.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(_userImage),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _userImage.isEmpty
            ? Icon(
                CupertinoIcons.person_solid,
                color: darkRed.withOpacity(0.3),
                size: 50,
              )
            : null,
      ),
    );
  }

  Widget _buildFavoriteAlbumsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _favoriteAlbums.map((album) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.13,
            height: MediaQuery.of(context).size.width * 0.13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: album.imageUrl.isNotEmpty
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 100),
      child: Container(
        decoration: BoxDecoration(
          color: peach,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: peach.withOpacity(0.8),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: CupertinoButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/edit-profile');
          },
          padding: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: white100,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          color: null,
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    bool isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? darkRed : darkRed.withOpacity(0.7),
            ),
            child: Text(option),
          ),
          SizedBox(height: 4),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 4,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              color: peach,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
