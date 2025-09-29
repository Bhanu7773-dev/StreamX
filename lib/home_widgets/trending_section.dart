import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import '../stream_services/api.dart';
import '../stream_services/tmdb_api.dart';
import '../screens/movie_play_page.dart';

class TrendingNow extends StatefulWidget {
  final List<Movie>? movies;
  const TrendingNow({Key? key, this.movies}) : super(key: key);

  @override
  State<TrendingNow> createState() => _TrendingNowState();
}

class _TrendingNowState extends State<TrendingNow> {
  List<Movie> _trendingMovies = [];
  bool _loading = true;
  String? _error;

  // Cache for TMDB ratings by movie title
  Map<String, double> _ratingCache = {};

  @override
  void initState() {
    super.initState();
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    if (widget.movies != null) {
      setState(() {
        _trendingMovies = widget.movies!;
        _loading = false;
        _error = null;
      });
    } else {
      try {
        final movies = await StreamApiService().fetchTrending();
        setState(() {
          _trendingMovies = movies;
          _loading = false;
          _error = null;
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  // Helper method to get rating, fetching if not cached
  Future<double> _getRating(String title) async {
    if (_ratingCache.containsKey(title)) {
      return _ratingCache[title]!;
    }
    try {
      final details = await TMDBApiService().fetchMovieDetailsByTitle(title);
      double rating = 0.0;
      if (details != null) {
        final vote = details["vote_average"];
        if (vote is num) rating = vote.toDouble();
      }
      if (rating == 0.0) {
        // Generate fake rating between 6.0 and 9.5
        rating = 6.0 + Random().nextDouble() * 3.5;
      }
      _ratingCache[title] = rating;
      return rating;
    } catch (e) {
      // Generate fake rating on error
      double fakeRating = 6.0 + Random().nextDouble() * 3.5;
      _ratingCache[title] = fakeRating;
      return fakeRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _trendingMovies.length,
            itemBuilder: (context, index) {
              final movie = _trendingMovies[index];
              return FutureBuilder<double>(
                future: _getRating(movie.title),
                builder: (context, snapshot) {
                  double rating = snapshot.data ?? 0.0;
                  return _TrendingCard(movie: movie, rating: rating);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Movie movie;
  final double rating;

  const _TrendingCard({Key? key, required this.movie, required this.rating})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MoviePlayPage(movie: movie),
            transitionDuration: const Duration(
              milliseconds: 600,
            ), // Slower Hero animation
            reverseTransitionDuration: const Duration(
              milliseconds: 600,
            ), // Slower reverse animation
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Container(
                height: 290,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'movie-poster-${movie.title}',
                        createRectTween: (Rect? begin, Rect? end) {
                          return RectTween(begin: begin, end: end);
                        },
                        flightShuttleBuilder:
                            (
                              BuildContext flightContext,
                              Animation<double> animation,
                              HeroFlightDirection flightDirection,
                              BuildContext fromHeroContext,
                              BuildContext toHeroContext,
                            ) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  // Use curved animation for smoother transition
                                  final curvedAnimation = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOutCubic,
                                  );

                                  // Interpolate border radius consistently throughout animation
                                  double radius;
                                  if (flightDirection ==
                                      HeroFlightDirection.push) {
                                    // Forward: 34 → 12
                                    radius =
                                        34.0 - (22.0 * curvedAnimation.value);
                                  } else {
                                    // Reverse: 12 → 34
                                    radius =
                                        12.0 + (22.0 * curvedAnimation.value);
                                  }

                                  return Material(
                                    color: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        radius,
                                      ),
                                      child: Image.network(
                                        movie.image,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[800],
                                                  child: const Icon(
                                                    Icons.movie,
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Image.network(
                            movie.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white24,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    // Subtle dark overlay to increase contrast for pills
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(34),
                        ),
                      ),
                    ),
                    // Rating badge (frosted glass) - same style as carousel
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
                                  rating.toStringAsFixed(1),
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
                    // Frosted glass pill (bottom-center) - now displays info without gesture
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: Colors.white24,
                                width: 0.5,
                              ),
                            ),
                            child: SizedBox(
                              height: 64,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 6.0,
                                        top: 6.0,
                                        right: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            movie.type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            movie.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Play button inside circular container - visual only
                                  Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.only(
                                      left: 12.0,
                                      right: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
