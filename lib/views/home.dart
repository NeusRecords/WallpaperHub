import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import '../data/database_helper.dart';
import '../models/category_model.dart';
import '../models/wallpaper_model.dart';
import '../widgets/widgets.dart';
import '../views/search.dart';
import '../views/category.dart';
import '../views/image_view.dart';
import '../services/background_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<CategoryModel> categories = [];
  List<WallpaperModel> trendingWallpapers = [];
  List<WallpaperModel> favoriteWallpapers = [];
  List<WallpaperModel> featuredWallpapers = [];

  late TabController _tabController;
  TextEditingController searchController = TextEditingController();

  Future<void> getData() async {
    categories = getCategories();
    await getTrendingWallpapers();
    await getFeaturedWallpapers();
    await getFavorites();
  }

  Future<void> getTrendingWallpapers() async {
    var response = await http.get(
        Uri.parse("https://api.pexels.com/v1/curated?per_page=30&page=1"),
        headers: {"Authorization": apiKey});

    Map<String, dynamic> jsonData = jsonDecode(response.body);
    trendingWallpapers = [];
    jsonData["photos"].forEach((element) {
      trendingWallpapers.add(WallpaperModel.fromMap(element));
    });
    setState(() {});
  }

  Future<void> getFeaturedWallpapers() async {
    var response = await http.get(
        Uri.parse("https://api.pexels.com/v1/curated?per_page=5&page=2"),
        headers: {"Authorization": apiKey});

    Map<String, dynamic> jsonData = jsonDecode(response.body);
    featuredWallpapers = [];
    jsonData["photos"].forEach((element) {
      featuredWallpapers.add(WallpaperModel.fromMap(element));
    });
    setState(() {});
  }

  Future<void> getFavorites() async {
    favoriteWallpapers = await DatabaseHelper.instance.queryAllRows();
    setState(() {});
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: brandName(),
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: const Color(0xFF0F0F0F),
                floating: true,
                pinned: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                    onPressed: () => _showSettings(),
                  )
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Featured Horizontal Slider
                    if (featuredWallpapers.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text("Featured Daily", 
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredWallpapers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageView(
                                      imgUrl: featuredWallpapers[index].src.portrait,
                                      wallpaperModel: featuredWallpapers[index],
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'featured_${featuredWallpapers[index].src.portrait}',
                                child: Container(
                                  width: 300,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CachedNetworkImage(
                                      imageUrl: featuredWallpapers[index].src.portrait,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.white10),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Search Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                        hintText: "Search wallpapers...",
                                        hintStyle: TextStyle(color: Colors.white54),
                                        border: InputBorder.none),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.search, color: Colors.blueAccent),
                                  onPressed: () {
                                    if (searchController.text != "") {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Search(searchQuery: searchController.text)));
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.blueAccent,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    onTap: (index) {
                      if(index == 2) getFavorites();
                    },
                    tabs: const [
                      Tab(text: "Trending"),
                      Tab(text: "Explore"),
                      Tab(text: "Favorites"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Trending tab - uses its own scroll coordinated with NestedScrollView
              SingleChildScrollView(
                child: wallpapersList(wallpapers: trendingWallpapers, context: context),
              ),
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryTile(title: categories[index].categoryName!);
                }
              ),
              // Favorites tab
              favoriteWallpapers.isEmpty 
                ? const Center(child: Text("No favorites yet", style: TextStyle(color: Colors.white54)))
                : SingleChildScrollView(
                    child: wallpapersList(wallpapers: favoriteWallpapers, context: context),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentMode = prefs.getInt(BackgroundService.modeKey) ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Auto Wallpaper Changer", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  RadioListTile(
                    title: const Text("Off", style: TextStyle(color: Colors.white70)),
                    value: 0,
                    groupValue: currentMode,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) {
                      setModalState(() => currentMode = val!);
                      _updateMode(val!);
                    },
                  ),
                  RadioListTile(
                    title: const Text("Random (Every 12h)", style: TextStyle(color: Colors.white70)),
                    value: 1,
                    groupValue: currentMode,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) {
                      setModalState(() => currentMode = val!);
                      _updateMode(val!);
                    },
                  ),
                  RadioListTile(
                    title: const Text("Day/Night (6 AM/PM)", style: TextStyle(color: Colors.white70)),
                    value: 2,
                    groupValue: currentMode,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) {
                      setModalState(() => currentMode = val!);
                      _updateMode(val!);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _updateMode(int mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(BackgroundService.modeKey, mode);
    
    if (mode == 0) await BackgroundService.stopAll();
    else if (mode == 1) await BackgroundService.scheduleRandom();
    else if (mode == 2) await BackgroundService.scheduleDayNight();
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings updated!")));
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  const CategoryTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Category(categoryName: title.toLowerCase())));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
