import 'package:flutter/material.dart';
import '../home_widgets/movie_card_section.dart'; // Update this import
import '../home_widgets/trending_section.dart';
import '../home_widgets/genre_section.dart';
import '../hybrrid/navbar.dart';
import '../stream_services/api.dart';

class HomePage extends StatefulWidget {
  final List<Movie> carouselMovies;
  final List<Movie> remainingMovies;
  final Map<String, List<Movie>> genreMovies;
  const HomePage({
    super.key,
    required this.carouselMovies,
    required this.remainingMovies,
    required this.genreMovies,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          _buildSearchPage(),
          _buildFavoritesPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: StreamXNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // App title
      title: const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          'StreamX',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.redAccent,
            fontWeight: FontWeight.w300,
            fontSize: 35,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.redAccent,
              size: 32,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline,
                color: Colors.redAccent,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Movie Carousel (no header)
          CircularMovieCarousel(movies: widget.carouselMovies),

          // Genre Section
          GenreSection(
            movies: widget.remainingMovies,
            genreMovies: widget.genreMovies,
          ),

          // Trending Section moved to home_widgets/trending_section.dart
          TrendingNow(movies: widget.remainingMovies),

          // Add space for navbar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // _buildTrendingCard was moved to `home_widgets/trending_section.dart`.

  Widget _buildFavoritesPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 80, color: Colors.redAccent),
          SizedBox(height: 16),
          Text(
            "Favorites",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your favorite movies will appear here",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Search Page",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Search for your favorite movies",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Settings Page",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Customize your experience",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
