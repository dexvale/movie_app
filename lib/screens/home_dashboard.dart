import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import 'video_player.dart';


class HomeDashboard extends StatelessWidget {
  final AppState state;
  final VoidCallback onNavigateToDetails;

  const HomeDashboard({
    super.key,
    required this.state,
    required this.onNavigateToDetails,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(context),
                _buildSectionHeader('Popular'),
                _buildPopularCarousel(),
                const SizedBox(height: 20),
                _buildSectionHeader('Recently Added'),
                _buildRecentlyAddedCarousel(),
                const SizedBox(height: 90), // Bottom nav padding
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    const Icon(
                      Icons.movie_creation_outlined,
                      color: Color(0xFFE50914),
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FLIXNOIR',
                      style: TextStyle(
                        color: const Color(0xFFE50914),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFE50914).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Search button
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 24),
                  onPressed: () {
                    // Navigate to Search tab
                    state.activeNavBarIndex = 1;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final heroMovie = state.movies.isNotEmpty ? state.movies.first : state.selectedMovie;
    final String? backdrop = heroMovie.backdropPath;

    return Container(
      height: 480,
      width: double.infinity,
      child: Stack(
        children: [
          // Backdrop Image or Gradient
          if (backdrop != null)
            Positioned.fill(
              child: Image.network(
                '${ApiService.imageBaseUrlUrlOriginal}$backdrop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF0B0C10), Color(0xFF140D1F)],
                    ),
                  ),
                ),
              ),
            )
          else ...[
            // Cyberpunk Spires Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF0B0C10),
                      Color(0xFF140D1F),
                      Color(0xFF09142A),
                    ],
                  ),
                ),
              ),
            ),
            
            // Spires Drawing (Procedural shapes/grids)
            Positioned.fill(
              child: CustomPaint(
                painter: SpiresPainter(),
              ),
            ),
          ],

          // Bottom Vignette Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 0.8, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    const Color(0xFF0B0C10).withOpacity(0.8),
                    const Color(0xFF0B0C10),
                  ],
                ),
              ),
            ),
          ),

          // Hero Content Overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag & Rating
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFE50914).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'NEW RELEASE',
                        style: TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${heroMovie.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Title
                Text(
                  heroMovie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Synopsis snippet
                Text(
                  heroMovie.synopsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Watch Now & My List buttons
                Row(
                  children: [
                    // Watch Now (Pill button)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          state.selectMovie(heroMovie.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(movie: heroMovie),
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE50914).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_arrow, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Watchlist circle button
                    InkWell(
                      onTap: () {
                        state.toggleWatchlist(heroMovie.id);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2229),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: state.selectedMovie.id == heroMovie.id && heroMovie.isInWatchlist
                                ? const Color(0xFFE50914)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          state.movies.firstWhere((m) => m.id == heroMovie.id).isInWatchlist
                              ? Icons.check
                              : Icons.add,
                          color: state.movies.firstWhere((m) => m.id == heroMovie.id).isInWatchlist
                              ? const Color(0xFFE50914)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'SEE ALL',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCarousel() {
    // Show Obsidian Sky & The Silent Echo + TMDB movies if populated!
    final popular = state.movies.where((m) {
      if (state.movies.length <= 13) return m.id == 'obsidian_sky' || m.id == 'silent_echo';
      // If TMDB active, skip local mockups
      return m.id != 'aetheria' && m.id != 'obsidian_sky' && m.id != 'silent_echo' && 
             m.id != 'neon_genesis' && m.id != 'midnight_blues' && m.id != 'shadow_protocol' &&
             m.id != 'crimson_horizon' && m.id != 'vantablack' && m.id != 'neon_pulse' &&
             m.id != 'the_beacon' && m.id != 'last_cipher' && m.id != 'neo_tokyo' && m.id != 'void_walker';
    }).toList();
    
    return Container(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: popular.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final movie = popular[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                state.selectMovie(movie.id);
                onNavigateToDetails();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          if (movie.posterPath != null)
                            Positioned.fill(
                              child: Image.network(
                                '${ApiService.imageBaseUrlUrl500}${movie.posterPath}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: movie.posterColors,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: movie.posterColors,
                                  ),
                                ),
                              ),
                            ),
                          // Cyberpunk silhouette details
                          if (movie.posterPath == null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PosterDetailPainter(movie.id),
                              ),
                            ),
                          // Rating overlay
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.qualityBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFC107), size: 10),
                      const SizedBox(width: 2),
                      Text(
                        '${movie.rating}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAddedCarousel() {
    // Show Neon Genesis & Midnight Blues (keep them static for watching progress demo)
    final recently = state.movies.where((m) => m.id == 'neon_genesis' || m.id == 'midnight_blues').toList();

    return Container(
      height: 170,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: recently.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final movie = recently[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                state.selectMovie(movie.id);
                onNavigateToDetails();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          if (movie.posterPath != null)
                            Positioned.fill(
                              child: Image.network(
                                '${ApiService.imageBaseUrlUrl500}${movie.posterPath}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: movie.posterColors,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: movie.posterColors,
                                  ),
                                ),
                              ),
                            ),
                          if (movie.posterPath == null)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PosterDetailPainter(movie.id),
                              ),
                            ),
                          // Watching Progress bar
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 3,
                            child: Container(
                              color: Colors.white.withOpacity(0.2),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: movie.id == 'neon_genesis' ? 0.85 : 0.4,
                                child: Container(color: const Color(0xFFE50914)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movie.timeRemaining ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10).withOpacity(0.85),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.search, 'Search'),
              _buildNavItem(2, Icons.download_for_offline_outlined, 'Downloads'),
              _buildNavItem(3, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = state.activeNavBarIndex == index;
    return InkWell(
      onTap: () {
        state.activeNavBarIndex = index;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFE50914) : Colors.white.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFE50914) : Colors.white.withOpacity(0.5),
                fontSize: 9,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFE50914),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw Cyberpunk Skyscrapers & Neon Lines
class SpiresPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw grid mesh overlay
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.04)
      ..strokeWidth = 1.0;
    
    double spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Drawing spires (cyberpunk buildings)
    final shadowPaint = Paint()..color = const Color(0xFF0B0C10);
    final cyanNeon = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.3)
      ..strokeWidth = 2.0;
    final redNeon = Paint()
      ..color = const Color(0xFFE50914).withOpacity(0.3)
      ..strokeWidth = 2.0;

    // Spires parameters: X position, width, height, glow color
    final spires = [
      _Spire(10, 45, 290, true),
      _Spire(65, 30, 220, false),
      _Spire(110, 50, 320, true),
      _Spire(180, 55, 350, false),
      _Spire(250, 45, 270, true),
      _Spire(310, 60, 310, false),
    ];

    for (var spire in spires) {
      final rect = Rect.fromLTWH(spire.x, size.height - spire.height, spire.width, spire.height);
      canvas.drawRect(rect, shadowPaint);
      
      // Neon antennas / highlights
      final topCenter = Offset(spire.x + spire.width / 2, size.height - spire.height);
      final antennaTop = Offset(topCenter.dx, topCenter.dy - 60);
      canvas.drawLine(topCenter, antennaTop, spire.isCyan ? cyanNeon : redNeon);

      // Antenna glowing tip
      canvas.drawCircle(
        antennaTop, 
        3.0, 
        Paint()..color = spire.isCyan ? const Color(0xFF00E5FF) : const Color(0xFFE50914),
      );

      // Edge highlights
      final edgePaint = Paint()
        ..color = (spire.isCyan ? const Color(0xFF00E5FF) : const Color(0xFFE50914)).withOpacity(0.15)
        ..strokeWidth = 1.0;
      canvas.drawLine(rect.topLeft, rect.bottomLeft, edgePaint);
      canvas.drawLine(rect.topRight, rect.bottomRight, edgePaint);
    }

    // Draw astronaut shadow walking near bottom
    final personPaint = Paint()..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(Offset(size.width / 2, size.height - 110), 8, personPaint);
    canvas.drawRect(Rect.fromLTWH(size.width / 2 - 4, size.height - 102, 8, 20), personPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Spire {
  final double x;
  final double width;
  final double height;
  final bool isCyan;
  _Spire(this.x, this.width, this.height, this.isCyan);
}

// Custom Painter for unique movie poster contents (without requiring physical images)
class PosterDetailPainter extends CustomPainter {
  final String id;
  PosterDetailPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    if (id == 'obsidian_sky') {
      // Draw a blood red sun/moon eclipse
      final paint = Paint()
        ..color = const Color(0xFFE50914).withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, size.height / 3), 32, paint);
      
      // Draw eclipse mask
      final mask = Paint()..color = const Color(0xFF0F0C20);
      canvas.drawCircle(Offset(size.width / 2 + 10, size.height / 3 - 5), 28, mask);

      // Draw silhouette figure standing below
      final floor = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, size.height - 40, size.width, 40), floor);

      final person = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(size.width / 2, size.height - 52), 5, person);
      canvas.drawRect(Rect.fromLTWH(size.width / 2 - 3, size.height - 47, 6, 12), person);
    } else if (id == 'silent_echo') {
      // Draw vertical futuristic lines and a child/figure looking up
      final skyPaint = Paint()
        ..color = const Color(0xFFFF007F).withOpacity(0.15)
        ..strokeWidth = 1;
      
      for (double i = 10; i < size.width; i += 15) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height - 50), skyPaint);
      }

      final floor = Paint()..color = const Color(0xFF1F1C2C);
      canvas.drawRect(Rect.fromLTWH(0, size.height - 50, size.width, 50), floor);

      final glow = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.width / 2, size.height - 50), 15, glow);
    } else if (id == 'neon_genesis') {
      // Control panel deck with green/red status light paths
      final laserPaint = Paint()
        ..color = const Color(0xFFE50914)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), laserPaint);

      final deckGlow = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.2)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.8), deckGlow);
    } else if (id == 'midnight_blues') {
      // Trumpet / soundwave circles in red/grey
      final wavePaint = Paint()
        ..color = const Color(0xFFE50914).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, wavePaint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 35, wavePaint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
