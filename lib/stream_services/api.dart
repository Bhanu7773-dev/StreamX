import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final String id;
  final String title;
  final String url;
  final String image;
  final String releaseDate;
  final String duration;
  final String type;

  Movie({
    required this.id,
    required this.title,
    required this.url,
    required this.image,
    required this.releaseDate,
    required this.duration,
    required this.type,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      duration: json['duration'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class StreamApiService {
  static const String _baseUrl =
      'https://consumet-roan-eight.vercel.app/movies/flixhq';

  // 1. Trending
  Future<List<Movie>> fetchTrending() async {
    final uri = Uri.parse('$_baseUrl/trending');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map<Movie>((item) => Movie.fromJson(item)).toList();
      } else if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map<Movie>((item) => Movie.fromJson(item))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  // 2. Search
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/$query?page=$page');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map<Movie>((item) => Movie.fromJson(item)).toList();
      } else if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map<Movie>((item) => Movie.fromJson(item))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to search movies');
    }
  }

  // 3. Movie Info
  Future<Map<String, dynamic>> fetchMovieInfo(String id) async {
    final uri = Uri.parse('$_baseUrl/info?id=$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch movie info');
    }
  }

  // 4. Movie Episode Available Servers
  Future<Map<String, dynamic>> fetchEpisodeServers({
    required String episodeId,
    required String mediaId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/servers?episodeId=$episodeId&mediaId=$mediaId',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch episode servers');
    }
  }

  // 5. Movie Episode Streaming Links
  Future<Map<String, dynamic>> fetchWatchLinks({
    required String episodeId,
    required String mediaId,
    required String server,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch watch links');
    }
  }
}
