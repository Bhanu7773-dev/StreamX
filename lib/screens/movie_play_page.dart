import 'package:flutter/material.dart';
import '../stream_services/api.dart';
import '../stream_services/tmdb_api.dart';

class MoviePlayPage extends StatefulWidget {
  final Movie movie;

  const MoviePlayPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MoviePlayPage> createState() => _MoviePlayPageState();
}

class _MoviePlayPageState extends State<MoviePlayPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TMDB API data
  Map<String, dynamic>? _tmdbData;
  bool _isLoading = true;
  String? _error;
  final TMDBApiService _tmdbService = TMDBApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMovieData();
  }

  Future<void> _fetchMovieData() async {
    try {
      final movieData = await _tmdbService.fetchMovieDetailsByTitle(
        widget.movie.title,
      );
      if (mounted) {
        setState(() {
          _tmdbData = movieData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load movie details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildTabBar(),
              _buildTabContent(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: const Color(0xFF0A0A0A),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildVideoPlayer(),
        collapseMode: CollapseMode.none,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Stack(
        children: [
          // Background poster image
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: Image.network(
                widget.movie.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                        Color(0xFF0F3460),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dark overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white.withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load movie data',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // Movie info overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Movie poster
                Hero(
                  tag: 'movie-poster-${widget.movie.title}',
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.movie.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE53E3E),
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Movie details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tmdbData?['title'] ?? widget.movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _buildMovieMetadata(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildRatingChip(
                            _tmdbData != null
                                ? '${(_tmdbData!['vote_average'] as num).toStringAsFixed(1)}'
                                : '0.0',
                            Icons.star,
                            Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          _buildRatingChip(
                            _tmdbData != null
                                ? '${((_tmdbData!['vote_average'] as num) * 10).toInt()}%'
                                : '0%',
                            Icons.thumb_up,
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _buildRatingChip(
                            _tmdbData != null
                                ? '${_tmdbData!['runtime'] ?? 'N/A'} min'
                                : 'N/A min',
                            Icons.access_time,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectorName() {
    if (_tmdbData == null || _tmdbData!['credits'] == null) return 'N/A';

    final credits = _tmdbData!['credits'];
    if (credits['crew'] != null) {
      final crew = credits['crew'] as List;
      final director = crew.firstWhere(
        (person) => person['job'] == 'Director',
        orElse: () => null,
      );
      if (director != null) {
        return director['name'];
      }
    }
    return 'N/A';
  }

  String _getWriterName() {
    if (_tmdbData == null || _tmdbData!['credits'] == null) return 'N/A';

    final credits = _tmdbData!['credits'];
    if (credits['crew'] != null) {
      final crew = credits['crew'] as List;
      final writer = crew.firstWhere(
        (person) => person['job'] == 'Writer' || person['job'] == 'Screenplay',
        orElse: () => null,
      );
      if (writer != null) {
        return writer['name'];
      }
    }
    return 'N/A';
  }

  String _getBudgetFormatted() {
    if (_tmdbData == null) return 'N/A';

    final budget = _tmdbData!['budget'];
    if (budget != null && budget > 0) {
      if (budget >= 1000000) {
        return '\$${(budget / 1000000).toStringAsFixed(0)}M';
      } else if (budget >= 1000) {
        return '\$${(budget / 1000).toStringAsFixed(0)}K';
      } else {
        return '\$$budget';
      }
    }
    return 'N/A';
  }

  String _getBoxOffice() {
    if (_tmdbData == null) return 'N/A';

    final revenue = _tmdbData!['revenue'];
    if (revenue != null && revenue > 0) {
      if (revenue >= 1000000000) {
        return '\$${(revenue / 1000000000).toStringAsFixed(1)}B';
      } else if (revenue >= 1000000) {
        return '\$${(revenue / 1000000).toStringAsFixed(0)}M';
      } else if (revenue >= 1000) {
        return '\$${(revenue / 1000).toStringAsFixed(0)}K';
      } else {
        return '\$$revenue';
      }
    }
    return 'N/A';
  }

  String _getProducerName() {
    if (_tmdbData == null || _tmdbData!['credits'] == null) return 'N/A';

    final credits = _tmdbData!['credits'];
    if (credits['crew'] != null) {
      final crew = credits['crew'] as List;
      final producer = crew.firstWhere(
        (person) =>
            person['job'] == 'Producer' ||
            person['job'] == 'Executive Producer',
        orElse: () => null,
      );
      if (producer != null) {
        return producer['name'];
      }
    }
    return 'N/A';
  }

  String _getComposerName() {
    if (_tmdbData == null || _tmdbData!['credits'] == null) return 'N/A';

    final credits = _tmdbData!['credits'];
    if (credits['crew'] != null) {
      final crew = credits['crew'] as List;
      final composer = crew.firstWhere(
        (person) =>
            person['job'] == 'Original Music Composer' ||
            person['job'] == 'Music' ||
            person['job'] == 'Composer',
        orElse: () => null,
      );
      if (composer != null) {
        return composer['name'];
      }
    }
    return 'N/A';
  }

  List<Map<String, dynamic>> _getRealCastData() {
    if (_tmdbData == null || _tmdbData!['credits'] == null) {
      return [];
    }

    final credits = _tmdbData!['credits'];
    if (credits['cast'] == null) return [];

    final cast = credits['cast'] as List;

    // Generate colors for each cast member
    final colors = [
      const Color(0xFFE53E3E), // Red
      const Color(0xFF9F7AEA), // Purple
      const Color(0xFF4299E1), // Blue
      const Color(0xFF48BB78), // Green
      const Color(0xFFED8936), // Orange
      const Color(0xFFECC94B), // Yellow
      const Color(0xFF38B2AC), // Teal
      const Color(0xFFED64A6), // Pink
      const Color(0xFF667EEA), // Indigo
      const Color(0xFF9AE6B4), // Light Green
    ];

    // Take first 10 cast members and assign colors
    return cast.take(10).map<Map<String, dynamic>>((castMember) {
      final index = cast.indexOf(castMember);
      return {
        'name': castMember['name'] ?? 'Unknown',
        'role': castMember['character'] ?? 'Unknown Character',
        'color': colors[index % colors.length],
        'profile_path': castMember['profile_path'],
      };
    }).toList();
  }

  String _buildMovieMetadata() {
    if (_tmdbData == null) return 'Loading...';

    final year = _tmdbData!['release_date'] != null
        ? _tmdbData!['release_date'].toString().substring(0, 4)
        : 'N/A';

    final genres = _tmdbData!['genres'] != null
        ? (_tmdbData!['genres'] as List).map((g) => g['name']).join(', ')
        : 'N/A';

    return '$year • $genres';
  }

  Widget _buildRatingChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Watch Now', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.playlist_add, size: 20),
              label: const Text('Watchlist'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFE53E3E),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          // TabBarView handles the switching automatically
        },
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Episodes'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 500, // Further reduced to definitely force scrolling
      child: TabBarView(
        controller: _tabController,
        children: [_buildInfoTab(), _buildEpisodesTab()],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildMovieStats(),
          const SizedBox(height: 32),
          _buildSynopsis(),
          const SizedBox(height: 32),
          _buildCastSection(),
          const SizedBox(height: 32),
          _buildCrewSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildSeasonSelector(),
          const SizedBox(height: 16),
          _buildEpisodesList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Season',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: 1,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                items: [1, 2, 3].map((season) {
                  return DropdownMenuItem(
                    value: season,
                    child: Text('Season $season'),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList() {
    final episodes = [
      {
        'title': 'The Beginning',
        'description':
            'Batman begins his journey to fight crime in Gotham City.',
        'duration': '45:32',
        'episodeNumber': 1,
        'thumbnail': const Color(0xFFE53E3E),
      },
      {
        'title': 'The Dark Knight Rises',
        'description':
            'Batman faces his greatest challenge yet with the Joker.',
        'duration': '42:18',
        'episodeNumber': 2,
        'thumbnail': const Color(0xFF4299E1),
      },
      {
        'title': 'Harvey Dent',
        'description': 'The introduction of Gotham\'s white knight.',
        'duration': '48:25',
        'episodeNumber': 3,
        'thumbnail': const Color(0xFF9F7AEA),
      },
      {
        'title': 'Chaos Theory',
        'description': 'The Joker\'s plan begins to unfold.',
        'duration': '51:12',
        'episodeNumber': 4,
        'thumbnail': const Color(0xFF48BB78),
      },
      {
        'title': 'Two Faces',
        'description': 'Harvey Dent\'s transformation into Two-Face.',
        'duration': '46:55',
        'episodeNumber': 5,
        'thumbnail': const Color(0xFFED8936),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Episode thumbnail
                    Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                        color: episodes[index]['thumbnail'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                episodes[index]['duration'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Episode info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE53E3E,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'EP ${episodes[index]['episodeNumber']}',
                                  style: const TextStyle(
                                    color: Color(0xFFE53E3E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.download_outlined,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            episodes[index]['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            episodes[index]['description'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Director', _getDirectorName()),
          _buildStatDivider(),
          _buildStatItem('Budget', _getBudgetFormatted()),
          _buildStatDivider(),
          _buildStatItem('Box Office', _getBoxOffice()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildSynopsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tmdbData != null && _tmdbData!['overview'] != null
                ? _tmdbData!['overview']
                : 'No synopsis available.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    final cast = _getRealCastData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Cast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: cast.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Cast information not available',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: cast.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: cast[index]['profile_path'] != null
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (cast[index]['color'] as Color)
                                            .withOpacity(0.8),
                                        cast[index]['color'] as Color,
                                      ],
                                    ),
                            ),
                            child: cast[index]['profile_path'] != null
                                ? ClipOval(
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w185${cast[index]['profile_path']}',
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    (cast[index]['color']
                                                            as Color)
                                                        .withOpacity(0.8),
                                                    cast[index]['color']
                                                        as Color,
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (cast[index]['name']
                                                          as String)
                                                      .split(' ')
                                                      .map(
                                                        (e) => e.isNotEmpty
                                                            ? e[0]
                                                            : '',
                                                      )
                                                      .join(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    (cast[index]['color']
                                                            as Color)
                                                        .withOpacity(0.3),
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      (cast[index]['name'] as String)
                                          .split(' ')
                                          .map((e) => e.isNotEmpty ? e[0] : '')
                                          .join(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cast[index]['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            cast[index]['role'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCrewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crew',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCrewCard(
                  'Director',
                  _getDirectorName(),
                  Icons.movie_filter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCrewCard('Writer', _getWriterName(), Icons.edit),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCrewCard(
                  'Producer',
                  _getProducerName(),
                  Icons.business,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCrewCard(
                  'Music',
                  _getComposerName(),
                  Icons.music_note,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrewCard(String role, String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
