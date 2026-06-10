import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';

class SearchFilters extends StatefulWidget {
  final AppState state;
  final VoidCallback onNavigateToDetails;

  const SearchFilters({
    super.key,
    required this.state,
    required this.onNavigateToDetails,
  });

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.state.searchQuery;
    _searchController.addListener(() {
      widget.state.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        // Filter logic based on query AND active chip
        final List<Movie> trendingList = widget.state.movies.where((movie) {
          // Exclude recommendations/details only items unless searched
          if (movie.id == 'neo_tokyo' || movie.id == 'void_walker') {
            if (widget.state.searchQuery.isEmpty) return false;
          }
          
          final matchQuery = movie.title.toLowerCase().contains(widget.state.searchQuery.toLowerCase()) ||
              movie.genres.toLowerCase().contains(widget.state.searchQuery.toLowerCase()) ||
              movie.synopsis.toLowerCase().contains(widget.state.searchQuery.toLowerCase());
          
          if (widget.state.activeGenreChip == 'All Genres') {
            return matchQuery;
          } else {
            final matchChip = movie.genres.toLowerCase().contains(widget.state.activeGenreChip.toLowerCase());
            return matchQuery && matchChip;
          }
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          appBar: _buildAppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search movies, actors...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    fillColor: const Color(0xFF1F2229),
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              
              // Genre list scrolling chips
              _buildGenreChips(),

              // Grid title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending Searches',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.state.searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          widget.state.selectGenreChip('All Genres');
                        },
                        child: const Text(
                          'Clear History',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Results grid
              Expanded(
                child: trendingList.isEmpty
                    ? _buildNoResultsView()
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: trendingList.length,
                        itemBuilder: (context, index) {
                          final movie = trendingList[index];
                          return _buildGridCard(movie);
                        },
                      ),
              ),
              const SizedBox(height: 80), // Bottom nav space padding
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0B0C10),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FlixNoir',
            style: TextStyle(
              color: const Color(0xFFE50914),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: const Color(0xFFE50914).withOpacity(0.3),
                  blurRadius: 8,
                )
              ],
            ),
          ),
          // User Avatar Thumbnail
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE50914), width: 1),
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFF1F2229)],
              ),
            ),
            child: const Center(
              child: Text(
                'JV',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    final chips = ['All Genres', 'Action', 'Drama', 'Sci-Fi', 'Thriller', 'Horror', 'Mystery'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        itemBuilder: (context, index) {
          final label = chips[index];
          final isActive = widget.state.activeGenreChip == label;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(label),
              selected: isActive,
              selectedColor: const Color(0xFFE50914),
              backgroundColor: const Color(0xFF1F2229),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) {
                  widget.state.selectGenreChip(label);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridCard(Movie movie) {
    return InkWell(
      onTap: () {
        widget.state.selectMovie(movie.id);
        widget.onNavigateToDetails();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Dynamic gradients representing poster
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

              // Poster details custom painter (only if posterPath is null)
              if (movie.posterPath == null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPosterPainter(movie.id),
                  ),
                ),

              // Dark shadow overlay at bottom for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Quality/Age badges
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    if (movie.qualityBadge.isNotEmpty && movie.qualityBadge != 'PG-13')
                      Container(
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
                  ],
                ),
              ),

              // Movie details text at bottom
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movie.genres,
                      style: const TextStyle(
                        color: Color(0xFFE50914),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
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
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "${widget.state.searchQuery}"',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
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
    final bool isActive = widget.state.activeNavBarIndex == index;
    return InkWell(
      onTap: () {
        widget.state.activeNavBarIndex = index;
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

class GridPosterPainter extends CustomPainter {
  final String id;
  GridPosterPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    // Generate distinct details based on the movie IDs
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE50914).withOpacity(0.3)
      ..strokeWidth = 1;
    
    if (id == 'shadow_protocol') {
      // Draw grid silhouette with a neon crimson circle target
      final targetPaint = Paint()
        ..color = const Color(0xFFE50914)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawCircle(Offset(size.width / 2, size.height / 2.5), 24, targetPaint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2.5), 12, targetPaint);
      canvas.drawLine(
        Offset(size.width / 2 - 35, size.height / 2.5), 
        Offset(size.width / 2 + 35, size.height / 2.5), 
        targetPaint,
      );
      canvas.drawLine(
        Offset(size.width / 2, size.height / 2.5 - 35), 
        Offset(size.width / 2, size.height / 2.5 + 35), 
        targetPaint,
      );

      final person = Paint()..color = Colors.black.withOpacity(0.8);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2.5 + 10), 4, person);
    } else if (id == 'crimson_horizon') {
      // Crimson planet/sun and astronaut
      final sun = Paint()
        ..color = const Color(0xFFE50914)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, size.height / 3), 40, sun);

      // Planet rings
      final ring = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.width / 2, size.height / 3), width: 110, height: 16), 
        ring,
      );
    } else if (id == 'vantablack') {
      // Draw a scary shadow texture with glowing red eyes
      final bg = Paint()..color = const Color(0xFF0D0D0D);
      canvas.drawPaint(bg);

      final eyes = Paint()
        ..color = const Color(0xFFE50914)
        ..style = PaintingStyle.fill;
      
      canvas.drawOval(Rect.fromLTWH(size.width / 2 - 25, size.height / 3, 12, 6), eyes);
      canvas.drawOval(Rect.fromLTWH(size.width / 2 + 13, size.height / 3, 12, 6), eyes);
      
      // Slits
      final pupil = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(size.width / 2 - 20, size.height / 3 + 1, 2, 4), pupil);
      canvas.drawRect(Rect.fromLTWH(size.width / 2 + 18, size.height / 3 + 1, 2, 4), pupil);
    } else if (id == 'neon_pulse') {
      // Abstract laser paths
      for (double i = 0; i < size.height * 0.7; i += 30) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i + 50), linePaint);
      }
    } else if (id == 'the_beacon') {
      // Lighthouse red beam
      final beam = Paint()
        ..color = const Color(0xFFE50914).withOpacity(0.8)
        ..strokeWidth = 4;
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.2), 
        Offset(size.width / 2, size.height * 0.7), 
        beam,
      );
      
      // Draw waves
      final wave = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3), wave);
    } else if (id == 'midnight_blues') {
      // Monochrome street scene
      final wave = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(size.width * 0.3, size.height), Offset(size.width * 0.3, size.height * 0.5), wave);
      canvas.drawLine(Offset(size.width * 0.7, size.height), Offset(size.width * 0.7, size.height * 0.5), wave);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
