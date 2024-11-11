import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/post.dart';
import '../services/post_spotify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final VoidCallback onPostDeleted;

  const PostWidget({
    required this.post,
    required this.onPostDeleted,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final SpotifyService _spotifyService = SpotifyService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final PostService _postService = PostService();

  String _referenceInfo = "";
  String _username = "";
  String _userImage = "";
  bool _isLoading = true;

  static const Color darkRed = Color(0xFF3E111B);
  static const Color dividerColor = Color(0xFFD9D9D9);

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
    } catch (_) {
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
    } catch (_) {
      setState(() {
        _referenceInfo = "Error fetching data";
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(BuildContext context) async {
    try {
      final isDeleted = await _postService.deletePost(widget.post.id);
      if (isDeleted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Success"),
            content: Text("Post deleted successfully"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
        widget.onPostDeleted();
      }
    } catch (error) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Failed to delete post: $error"),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePost(context);
              },
              isDestructiveAction: true,
              child: const Text("Delete Post"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        );
      },
    );
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
                        : AssetImage('assets/images/default_user.png') as ImageProvider,
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
                  // Options Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.ellipsis_vertical,
                      color: darkRed,
                    ),
                    onPressed: () => _showOptions(context),
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
                  fontSize: 18,
                  color: darkRed.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        // Divider Line
        Divider(
          color: darkRed.withOpacity(0.1),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }
}
