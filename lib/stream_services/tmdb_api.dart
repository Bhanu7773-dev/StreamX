import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBApiService {
  /// Search TMDB for a movie by its title and return detailed info including director, budget, etc.
  Future<Map<String, dynamic>?> fetchMovieDetailsByTitle(String title) async {
    // First search for the movie
    final searchUrl =
        '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(title)}';
    print('[TMDBApiService] fetchMovieDetailsByTitle Search URL: $searchUrl');
    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode == 200) {
      final searchData = json.decode(searchResponse.body);
      if (searchData['results'] is List && searchData['results'].isNotEmpty) {
        final movieId = searchData['results'][0]['id'];

        // Fetch detailed movie info including credits
        final detailsUrl =
            '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=credits';
        print(
          '[TMDBApiService] fetchMovieDetailsByTitle Details URL: $detailsUrl',
        );
        final detailsResponse = await http.get(Uri.parse(detailsUrl));

        if (detailsResponse.statusCode == 200) {
          return json.decode(detailsResponse.body) as Map<String, dynamic>;
        }
      }
    }
    throw Exception('Failed to search movie by title');
  }

  static const String _apiKey = '4f17907c4cf63f7f060a6051a82a00d7';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Fetch movie details by TMDB movie ID
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final url = '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  // Search for a movie by title
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url =
        '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to search movies');
    }
  }

  // Fetch popular movies
  Future<List<Map<String, dynamic>>> fetchPopularMovies({int page = 1}) async {
    final url =
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch popular movies');
    }
  }

  // Fetch movies by genre
  Future<List<Map<String, dynamic>>> fetchMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final url =
        '$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&with_genres=$genreId&page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch movies by genre');
    }
  }

  // Fetch movie credits (cast & crew)
  Future<Map<String, dynamic>> fetchMovieCredits(int movieId) async {
    final url =
        '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch movie credits');
    }
  }

  // Fetch similar movies
  Future<List<Map<String, dynamic>>> fetchSimilarMovies(int movieId) async {
    final url =
        '$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=en-US&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch similar movies');
    }
  }

  // Fetch movie videos (trailers, teasers, etc.)
  Future<List<Map<String, dynamic>>> fetchMovieVideos(int movieId) async {
    final url =
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch movie videos');
    }
  }

  // Fetch movie images (posters, backdrops)
  Future<Map<String, dynamic>> fetchMovieImages(int movieId) async {
    final url = '$_baseUrl/movie/$movieId/images?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch movie images');
    }
  }
}
