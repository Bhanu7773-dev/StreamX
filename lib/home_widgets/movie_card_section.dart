import 'package:flutter/material.dart';
// import 'dart:math' as math; // not used
import 'dart:async';
import 'dart:ui' as ui;

// Default sample movies for the carousel (moved from homepage)
final List<Map<String, dynamic>> _defaultSampleMovies = [
  {
    'title': 'Tron: Ares',
    'year': '2025',
    'genre': 'Cyberpunk',
    'duration': '1h 58min',
    'rating': 7.5,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/wVYREutTvI2tmxr6ujrHT704wGF.jpg',
  },
  {
    'title': 'Inception',
    'year': '2010',
    'genre': 'Sci-Fi',
    'duration': '2h 28min',
    'rating': 8.8,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
  },
  {
    'title': 'Spirited Away',
    'year': '2001',
    'genre': 'Fantasy',
    'duration': '2h 5min',
    'rating': 8.6,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
  },
  {
    'title': 'The Dark Knight',
    'year': '2008',
    'genre': 'Action',
    'duration': '2h 32min',
    'rating': 9.0,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
  },
  {
    'title': 'Interstellar',
    'year': '2014',
    'genre': 'Sci-Fi',
    'duration': '2h 49min',
    'rating': 8.7,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
  },
  {
    'title': 'Parasite',
    'year': '2019',
    'genre': 'Thriller',
    'duration': '2h 12min',
    'rating': 8.5,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
  },
];

class MovieCard extends StatelessWidget {
  final String title;
  final String year;
  final String genre;
  final String duration;
  final double rating;
  final String imageUrl;
  final bool isCenter;
  final double scale;
  final double rotation;
  final double opacity;

  const MovieCard({
    Key? key,
    required this.title,
    required this.year,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.imageUrl,
    this.isCenter = false,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: Transform.scale(
        scale: scale,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation),
          child: Container(
            width: 220,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isCenter ? 0.4 : 0.2),
                  blurRadius: isCenter ? 20 : 10,
                  offset: Offset(0, isCenter ? 10 : 5),
                  spreadRadius: isCenter ? 5 : 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Movie poster
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[800]!, Colors.grey[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.movie,
                          size: 60,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Rating badge (frosted glass)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Movie details
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              year,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTag(genre, Icons.category),
                                const SizedBox(width: 8),
                                _buildTag(duration, Icons.access_time),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularMovieCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> movies;

  CircularMovieCarousel({Key? key, List<Map<String, dynamic>>? movies})
    : movies = movies ?? _defaultSampleMovies,
      super(key: key);

  @override
  State<CircularMovieCarousel> createState() => _CircularMovieCarouselState();
}

class _CircularMovieCarouselState extends State<CircularMovieCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  int _currentIndex = 0;
  double _pageOffset = 0.0;
  bool _isAnimating = false;

  // Large number to simulate infinite scrolling
  static const int _infiniteMultiplier = 10000;
  late int _initialPage;

  @override
  void initState() {
    super.initState();

    // Start from the middle of our "infinite" list
    _initialPage = _infiniteMultiplier * widget.movies.length;
    _currentIndex = 0;

    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.6,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pageController.addListener(() {
      // Always update page offset so stacked cards follow the PageView
      final p = _pageController.page ?? _initialPage.toDouble();
      if (mounted) {
        setState(() {
          _pageOffset = p;
          _currentIndex = (p.round()) % widget.movies.length;
        });
      }
    });

    // Start auto-scroll after first frame so PageController is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      if (_isAnimating) return;

      final currentPage = (_pageController.page ?? _initialPage.toDouble())
          .round();
      final nextPage = currentPage + 1;
      _isAnimating = true;
      _pageController
          .animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .whenComplete(() {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                setState(() {
                  _isAnimating = false;
                });
              }
            });
          });
    });
  }

  // Pause auto-scroll and resume after 2 seconds
  void _pauseAutoScrollTemporarily() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _startAutoScroll();
    });
  }

  // Get the actual movie index from the infinite scroll position
  int _getMovieIndex(int pageIndex) {
    return pageIndex % widget.movies.length;
  }

  // Get visible indices around current position
  List<int> _getVisibleIndices() {
    int currentPage = _pageOffset.round();
    List<int> indices = [];

    // Show 5 cards (2 before, center, 2 after)
    for (int i = currentPage - 2; i <= currentPage + 2; i++) {
      indices.add(i);
    }

    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final visibleIndices = _getVisibleIndices();

    // Sort indices by distance from _pageOffset for proper z-ordering
    visibleIndices.sort((a, b) {
      final da = (a - _pageOffset).abs();
      final db = (b - _pageOffset).abs();
      return db.compareTo(da); // farthest first, closest last
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => _pauseAutoScrollTemporarily(),
          onTapUp: (_) => _pauseAutoScrollTemporarily(),
          onTapCancel: () => _pauseAutoScrollTemporarily(),
          child: NotificationListener<ScrollStartNotification>(
            onNotification: (notification) {
              _pauseAutoScrollTemporarily();
              return false;
            },
            child: SizedBox(
              height: 375,
              child: Stack(
                children: [
                  // Stack cards so the center card is always on top
                  ...visibleIndices.map((index) => _buildStackedCard(index)),

                  // Main PageView with infinite scrolling
                  PageView.builder(
                    controller: _pageController,
                    itemCount: null, // null for infinite scrolling
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = _getMovieIndex(index);
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(); // Transparent container for PageView
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (i) {
            final isActive = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isActive ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.redAccent : Colors.grey[600],
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStackedCard(int pageIndex) {
    final movieIndex = _getMovieIndex(pageIndex);
    final movie = widget.movies[movieIndex];
    final difference = (pageIndex - _pageOffset).abs();
    final isCenter = difference < 0.5;

    // Don't render cards that are too far away
    if (difference > 2.5) return const SizedBox.shrink();

    // Smoother calculations with easing
    double scale = isCenter
        ? 1.0
        : (0.85 - (difference * 0.08)).clamp(0.6, 0.85);

    // All cards fully opaque
    double opacity = 1.0;

    // Smoother rotation
    double rotation = isCenter ? 0.0 : (pageIndex - _pageOffset) * 0.2;

    // Smoother horizontal offset
    double horizontalOffset = 0.0;
    if (!isCenter) {
      horizontalOffset = (pageIndex - _pageOffset) * 80;
      horizontalOffset = horizontalOffset.clamp(-120.0, 120.0);
    }

    // Smoother vertical offset
    double verticalOffset = isCenter ? 0.0 : 15 + (difference * 8);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Positioned(
          left:
              MediaQuery.of(context).size.width * 0.5 -
              110 +
              (horizontalOffset * value),
          top: 40 + (verticalOffset * value),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: GestureDetector(
              onTap: () {
                if (!isCenter && !_isAnimating) {
                  _pageController.animateToPage(
                    pageIndex,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              child: MovieCard(
                title: movie['title'],
                year: movie['year'],
                genre: movie['genre'],
                duration: movie['duration'],
                rating: movie['rating'],
                imageUrl: movie['imageUrl'],
                isCenter: isCenter,
                scale: scale,
                rotation: rotation,
                opacity: 1.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
