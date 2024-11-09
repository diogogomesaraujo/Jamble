import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/post.dart';
import '../services/post_spotify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({required this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final SpotifyService _spotifyService = SpotifyService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String _referenceInfo = "";
  String _username = "";
  String _userImage = "";
  bool _isLoading = true;

  static const Color darkRed = Color(0xFF3E111B);
  static const Color dividerColor = Color(0xFFD9D9D9); // Subtle line color

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchReferenceInfo();
  }

  Future<void> _fetchUserData() async {
    try {
      String? username = await _storage.read(key: "user_username");
      String? userImage = await _storage.read(key: "user_image");

      setState(() {
        _username = username ?? "Unknown";
        _userImage = userImage ?? "";
      });
    } catch (error) {
      setState(() {
        _username = "Unknown";
        _userImage = "";
      });
    }
  }

  Future<void> _fetchReferenceInfo() async {
    try {
      String referenceInfo = "";

      if (widget.post.type == "artist") {
        final artist = await _spotifyService.getArtistById(widget.post.referenceId);
        referenceInfo = artist["name"];
      } else if (widget.post.type == "album") {
        final album = await _spotifyService.getAlbumById(widget.post.referenceId);
        final artistNames = (album["artists"] as List)
            .map((artist) => artist["name"])
            .join(", ");
        referenceInfo = "${album["name"]}, $artistNames";
      } else if (widget.post.type == "song") {
        final song = await _spotifyService.getSongById(widget.post.referenceId);
        final artistNames = (song["artists"] as List)
            .map((artist) => artist["name"])
            .join(", ");
        referenceInfo = "${song["name"]}, $artistNames";
      }

      setState(() {
        _referenceInfo = referenceInfo;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _referenceInfo = "Error fetching data";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Image
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _userImage.isNotEmpty
                        ? NetworkImage(_userImage)
                        : NetworkImage(
                            'https://via.placeholder.com/150?text=User',
                          ),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        Text(
                          "@$_username",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: darkRed,
                          ),
                        ),
                        // Reference Information
                        _isLoading
                            ? const CupertinoActivityIndicator()
                            : Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  _referenceInfo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: darkRed.withOpacity(0.9),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Post Content
              Text(
                widget.post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18, // Increased font size
                  color: darkRed.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        // Subtle divisory line
        Divider(
          color: darkRed.withOpacity(0.1),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}
