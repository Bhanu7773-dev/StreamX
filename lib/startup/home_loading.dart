import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/homepage.dart';
import '../stream_services/api.dart';
import '../stream_services/tmdb_api.dart';

class HomeLoadingScreen extends StatefulWidget {
  const HomeLoadingScreen({Key? key}) : super(key: key);

  @override
  State<HomeLoadingScreen> createState() => _HomeLoadingScreenState();
}

class _HomeLoadingScreenState extends State<HomeLoadingScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  int _quoteIndex = 0;

  List<Movie> _carouselMovies = [];
  List<Movie> _remainingMovies = [];
  Map<String, List<Movie>> _genreMovies = {};

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;

  final List<Map<String, String>> _loadingSteps = [
    {
      'title': 'Initializing StreamX',
      'subtitle': 'Setting up your entertainment hub...',
      'icon': 'rocket_launch',
    },
    {
      'title': 'Fetching Latest Content',
      'subtitle': 'Loading movies and shows...',
      'icon': 'download',
    },
    {
      'title': 'Personalizing Experience',
      'subtitle': 'Preparing recommendations...',
      'icon': 'tune',
    },
    {
      'title': 'Building Your Feed',
      'subtitle': 'Organizing trending content...',
      'icon': 'auto_awesome',
    },
    {
      'title': 'Almost Ready!',
      'subtitle': 'Finalizing your homepage...',
      'icon': 'check_circle',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticInOut),
    );
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
    _scaleController.forward();
    _shimmerController.repeat();

    // Start fetching data
    _fetchData();
  }

  Future<void> _animateProgress(double newProgress) async {
    const int steps = 20;
    const int durationMs = 1000;
    const int stepDuration = durationMs ~/ steps;
    double current = _progress;
    double step = (newProgress - current) / steps;
    for (int i = 0; i < steps; i++) {
      current += step;
      setState(() {
        _progress = current;
      });
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
    setState(() {
      _progress = newProgress;
    });
  }

  Future<void> _fetchData() async {
    try {
      // Step 1: Fetch trending movies
      await _animateProgress(0.2);
      setState(() => _quoteIndex = 1);
      final allMovies = await StreamApiService().fetchTrending();
      await _animateProgress(0.5);
      setState(() => _quoteIndex = 2);

      // Shuffle and split
      final shuffled = allMovies.toList()..shuffle();
      _carouselMovies = shuffled.take(5).toList();
      _remainingMovies = shuffled.skip(5).toList();

      await _animateProgress(0.8);
      setState(() => _quoteIndex = 3);

      // Step 3: Fetch genre movies
      await _fetchGenreMovies();
      await _animateProgress(1.0);
      setState(() => _quoteIndex = 4);

      // Stop shimmer animation
      _shimmerController.stop();

      // Stop animations
      _pulseController.stop();

      // Navigate after completion
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomePage(
                carouselMovies: _carouselMovies,
                remainingMovies: _remainingMovies,
                genreMovies: _genreMovies,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    } catch (e) {
      // On error, still navigate with empty lists or show error
      _animateProgress(1.0);
      setState(() => _quoteIndex = 4);
      _pulseController.stop();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomePage(
                carouselMovies: [],
                remainingMovies: [],
                genreMovies: {},
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      });
    }
  }

  Future<void> _fetchGenreMovies() async {
    final genres = [
      'Action',
      'Comedy',
      'Drama',
      'Horror',
      'Romance',
      'Thriller',
      'Sci-Fi',
    ];
    final genreIds = {
      'Action': 28,
      'Comedy': 35,
      'Drama': 18,
      'Horror': 27,
      'Romance': 10749,
      'Thriller': 53,
      'Sci-Fi': 878,
    };

    for (final genre in genres) {
      final genreId = genreIds[genre];
      if (genreId != null) {
        try {
          final tmdbMovies = await TMDBApiService().fetchMoviesByGenre(genreId);
          _genreMovies[genre] = tmdbMovies
              .take(20)
              .map(
                (m) => Movie(
                  id: m['id'].toString(),
                  title: m['title'] ?? 'Unknown',
                  url: '',
                  image:
                      'https://image.tmdb.org/t/p/w500${m['poster_path'] ?? ''}',
                  releaseDate: m['release_date'] ?? 'Unknown',
                  duration: '120 min',
                  type: genre,
                ),
              )
              .toList();
        } catch (e) {
          // On error, use empty list for this genre
          _genreMovies[genre] = [];
        }
      }
    }

    // Also fetch popular movies for 'ALL'
    try {
      final tmdbMovies = await TMDBApiService().fetchPopularMovies();
      _genreMovies['ALL'] = tmdbMovies
          .take(20)
          .map(
            (m) => Movie(
              id: m['id'].toString(),
              title: m['title'] ?? 'Unknown',
              url: '',
              image: 'https://image.tmdb.org/t/p/w500${m['poster_path'] ?? ''}',
              releaseDate: m['release_date'] ?? 'Unknown',
              duration: '120 min',
              type: m['genre_ids']?.isNotEmpty == true
                  ? _getGenreName(m['genre_ids'][0])
                  : 'Unknown',
            ),
          )
          .toList();
    } catch (e) {
      _genreMovies['ALL'] = [];
    }
  }

  String _getGenreName(int id) {
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return genreMap[id] ?? 'Unknown';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'download':
        return Icons.download;
      case 'tune':
        return Icons.tune;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'check_circle':
        return Icons.check_circle;
      default:
        return Icons.movie_creation_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _loadingSteps[_quoteIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo/Icon Section with enhanced design
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.red.withOpacity(
                                      _pulseAnimation.value * 0.2,
                                    ),
                                    Colors.red.withOpacity(
                                      _pulseAnimation.value * 0.1,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Main circle
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(
                                  color: Colors.red.withOpacity(
                                    _pulseAnimation.value * 0.8,
                                  ),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(
                                      _pulseAnimation.value * 0.3,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  size: 60,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name with enhanced styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'StreamX',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..shader =
                              const LinearGradient(
                                colors: [Colors.red, Color(0xFFB71C1C)],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 80.0),
                              ),
                        letterSpacing: 3.0,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 3,
                      width: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.red,
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Entertainment Universe',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Enhanced Progress Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Step Icon and Info - NO SPINNING
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Row(
                            children: [
                              // Static icon with bounce animation only
                              AnimatedBuilder(
                                animation: _bounceAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 +
                                        (_bounceAnimation.value *
                                            0.1), // Subtle scale effect
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getIconFromString(
                                            currentStep['icon']!,
                                          ),
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentStep['title']!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentStep['subtitle']!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Enhanced Progress Bar Section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Loading Progress',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress Bar with enhanced styling
                        Container(
                          width: double.infinity,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red.withOpacity(
                                          _progress < 1.0
                                              ? _pulseAnimation.value
                                              : 1.0,
                                        ),
                                      ),
                                    ),
                                    // Shimmer effect
                                    if (_progress < 1.0)
                                      AnimatedBuilder(
                                        animation: _shimmerAnimation,
                                        builder: (context, child) {
                                          return Positioned(
                                            left:
                                                (_shimmerAnimation.value *
                                                    _progress *
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.6) -
                                                50,
                                            child: Container(
                                              width: 50,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white.withOpacity(
                                                      0.5,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Progress Steps Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_loadingSteps.length, (
                            index,
                          ) {
                            bool isCompleted = index < _quoteIndex;
                            bool isCurrent = index == _quoteIndex;

                            return Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.red
                                    : isCurrent
                                    ? Colors.red.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.3),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.red
                                      : Colors.white.withOpacity(0.2),
                                  width: isCurrent ? 2 : 1,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Enhanced Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'Powered by StreamX Engine',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
