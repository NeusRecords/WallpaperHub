import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import '../data/database_helper.dart';
import '../models/wallpaper_model.dart';

class ImageView extends StatefulWidget {
  final String imgUrl;
  final WallpaperModel? wallpaperModel;
  const ImageView({super.key, required this.imgUrl, this.wallpaperModel});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool isFavorite = false;
  double blurValue = 0.0;
  double brightnessValue = 1.0;
  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void _checkFavorite() async {
    if (widget.wallpaperModel != null) {
      isFavorite = await DatabaseHelper.instance.isFavorite(widget.wallpaperModel!.photographerId);
      setState(() {});
    }
  }

  void _toggleFavorite() async {
    if (widget.wallpaperModel == null) return;

    if (isFavorite) {
      await DatabaseHelper.instance.delete(widget.wallpaperModel!.photographerId);
    } else {
      await DatabaseHelper.instance.insert(widget.wallpaperModel!);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFavorite ? "Added to favorites" : "Removed from favorites"))
    );
  }

  _shareImage() {
    Share.share("Check out this amazing wallpaper from WallpaperHub: ${widget.imgUrl}");
  }

  _save() async {
    if (kIsWeb) {
      // On web, we could potentially open the URL in a new tab or trigger a download, 
      // but for now let's just show a message.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download available on mobile app")));
      return;
    }
    if (io.Platform.isAndroid) await _askPermission();

    var response = await Dio().get(widget.imgUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(response.data));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image saved to gallery!")));
    }
  }

  _askPermission() async {
    if (await Permission.storage.request().isGranted) {} else { await Permission.storage.request(); }
  }

  _setWallpaper(int location) async {
    if (kIsWeb) return;
    var response = await Dio().get(widget.imgUrl, options: Options(responseType: ResponseType.bytes));
    final appDir = await getTemporaryDirectory();
    final file = io.File('${appDir.path}/wallpaper.jpg');
    await file.writeAsBytes(response.data);

    try {
      await WallpaperManagerFlutter().setWallpaper(
        file,
        location == 1 ? WallpaperManagerFlutter.homeScreen : location == 2 ? WallpaperManagerFlutter.lockScreen : WallpaperManagerFlutter.bothScreens,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallpaper set successfully!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error setting wallpaper")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Filters
          Hero(
            tag: widget.imgUrl,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  brightnessValue, 0, 0, 0, 0,
                  0, brightnessValue, 0, 0, 0,
                  0, 0, brightnessValue, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl: widget.imgUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Top Header (Back, Share, Favorite)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                Row(
                  children: [
                    _circularButton(Icons.share_outlined, _shareImage),
                    const SizedBox(width: 12),
                    _circularButton(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      _toggleFavorite,
                      color: isFavorite ? Colors.redAccent : Colors.white
                    ),
                  ],
                )
              ],
            ),
          ),

          // Bottom Actions
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showFilters) _buildFilterPanel(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Filter Toggle
                      _actionButton(Icons.tune, "Edit", () => setState(() => showFilters = !showFilters)),
                      const SizedBox(width: 16),
                      // Main Set Action
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            _save();
                          } else if (io.Platform.isAndroid) {
                            _showWallpaperOptions();
                          } else {
                            _save();
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 55,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: Text("Set Wallpaper", 
                                style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _actionButton(Icons.download, "Save", _save),
                    ],
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _circularButton(IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _filterRow("Blur", blurValue, 0, 10, (val) => setState(() => blurValue = val)),
          const SizedBox(height: 16),
          _filterRow("Brightness", brightnessValue, 0.5, 1.5, (val) => setState(() => brightnessValue = val)),
        ],
      ),
    );
  }

  Widget _filterRow(String label, double value, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.blueAccent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              ListTile(leading: const Icon(Icons.home, color: Colors.blueAccent), title: const Text("Home Screen"), onTap: () { Navigator.pop(context); _setWallpaper(1); }),
              ListTile(leading: const Icon(Icons.lock, color: Colors.blueAccent), title: const Text("Lock Screen"), onTap: () { Navigator.pop(context); _setWallpaper(2); }),
              ListTile(leading: const Icon(Icons.devices, color: Colors.blueAccent), title: const Text("Both Screens"), onTap: () { Navigator.pop(context); _setWallpaper(3); }),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}
