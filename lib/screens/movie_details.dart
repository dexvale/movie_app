import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import 'home_dashboard.dart'; // For PosterDetailPainter

class MovieDetails extends StatelessWidget {
  final AppState state;
  final VoidCallback onBack;

  const MovieDetails({
    super.key,
    required this.state,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final movie = state.selectedMovie;
        final isInWatchlist = movie.isInWatchlist;
        
        String downloadBtnText = 'Download';
        IconData downloadBtnIcon = Icons.arrow_downward;
        Color downloadBtnColor = Colors.white;

        if (movie.downloadState == DownloadState.downloading) {
          downloadBtnText = 'Downloading (${(movie.downloadProgress * 100).toInt()}%)';
          downloadBtnIcon = Icons.hourglass_empty;
          downloadBtnColor = const Color(0xFFE50914);
        } else if (movie.downloadState == DownloadState.downloaded) {
          downloadBtnText = 'Downloaded';
          downloadBtnIcon = Icons.check_circle;
          downloadBtnColor = const Color(0xFFE50914);
        } else if (movie.downloadState == DownloadState.expired) {
          downloadBtnText = 'Expired - Renew';
          downloadBtnIcon = Icons.refresh;
          downloadBtnColor = Colors.orange;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Backdrop Image (40% height simulation)
                _buildBackdrop(context, movie),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre Tags
                      Text(
                        movie.genres.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Metadata row
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${movie.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2229),
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
                          const SizedBox(width: 4),
                          Text(
                            '${movie.year}  •  ${movie.runtime}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // PLAY BUTTON (Full width, crimson)
                      InkWell(
                        onTap: () {
                          // Show play snackbar or screen overlay simulation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFE50914),
                              content: Text(
                                'Playing "${movie.title}" in Ultra HD...',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE50914).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_arrow, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // My List and Download button row
                      Row(
                        children: [
                          // My List button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                state.toggleWatchlist(movie.id);
                              },
                              icon: Icon(
                                isInWatchlist ? Icons.check : Icons.add,
                                color: isInWatchlist ? const Color(0xFFE50914) : Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                isInWatchlist ? 'In My List' : 'My List',
                                style: TextStyle(
                                  color: isInWatchlist ? const Color(0xFFE50914) : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isInWatchlist
                                      ? const Color(0xFFE50914)
                                      : Colors.white.withOpacity(0.2),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFF1F2229).withOpacity(0.4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Download button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                state.toggleDownload(movie.id);
                              },
                              icon: Icon(downloadBtnIcon, color: downloadBtnColor, size: 18),
                              label: Text(
                                downloadBtnText,
                                style: TextStyle(
                                  color: downloadBtnColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: movie.downloadState != DownloadState.notDownloaded
                                      ? downloadBtnColor.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.2),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: const Color(0xFF1F2229).withOpacity(0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Synopsis Header
                      const Text(
                        'Synopsis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Synopsis Text
                      Text(
                        movie.synopsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cast Header
                      const Text(
                        'Cast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cast List
                      _buildCastList(),
                      const SizedBox(height: 24),

                      // Recommended section
                      const Text(
                        'Recommended',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildRecommendedList(),
                      const SizedBox(height: 90), // Bottom nav space padding
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBackdrop(BuildContext context, Movie movie) {
    final String? backdrop = movie.backdropPath;

    return Container(
      height: 330,
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        movie.posterColors.last.withOpacity(0.6),
                        const Color(0xFF0B0C10),
                      ],
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      movie.posterColors.last.withOpacity(0.6),
                      const Color(0xFF0B0C10),
                    ],
                  ),
                ),
              ),
            ),

          // Custom visual shapes (only if backdrop is null)
          if (backdrop == null)
            Positioned.fill(
              child: CustomPaint(
                painter: BackdropVisualPainter(movie.id),
              ),
            ),

          // Smooth Vertical Fade out at bottom 15%
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF0B0C10),
                  ],
                ),
              ),
            ),
          ),

          // Top Nav Buttons (Back and Share overlays)
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Circle button
                InkWell(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                
                // Share Circle button
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard! Share with friends.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastList() {
    final castList = state.activeCast;
    return Container(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: castList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final member = castList[index];
          return Container(
            margin: const EdgeInsets.only(right: 20),
            width: 60,
            child: Column(
              children: [
                // Circular Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE50914).withOpacity(0.4),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: member.avatarColors,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Name
                Text(
                  member.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedList() {
    // Show fetched recommendations if present, otherwise default to mock movies
    final list = state.recommendations.isNotEmpty 
        ? state.recommendations 
        : state.movies.where((m) => m.id == 'neo_tokyo' || m.id == 'void_walker').toList();

    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final movie = list[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                state.selectMovie(movie.id);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9,
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

  Widget _buildBottomNav() {
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

// Custom Painter for Movie Details Backdrop graphics (Neon towers/Grid/Planet)
class BackdropVisualPainter extends CustomPainter {
  final String id;
  BackdropVisualPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.3)
      ..strokeWidth = 2.0;
    
    final redPaint = Paint()
      ..color = const Color(0xFFE50914).withOpacity(0.3)
      ..strokeWidth = 2.0;

    if (id == 'aetheria') {
      // Draw grid lines
      final gridPaint = Paint()
        ..color = const Color(0xFFE50914).withOpacity(0.05)
        ..strokeWidth = 1.0;
      
      double spacing = 15.0;
      for (double i = 0; i < size.width; i += spacing) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      }

      // Draw two twin tower structures glowing with neon spires
      final rect1 = Rect.fromLTWH(size.width * 0.2, size.height * 0.2, 50, size.height * 0.8);
      final rect2 = Rect.fromLTWH(size.width * 0.6, size.height * 0.1, 45, size.height * 0.9);

      final buildingPaint = Paint()..color = const Color(0xFF0B0C10);
      canvas.drawRect(rect1, buildingPaint);
      canvas.drawRect(rect2, buildingPaint);

      // Draw highlights
      canvas.drawLine(rect1.topLeft, Offset(rect1.left, size.height), cyanPaint);
      canvas.drawLine(rect2.topRight, Offset(rect2.right, size.height), redPaint);

      // Spires light points
      canvas.drawCircle(Offset(rect1.left + 25, rect1.top - 20), 4, Paint()..color = const Color(0xFF00E5FF));
      canvas.drawLine(Offset(rect1.left + 25, rect1.top), Offset(rect1.left + 25, rect1.top - 20), cyanPaint);

      canvas.drawCircle(Offset(rect2.left + 22.5, rect2.top - 25), 4, Paint()..color = const Color(0xFFE50914));
      canvas.drawLine(Offset(rect2.left + 22.5, rect2.top), Offset(rect2.left + 22.5, rect2.top - 25), redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
