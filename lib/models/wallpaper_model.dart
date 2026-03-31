class WallpaperModel {
  String photographer;
  String photographerUrl;
  int photographerId;
  SrcModel src;

  WallpaperModel({
    required this.photographer,
    required this.photographerId,
    required this.photographerUrl,
    required this.src,
  });

  factory WallpaperModel.fromMap(Map<String, dynamic> jsonData) {
    return WallpaperModel(
      photographer: jsonData["photographer"],
      photographerId: jsonData["photographer_id"],
      photographerUrl: jsonData["photographer_url"],
      src: SrcModel.fromMap(jsonData["src"]),
    );
  }
}

class SrcModel {
  String original;
  String small;
  String portrait;

  SrcModel({
    required this.original,
    required this.portrait,
    required this.small,
  });

  factory SrcModel.fromMap(Map<String, dynamic> jsonData) {
    return SrcModel(
      original: jsonData["original"],
      portrait: jsonData["portrait"],
      small: jsonData["small"],
    );
  }
}
