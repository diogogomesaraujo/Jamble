import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_spotify_data.dart'; // Ensure correct path
import '../modals/top_artists_modal.dart'; // Import the popup widget

class TopArtistsComponent extends StatefulWidget {
  @override
  _TopArtistsComponentState createState() => _TopArtistsComponentState();
}

class _TopArtistsComponentState extends State<TopArtistsComponent> {
  final SpotifyService _spotifyService = SpotifyService();
  List<Artist> _topArtists = []; // For displaying the top 3 artists
  List<Artist> _allArtists = []; // For displaying all artists in the popup
  bool _isLoading = true;

  static const Color darkRed = Color(0xFF3E111B);
  static const Color peach = Color(0xFFFEA57D);

  @override
  void initState() {
    super.initState();
    _fetchTopArtists();
  }

  Future<void> _fetchTopArtists() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Artist> artists = await _spotifyService.getTopArtistsFromBackend();
      setState(() {
        _allArtists = artists; // Store all artists for the popup
        _topArtists = artists.take(3).toList(); // Display only top 3 in the widget
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching top artists: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTopArtistsPopup() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return TopArtistsPopup(artists: _allArtists); // Pass all artists to the popup
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/flower.svg',
                height: 30,
                width: 30,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Top Artists",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: darkRed,
                    ),
                  ),
                  Text(
                    "In the Last 6 Months",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: darkRed.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: _showTopArtistsPopup,
                child: Text(
                  "View All",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkRed,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _isLoading
              ? Center(child: CupertinoActivityIndicator())
              : Column(
                  children: _topArtists.asMap().entries.map((entry) {
                    int index = entry.key;
                    Artist artist = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Number Column with fixed width for consistent alignment
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: darkRed,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          // Image Column with fixed size
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: artist.imageUrls.isNotEmpty
                                ? Image.network(
                                    artist.imageUrls.first,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                  ),
                          ),
                          SizedBox(width: 15),
                          // Name Column with Expanded widget
                          Expanded(
                            child: Text(
                              artist.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: darkRed,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
