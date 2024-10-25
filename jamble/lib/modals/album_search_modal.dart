import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/favourite_albums.dart'; // Your service for searching albums

class AlbumSearchModal extends StatefulWidget {
  final Function(Album) onAlbumSelected; // Callback for when an album is selected
  final List<Album> favouriteAlbums; // List of favourite albums

  AlbumSearchModal({
    required this.onAlbumSelected,
    required this.favouriteAlbums,
  });

  @override
  _AlbumSearchModalState createState() => _AlbumSearchModalState();
}

class _AlbumSearchModalState extends State<AlbumSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  List<Album> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;
  final FavouriteAlbumsService _albumService = FavouriteAlbumsService();

  static const Color darkRed = Color(0xFF3E111B);
  static const Color peach = Color(0xFFFEA57D);
  static const Color white100 = Color(0xFFFFFFFF);

  bool isAddAlbumButtonPressed = false;

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
    _searchFocusNode.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchAlbums(_searchController.text);
      }
    });
  }

  Future<void> _searchAlbums(String query) async {
    setState(() {
      _isSearching = true;
    });
    try {
      List<Album> albums = await _albumService.searchAlbums(query);
      setState(() {
        _searchResults = albums;
        _isSearching = false;
      });
    } catch (error) {
      setState(() {
        _isSearching = false;
      });
      print('Error: $error');
    }
  }

  void _onAddAlbumButtonPressed(bool isPressed) {
    setState(() {
      isAddAlbumButtonPressed = isPressed;
    });
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
            "Choose an Album to add to your favourites!",
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
            placeholder: 'Search albums',
            placeholderStyle: TextStyle(
              color: darkRed.withOpacity(0.5),
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
            style: TextStyle(
              color: darkRed,
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
            decoration: BoxDecoration(
              color: white100,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(height: 10),
          _isSearching
              ? CupertinoActivityIndicator()
              : _searchResults.isNotEmpty
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final currentAlbum = _searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                widget.onAlbumSelected(currentAlbum);
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      currentAlbum.imageUrl.isNotEmpty
                                          ? currentAlbum.imageUrl
                                          : 'default_image_url', // Handle missing image
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentAlbum.name,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: darkRed,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          currentAlbum.artist,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: darkRed.withOpacity(0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
          SizedBox(height: 20),
          GestureDetector(
            onTapDown: (_) => _onAddAlbumButtonPressed(true),
            onTapUp: (_) => _onAddAlbumButtonPressed(false),
            onTapCancel: () => _onAddAlbumButtonPressed(false),
            onTap: () {
              Navigator.pop(context); // Close modal on album addition
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isAddAlbumButtonPressed ? peach.withOpacity(0.8) : peach,
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
                  "Add Album",
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
        ],
      ),
    );
  }
}
