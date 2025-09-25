import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBApiService {
  /// Search TMDB for a movie by its title and return the first result's details (including rating)
  Future<Map<String, dynamic>?> fetchMovieDetailsByTitle(String title) async {
    final url =
        '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(title)}';
    print('[TMDBApiService] fetchMovieDetailsByTitle URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List && data['results'].isNotEmpty) {
        // Return the first result's details
        return data['results'][0] as Map<String, dynamic>;
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to search movie by title');
    }
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

  // Fetch trending movies
  Future<List<Map<String, dynamic>>> fetchTrending({
    String mediaType = 'movie',
    String timeWindow = 'week',
  }) async {
    final url = '$_baseUrl/trending/$mediaType/$timeWindow?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch trending movies');
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
