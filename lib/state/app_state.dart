import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Navigation for the virtual simulation
  int _activeNavBarIndex = 0;
  int get activeNavBarIndex => _activeNavBarIndex;

  set activeNavBarIndex(int index) {
    _activeNavBarIndex = index;
    notifyListeners();
  }

  // Active view in the dashboard (0 = Ecosystem side-by-side, 1-5 = Focused Screen 1-5)
  int _focusedScreenIndex = 0; // 0 is horizontal row, 1-5 is individual screen focus
  int get focusedScreenIndex => _focusedScreenIndex;

  void setFocusedScreen(int index) {
    _focusedScreenIndex = index;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CastMember> _activeCast = [];
  List<CastMember> get activeCast => _activeCast.isEmpty ? cast : _activeCast;

  List<Movie> _recommendations = [];
  List<Movie> get recommendations => _recommendations;

  // List of movies
  final List<Movie> _movies = [
    Movie(
      id: 'aetheria',
      title: 'AETHERIA',
      rating: 9.4,
      year: '2024',
      runtime: '2h 15m',
      genres: 'SCI-FI • CYBERPUNK',
      synopsis: 'In a decaying megalopolis where digital consciousness can be harvested, a rogue data-thief uncovers a celestial signal that suggests life exists beyond the simulated reality of Aetheria. As the boundaries between memory and code blur, she must navigate the neon-drenched underworld to protect the last fragment of human soul.',
      posterColors: [const Color(0xFF0B0C10), const Color(0xFFE50914)],
      isInWatchlist: true,
      downloadState: DownloadState.notDownloaded,
    ),
    Movie(
      id: 'obsidian_sky',
      title: 'Obsidian Sky',
      rating: 8.8,
      year: '2025',
      runtime: '1h 58m',
      qualityBadge: '4K',
      genres: 'Sci-Fi • Noir',
      synopsis: 'A noir detective searches for a missing synthetic singer in the darkest trenches of a perpetual eclipse.',
      posterColors: [const Color(0xFF0F0C20), const Color(0xFF2C5364)],
    ),
    Movie(
      id: 'silent_echo',
      title: 'The Silent Echo',
      rating: 9.1,
      year: '2025',
      runtime: '2h 05m',
      qualityBadge: 'HDR',
      genres: 'Drama • Mystery',
      synopsis: 'A sound engineer intercepts a voice from the void that speaks only in forgotten childhood memories.',
      posterColors: [const Color(0xFF1F1C2C), const Color(0xFF928DAB)],
    ),
    Movie(
      id: 'neon_genesis',
      title: 'Neon Genesis: Part II',
      rating: 8.9,
      year: '2026',
      runtime: '2h 10m',
      genres: 'Action • Mecha',
      timeRemaining: '24m remaining',
      synopsis: 'Humanity faces its final stand against towering biomechanical entities in this stunning sequel.',
      posterColors: [const Color(0xFF140008), const Color(0xFF4A0E17)],
    ),
    Movie(
      id: 'midnight_blues',
      title: 'Midnight Blues',
      rating: 8.5,
      year: '2024',
      runtime: '1h 45m',
      genres: 'Drama • Music',
      timeRemaining: '1h 12m remaining',
      synopsis: 'A jazz trumpeter makes a deal with a shadowy corporation to play one last gig in the virtual underground.',
      posterColors: [const Color(0xFF1E1E1E), const Color(0xFF0D0D0D)],
    ),
    Movie(
      id: 'shadow_protocol',
      title: 'Shadow Protocol',
      rating: 9.0,
      year: '2025',
      runtime: '2h 12m',
      genres: 'Crime • Thriller',
      synopsis: 'An elite hacker is framed for deleting the global central database, initiating a high-stakes manhunt.',
      posterColors: [const Color(0xFF0D1B2A), const Color(0xFF415A77)],
      downloadState: DownloadState.downloading,
      downloadProgress: 0.65,
      downloadSize: '945 MB',
    ),
    Movie(
      id: 'crimson_horizon',
      title: 'Crimson Horizon',
      rating: 8.7,
      year: '2025',
      runtime: '2h 02m',
      qualityBadge: 'AD',
      genres: 'Sci-Fi • Adventure',
      synopsis: 'An astronaut embarks on a solo voyage to the edge of a red supergiant star to save her stranded crew.',
      posterColors: [const Color(0xFF3E0A0A), const Color(0xFFE50914)],
    ),
    Movie(
      id: 'vantablack',
      title: 'Vantablack',
      rating: 8.6,
      year: '2025',
      runtime: '1h 50m',
      qualityBadge: '18+',
      genres: 'Horror • Mystery',
      synopsis: 'A research team discovers a substance that absorbs all light and reflects their darkest thoughts.',
      posterColors: [const Color(0xFF050505), const Color(0xFF1A1A1A)],
    ),
    Movie(
      id: 'neon_pulse',
      title: 'Neon Pulse',
      rating: 9.2,
      year: '2024',
      runtime: '2h 08m',
      genres: 'Action • Cyberpunk',
      synopsis: 'A cybernetic racer enters an illegal death tournament in the skyways of Neo-Tokyo.',
      posterColors: [const Color(0xFF000B29), const Color(0xFF00E5FF)],
      downloadState: DownloadState.downloaded,
      downloadSize: '320 MB',
    ),
    Movie(
      id: 'the_beacon',
      title: 'The Beacon',
      rating: 8.4,
      year: '2024',
      runtime: '1h 40m',
      genres: 'Thriller • Indie',
      synopsis: 'A lighthouse keeper on a remote volcanic island discovers the light is attracting things from beneath the waves.',
      posterColors: [const Color(0xFF0F1A1C), const Color(0xFF2E5B5B)],
    ),
    Movie(
      id: 'last_cipher',
      title: 'The Last Cipher',
      rating: 8.8,
      year: '2023',
      runtime: '1h 56m',
      genres: 'Mystery • Indie',
      synopsis: 'An ancient manuscript contains a cryptographic key that could unlock the secrets of human consciousness.',
      posterColors: [const Color(0xFF1B1B1B), const Color(0xFF3D2A12)],
      downloadState: DownloadState.expired,
      downloadSize: 'Expired • Renew Required',
    ),
    Movie(
      id: 'neo_tokyo',
      title: 'NEO TOKYO',
      rating: 8.9,
      year: '2026',
      runtime: '2h 10m',
      genres: 'Sci-Fi • Cyberpunk',
      synopsis: 'A deep dive into the neon spires of a resurrected cyber metropolis.',
      posterColors: [const Color(0xFF0E0E1E), const Color(0xFFFF007F)],
    ),
    Movie(
      id: 'void_walker',
      title: 'VOID WALKER',
      rating: 9.1,
      year: '2025',
      runtime: '1h 55m',
      genres: 'Sci-Fi • Cyberpunk',
      synopsis: 'A wanderer travels through empty digital spaces looking for signs of human activity.',
      posterColors: [const Color(0xFF1E0E1E), const Color(0xFFE50914)],
    ),
  ];

  List<Movie> get movies => _movies;

  // Selected Movie for Detail View (Screen 3)
  late String _selectedMovieId = 'aetheria';
  String get selectedMovieId => _selectedMovieId;
  
  Movie get selectedMovie => _movies.firstWhere((m) => m.id == _selectedMovieId, orElse: () => _movies.first);

  Future<void> selectMovie(String id) async {
    _selectedMovieId = id;
    notifyListeners();

    if (ApiService.apiKey.isEmpty && ApiService.readAccessToken.isEmpty) return;

    final bool isTmdbId = int.tryParse(id) != null;
    if (isTmdbId) {
      try {
        final fetchedCast = await _apiService.fetchCastMembers(id);
        if (fetchedCast.isNotEmpty) {
          _activeCast = fetchedCast;
        }

        final fetchedRecs = await _apiService.fetchRecommendations(id);
        if (fetchedRecs.isNotEmpty) {
          _recommendations = fetchedRecs;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading movie details from TMDB: $e');
      }
    } else {
      // Reset recommendations / cast to static ones for mock files
      _activeCast = [];
      _recommendations = [];
      notifyListeners();
    }
  }

  // Search and Genre filters
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();

    if (query.trim().isEmpty) return;
    if (ApiService.apiKey.isEmpty && ApiService.readAccessToken.isEmpty) return;

    try {
      final searchResults = await _apiService.searchMovies(query);
      if (searchResults.isNotEmpty) {
        for (var movie in searchResults) {
          final existingIdx = _movies.indexWhere((m) => m.id == movie.id);
          if (existingIdx == -1) {
            _movies.add(movie);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error searching TMDB: $e');
    }
  }

  String _activeGenreChip = 'All Genres';
  String get activeGenreChip => _activeGenreChip;

  void selectGenreChip(String chip) {
    _activeGenreChip = chip;
    notifyListeners();
  }

  // Profile data
  String _username = 'Julian Vane';
  String get username => _username;
  bool _isPremiumMember = true;
  bool get isPremiumMember => _isPremiumMember;
  int _watchedCount = 124;
  int get watchedCount => _watchedCount;

  int get watchlistCount {
    int count = _movies.where((m) => m.isInWatchlist).length;
    return count + 40; 
  }

  void updateUsername(String name) {
    _username = name;
    notifyListeners();
  }

  // Download logic & simulation
  Timer? _downloadSimulationTimer;

  AppState() {
    // Start active downloads progress loop
    _downloadSimulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      bool changed = false;
      for (int i = 0; i < _movies.length; i++) {
        if (_movies[i].downloadState == DownloadState.downloading) {
          double newProgress = _movies[i].downloadProgress + 0.08;
          if (newProgress >= 1.0) {
            _movies[i] = _movies[i].copyWith(
              downloadState: DownloadState.downloaded,
              downloadProgress: 1.0,
              downloadSize: '1.2 GB',
            );
          } else {
            _movies[i] = _movies[i].copyWith(
              downloadProgress: newProgress,
            );
          }
          changed = true;
        }
      }
      if (changed) {
        notifyListeners();
      }
    });

    // Load initial TMDB data if key exists
    loadTMDBData();
  }

  Future<void> loadTMDBData() async {
    if (ApiService.apiKey.isEmpty && ApiService.readAccessToken.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Hero Movie
      final hero = await _apiService.fetchHeroMovie();
      if (hero != null) {
        final idx = _movies.indexWhere((m) => m.id == 'aetheria' || m.id == hero.id);
        if (idx != -1) {
          _movies[idx] = hero.copyWith(
            isInWatchlist: _movies[idx].isInWatchlist,
            downloadState: _movies[idx].downloadState,
          );
        } else {
          _movies.insert(0, hero);
        }
        _selectedMovieId = hero.id;
      }

      // 2. Fetch Popular Movies
      final popularList = await _apiService.fetchPopularMovies();
      if (popularList.isNotEmpty) {
        for (var movie in popularList) {
          final existingIdx = _movies.indexWhere((m) => m.id == movie.id);
          if (existingIdx == -1) {
            _movies.add(movie);
          } else {
            _movies[existingIdx] = movie.copyWith(
              isInWatchlist: _movies[existingIdx].isInWatchlist,
              downloadState: _movies[existingIdx].downloadState,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading TMDB data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _downloadSimulationTimer?.cancel();
    super.dispose();
  }

  void toggleWatchlist(String movieId) {
    final idx = _movies.indexWhere((m) => m.id == movieId);
    if (idx != -1) {
      _movies[idx] = _movies[idx].copyWith(isInWatchlist: !_movies[idx].isInWatchlist);
      notifyListeners();
    }
  }

  void toggleDownload(String movieId) {
    final idx = _movies.indexWhere((m) => m.id == movieId);
    if (idx != -1) {
      final movie = _movies[idx];
      if (movie.downloadState == DownloadState.notDownloaded) {
        _movies[idx] = movie.copyWith(
          downloadState: DownloadState.downloading,
          downloadProgress: 0.0,
          downloadSize: '950 MB',
        );
      } else if (movie.downloadState == DownloadState.downloading) {
        _movies[idx] = movie.copyWith(
          downloadState: DownloadState.notDownloaded,
          downloadProgress: 0.0,
          downloadSize: '',
        );
      } else if (movie.downloadState == DownloadState.downloaded) {
        _movies[idx] = movie.copyWith(
          downloadState: DownloadState.notDownloaded,
          downloadProgress: 0.0,
          downloadSize: '',
        );
      } else if (movie.downloadState == DownloadState.expired) {
        _movies[idx] = movie.copyWith(
          downloadState: DownloadState.downloading,
          downloadProgress: 0.0,
          downloadSize: '1.2 GB',
        );
      }
      notifyListeners();
    }
  }

  double get storageUsedGb {
    double base = 42.5;
    return base;
  }

  final List<CastMember> cast = const [
    CastMember(name: 'Julian Vane', avatarColors: [Color(0xFFE50914), Color(0xFF1F2229)], initials: 'JV'),
    CastMember(name: 'Elena Thorne', avatarColors: [Color(0xFF00E5FF), Color(0xFF1F2229)], initials: 'ET'),
    CastMember(name: 'Marcus Kael', avatarColors: [Color(0xFFE50914), Color(0xFF0B0C10)], initials: 'MK'),
    CastMember(name: 'Sia Chen', avatarColors: [Color(0xFFFF007F), Color(0xFF1F2229)], initials: 'SC'),
  ];

  bool _smartDownloadsEnabled = true;
  bool get smartDownloadsEnabled => _smartDownloadsEnabled;

  void toggleSmartDownloads() {
    _smartDownloadsEnabled = !_smartDownloadsEnabled;
    notifyListeners();
  }
}
