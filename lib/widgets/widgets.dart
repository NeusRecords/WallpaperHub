import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';
import '../views/image_view.dart';

Widget brandName() {
  return RichText(
    text: TextSpan(
      style: GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      children: const <TextSpan>[
        TextSpan(text: 'Wallpaper', style: TextStyle(color: Colors.white)),
        TextSpan(text: 'Hub', style: TextStyle(color: Color(0xFF1A6EBF))),
      ],
    ),
  );
}

Widget wallpapersList({required List<WallpaperModel> wallpapers, required BuildContext context}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wallpapers.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageView(
                          imgUrl: wallpapers[index].src.portrait,
                          wallpaperModel: wallpapers[index],
                        )));
          },
          child: Hero(
            tag: wallpapers[index].src.portrait,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: wallpapers[index].src.portrait,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: (index % 2 == 0 ? 250 : 180),
                  color: const Color(0xFF262626),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        );
      },
    ),
  );
}
