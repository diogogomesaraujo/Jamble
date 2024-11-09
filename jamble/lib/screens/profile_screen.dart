import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:frontend/services/post.dart';
import 'package:frontend/services/favourite_albums.dart';
import 'package:frontend/widgets/post_widget.dart';
import 'package:frontend/widgets/top_artists_widget.dart';
import 'package:frontend/widgets/top_songs_widget.dart';
import 'package:frontend/modals/post_modal.dart'; // Ensure correct import

// Define color constants
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
  final PostService _postService = PostService();
  String _username = '';
  String _description = '';
  String _userImage = '';
  List<Album> _favoriteAlbums = [];
  List<Post> _posts = [];
  bool _isLoading = true;
  String _selectedOption = 'Jambles';
  bool _hasSpotifyId = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final username = await _secureStorage.read(key: 'user_username');
      final description = await _secureStorage.read(key: 'user_small_description');
      final userImage = await _secureStorage.read(key: 'user_image');
      final spotifyId = await _secureStorage.read(key: 'user_spotify_id');

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

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final postList = await _postService.getPosts();
      setState(() {
        _posts = postList;
        _isLoading = false;
      });
    } catch (e) {
      _showNotificationBanner("Error loading posts: ${e.toString()}", Colors.red);
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
    return CupertinoPageScaffold(
      backgroundColor: beige,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80),
                    _buildProfileHeader(),
                    _buildOptionSelector(),
                    if (_selectedOption == "Jambles") _buildPostsContent(),
                    if (_selectedOption == "On Repeat" && _hasSpotifyId)
                      _buildSpotifyContent(),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedOption == "Jambles") _buildAddPostButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
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
          _buildProfileImage(),
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
          if (_favoriteAlbums.isNotEmpty) ...[
            SizedBox(height: 20),
            _buildFavoriteAlbumsRow(),
          ],
          SizedBox(height: 24),
          _buildEditProfileButton(),
        ],
      ),
    );
  }

  Widget _buildOptionSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionButton("Jambles"),
        if (_hasSpotifyId) ...[
          SizedBox(width: 20),
          _buildOptionButton("On Repeat"),
        ],
      ],
    );
  }

  Widget _buildPostsContent() {
    return _isLoading
        ? Center(child: CupertinoActivityIndicator())
        : _buildPostsList();
  }

  Widget _buildSpotifyContent() {
    return Column(
      children: [
        TopArtistsComponent(),
        TopSongsComponent(),
      ],
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostWidget(
          post: _posts[index],
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: () {
        // Logic for editing profile image
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
        if (_selectedOption == "Jambles") {
          _loadPosts();
        }
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

  Widget _buildAddPostButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: _showPostModal,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: darkRed,
            shape: BoxShape.circle,
          ),
          child: Icon(EvaIcons.plus, color: white100, size: 30),
        ),
      ),
    );
  }

  void _showPostModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return FavouriteItemModal(
          onItemSelected: (item) {
            setState(() {
              if (item != null) {
                _posts.insert(0, item as Post);
              }
            });
          },
          favouriteItems: _favoriteAlbums,
        );
      },
    );
  }
}
