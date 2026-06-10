import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  // CONFIGURATION: Insert your TMDB credentials here
  static const String apiKey =
      'f29df1031c96f8fb124bb4c0ae20d29b'; // Insert your API Key (v3) here
  static const String readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmMjlkZjEwMzFjOTZmOGZiMTI0YmI0YzBhZTIwZDI5YiIsIm5iZiI6MTc4MTA3MDMyNS4wMTYsInN1YiI6IjZhMjhmOWY1YWExN2ZkMzg5Mjg5NjJiNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.pnoMPtqROs0I0c0-D9fZKRrmQUKNbaXsfRzLNbCA7ko'; // OR insert your API Read Access Token (v4) here

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrlUrl500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlUrlOriginal =
      'https://image.tmdb.org/t/p/original';

  Map<String, String> get _headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json;charset=utf-8',
    };
    if (readAccessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $readAccessToken';
    }
    return headers;
  }

  String _getUrl(String path, {Map<String, String>? queryParams}) {
    String url = '$_baseUrl$path';

    // Fallback: If no bearer token, use query parameter api_key
    if (readAccessToken.isEmpty && apiKey.isNotEmpty) {
      url += '${path.contains('?') ? '&' : '?'}api_key=$apiKey';
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      queryParams.forEach((key, value) {
        url += '${url.contains('?') ? '&' : '?'}$key=$value';
      });
    }
    return url;
  }

  // 1. Fetch Now Playing (for Screen 1 Hero Banner)
  Future<Movie?> fetchHeroMovie() async {
    if (apiKey.isEmpty && readAccessToken.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(_getUrl('/movie/now_playing', queryParams: {'page': '1'})),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        if (results.isNotEmpty) {
          return _mapJsonToMovie(
            results.first,
            customGenres: 'SCI-FI • CYBERPUNK',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading hero movie: $e');
    }
    return null;
  }

  // 2. Fetch Popular Movies (for Screen 1 Popular Carousel)
  Future<List<Movie>> fetchPopularMovies() async {
    if (apiKey.isEmpty && readAccessToken.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(_getUrl('/movie/popular', queryParams: {'page': '1'})),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => _mapJsonToMovie(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading popular list: $e');
    }
    return [];
  }

  // 3. Search Movies (for Screen 2 grid queries)
  Future<List<Movie>> searchMovies(String query) async {
    if (apiKey.isEmpty && readAccessToken.isEmpty) return [];
    if (query.trim().isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          _getUrl(
            '/search/movie',
            queryParams: {'query': Uri.encodeComponent(query), 'page': '1'},
          ),
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => _mapJsonToMovie(json)).toList();
      }
    } catch (e) {
      debugPrint('Error searching movies: $e');
    }
    return [];
  }

  // 4. Fetch Cast (for Screen 3 Movie Details Credits)
  Future<List<CastMember>> fetchCastMembers(String movieId) async {
    if (apiKey.isEmpty && readAccessToken.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(_getUrl('/movie/$movieId/credits')),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List castList = data['cast'] ?? [];

        // Take first 4-5 cast members
        final int limit = castList.length > 5 ? 5 : castList.length;
        final List<CastMember> members = [];

        for (int i = 0; i < limit; i++) {
          final item = castList[i];
          final String name = item['name'] ?? 'Actor';
          final String initials = name
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .join();

          members.add(
            CastMember(
              name: name,
              initials: initials.length > 2
                  ? initials.substring(0, 2)
                  : initials,
              // Generate distinct procedural gradient colors based on length
              avatarColors: [
                _getColorForIndex(name.length),
                _getColorForIndex(name.length + 3),
              ],
            ),
          );
        }
        return members;
      }
    } catch (e) {
      debugPrint('Error loading cast: $e');
    }
    return [];
  }

  // 5. Fetch Recommended Movies (for Screen 3 Bottom Carousel)
  Future<List<Movie>> fetchRecommendations(String movieId) async {
    if (apiKey.isEmpty && readAccessToken.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          _getUrl(
            '/movie/$movieId/recommendations',
            queryParams: {'page': '1'},
          ),
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => _mapJsonToMovie(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }
    return [];
  }

  // Deserializer: Generic Map data mapping helper
  Movie _mapJsonToMovie(Map<String, dynamic> json, {String? customGenres}) {
    final double rating = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
    final String releaseDate = json['release_date'] ?? '';
    final String year = releaseDate.split('-').first;

    // Map TMDB genres (placeholder mapping since we don't fetch full genre lists here)
    String genreString = customGenres ?? 'Action • Sci-Fi';
    final List<dynamic>? genreIds = json['genre_ids'];
    if (genreIds != null && genreIds.isNotEmpty) {
      final List<String> textGenres = [];
      for (var id in genreIds) {
        final mapped = _genreMap[id];
        if (mapped != null) textGenres.add(mapped);
        if (textGenres.length >= 2) break;
      }
      if (textGenres.isNotEmpty) {
        genreString = textGenres.join(' • ');
      }
    }

    final String title = json['title'] ?? 'Unknown Movie';

    return Movie(
      id: json['id'].toString(),
      title: title,
      rating: double.parse(rating.toStringAsFixed(1)),
      year: year.isEmpty ? '2024' : year,
      runtime:
          '2h 14m', // Default filler since details endpoint is required for this
      ageRating: json['adult'] == true ? '18+' : 'PG-13',
      qualityBadge: rating >= 8.0 ? '4K HDR' : 'HDR',
      genres: genreString,
      synopsis: json['overview'] ?? 'No overview available.',
      posterColors: [
        _getColorForIndex(title.length),
        _getColorForIndex(title.length + 5),
      ],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
    );
  }

  Color _getColorForIndex(int idx) {
    const list = [
      Color(0xFF0F0C20),
      Color(0xFF2C5364),
      Color(0xFF1F1C2C),
      Color(0xFF928DAB),
      Color(0xFF3E0A0A),
      Color(0xFFE50914),
      Color(0xFF0D1B2A),
      Color(0xFF415A77),
      Color(0xFF050505),
      Color(0xFF1A1A1A),
      Color(0xFF000B29),
      Color(0xFF00E5FF),
    ];
    return list[idx % list.length];
  }

  // Basic Genre ID map mapping
  static const Map<int, String> _genreMap = {
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
}
