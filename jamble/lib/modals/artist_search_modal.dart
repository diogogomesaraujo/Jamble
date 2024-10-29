import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/artist_image.dart';

class ArtistSearchModal extends StatefulWidget {
  final Function(String?) onArtistSelected; // Callback for artist image selection
  final String? initialArtistImageUrl;

  ArtistSearchModal({
    required this.onArtistSelected,
    this.initialArtistImageUrl,
  });

  @override
  _ArtistSearchModalState createState() => _ArtistSearchModalState();
}

class _ArtistSearchModalState extends State<ArtistSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Artist> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;
  final FavouriteArtistsService _artistService = FavouriteArtistsService();
  bool isAddImageButtonPressed = false;

  static const Color darkRed = Color(0xFF3E111B);
  static const Color peach = Color(0xFFFEA57D);
  static const Color grey = Color(0xFFF2F2F2);
  static const Color white100 = Color(0xFFFFFFFF);

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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchArtists(_searchController.text);
      }
    });
  }

  Future<void> _searchArtists(String query) async {
    setState(() {
      _isSearching = true;
    });
    try {
      List<Artist> artists = await _artistService.searchArtists(query);
      setState(() {
        _searchResults = artists.where((artist) => artist.imageUrls.isNotEmpty).toList();
        _isSearching = false;
      });
    } catch (error) {
      setState(() {
        _isSearching = false;
      });
      print('Error: $error');
    }
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
            "Choose an Artist as your Avatar!",
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
            placeholder: 'Search artists',
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
              color: grey.withOpacity(0.1),
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
                          final currentArtist = _searchResults[index];
                          final imageUrl = currentArtist.imageUrls.isNotEmpty
                              ? currentArtist.imageUrls.first
                              : null;
                          if (imageUrl == null) return Container();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                widget.onArtistSelected(imageUrl);
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      currentArtist.name,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: darkRed,
                                        fontSize: 16,
                                      ),
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
            onTapDown: (_) => setState(() => isAddImageButtonPressed = true),
            onTapUp: (_) => setState(() => isAddImageButtonPressed = false),
            onTapCancel: () => setState(() => isAddImageButtonPressed = false),
            onTap: () {
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isAddImageButtonPressed ? peach.withOpacity(0.8) : peach,
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
                  "Confirm Selection",
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
          GestureDetector(
            onTap: () {
              widget.onArtistSelected(null);
              Navigator.pop(context);
            },
            child: Text(
              "Remove",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: darkRed.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}