import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/search.dart'; // Search service
import '../services/post.dart'; // Post service

class FavouriteItemModal extends StatefulWidget {
  final Function(dynamic) onItemSelected; // Callback for when an item is selected
  final List<dynamic> favouriteItems; // List of favourite items

  FavouriteItemModal({
    required this.onItemSelected,
    required this.favouriteItems,
  });

  @override
  _FavouriteItemModalState createState() => _FavouriteItemModalState();
}

class _FavouriteItemModalState extends State<FavouriteItemModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jambleController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  List<Album> _albums = [];
  List<Artist> _artists = [];
  List<Song> _songs = [];
  Timer? _debounce;
  bool _isSearching = false;
  final PostService _postService = PostService();
  final FavouriteAlbumsService _itemService = FavouriteAlbumsService();

  dynamic _selectedItem; // Holds the selected item
  String? _selectedType; // Holds the type of the selected item
  String? _selectedReferenceId; // Holds the reference ID of the selected item

  static const Color darkRed = Color(0xFF3E111B);
  static const Color peach = Color(0xFFFEA57D);
  static const Color white100 = Color(0xFFFFFFFF);
  static const Color selectedColor = Color(0x0A3E111B); // Lower opacity for selected color

  bool isJambleButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _jambleController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchItems(_searchController.text);
      }
    });
  }

  Future<void> _searchItems(String query) async {
    setState(() {
      _isSearching = true;
      _albums = [];
      _artists = [];
      _songs = [];
    });
    try {
      final results = await _itemService.searchSpotify(query);
      setState(() {
        _albums = results['albums'] as List<Album>;
        _artists = results['artists'] as List<Artist>;
        _songs = results['songs'] as List<Song>;
        _isSearching = false;
      });
    } catch (error) {
      setState(() {
        _isSearching = false;
      });
      _showErrorDialog("Error during search: $error");
    }
  }

  void _onItemSelected(dynamic item) {
    // Store the selected item
    if (item is Album) {
      _selectedItem = item;
      _selectedType = "album";
      _selectedReferenceId = item.id;
    } else if (item is Artist) {
      _selectedItem = item;
      _selectedType = "artist";
      _selectedReferenceId = item.id;
    } else if (item is Song) {
      _selectedItem = item;
      _selectedType = "song";
      _selectedReferenceId = item.id;
    } else {
      _showErrorDialog("Error: Unknown item type");
      return;
    }

    setState(() {
      // Trigger UI update
    });
  }

  Future<void> _onJambleButtonPressed() async {
    String content = _jambleController.text.trim(); // Ensure content is trimmed

    // Validate input
    if (_selectedItem == null || _selectedType == null || _selectedReferenceId == null) {
      _showErrorDialog("Error: You must select a song, album, or artist.");
      return;
    }

    if (content.isEmpty) {
      _showErrorDialog("Error: Content field cannot be empty. Please write your jamble!");
      return;
    }

    try {
      print("Content: $content");
      print("Type: $_selectedType");
      print("Reference ID: $_selectedReferenceId");

      // Send the data to the backend
      final success = await _postService.createPost(
        content: content,
        type: _selectedType!,
        referenceId: _selectedReferenceId!,
      );

      if (success) {
        _showSuccessDialog("Successfully sent to the backend!");
        Navigator.pop(context); // Close the modal
      } else {
        throw Exception("Failed to send data to backend");
      }
    } catch (e) {
      _showErrorDialog("Error creating post: $e");
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(dynamic item) {
    String title, subtitle, imageUrl;

    if (item is Album) {
      title = item.name;
      subtitle = item.artist;
      imageUrl = (item.imageUrl.isNotEmpty) ? item.imageUrl : 'https://via.placeholder.com/50';
    } else if (item is Artist) {
      title = item.name;
      subtitle = "Artist";
      imageUrl = item.imageUrls.isNotEmpty ? item.imageUrls.first : 'https://via.placeholder.com/50';
    } else if (item is Song) {
      title = item.name;
      subtitle = '${item.artist} - ${item.albumName}';
      imageUrl = (item.imageUrl.isNotEmpty) ? item.imageUrl : 'https://via.placeholder.com/50';
    } else {
      title = "Unknown";
      subtitle = "Unknown";
      imageUrl = 'https://via.placeholder.com/50';
    }

    bool isSelected = _selectedItem == item; // Check if the item is selected

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Less vertical padding
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onItemSelected(item),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted padding
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent, // Change background color if selected
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://via.placeholder.com/50',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: darkRed,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: darkRed.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: white100,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/flower.svg',
              height: 50,
              width: 50,
            ),
            SizedBox(height: 10),
            Text(
              "Choose a Song, Album or Artist to associate",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: darkRed,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            CupertinoSearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              placeholder: 'Search',
              placeholderStyle: TextStyle(
                color: darkRed.withOpacity(0.5),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              style: TextStyle(
                color: darkRed,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: BoxDecoration(
                color: white100,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(height: 10),
            _isSearching
                ? CupertinoActivityIndicator()
                : (_albums.isNotEmpty || _artists.isNotEmpty || _songs.isNotEmpty)
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ..._albums.map((album) => _buildResultItem(album)),
                            ..._artists.map((artist) => _buildResultItem(artist)),
                            ..._songs.map((song) => _buildResultItem(song)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "No results found.",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: darkRed.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _jambleController,
              minLines: 1,
              maxLines: null,
              placeholder: 'Write your jamble!',
              placeholderStyle: TextStyle(
                color: darkRed.withOpacity(0.5),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              style: TextStyle(
                color: darkRed,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFF2F2F2)),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              textAlignVertical: TextAlignVertical.top,
            ),
            SizedBox(height: 20),            GestureDetector(
              onTapDown: (_) => setState(() => isJambleButtonPressed = true),
              onTapUp: (_) => setState(() => isJambleButtonPressed = false),
              onTapCancel: () => setState(() => isJambleButtonPressed = false),
              onTap: _onJambleButtonPressed, // Trigger Jamble logic
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isJambleButtonPressed ? peach.withOpacity(0.8) : peach,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: peach.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    "Jamble",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white100,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
