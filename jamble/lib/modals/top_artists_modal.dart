import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/services/user_spotify_data.dart';

class TopArtistsPopup extends StatelessWidget {
  final List<Artist> artists;

  TopArtistsPopup({required this.artists});

  static const Color darkRed = Color(0xFF3E111B);
  static const Color peach = Color(0xFFFEA57D);
  static const Color grey = Color(0xFFF2F2F2);
  static const Color white100 = Color(0xFFFFFFFF);

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
            "Top Artists",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: darkRed,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "In the Last 4 Weeks",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: darkRed.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: darkRed,
                          ),
                        ),
                        SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: artist.imageUrls.isNotEmpty
                              ? Image.network(
                                  artist.imageUrls.first,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  color: grey,
                                ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            artist.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: darkRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}