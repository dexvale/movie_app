import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../state/app_state.dart';

class DownloadsManager extends StatefulWidget {
  final AppState state;
  final VoidCallback onNavigateToDetails;

  const DownloadsManager({
    super.key,
    required this.state,
    required this.onNavigateToDetails,
  });

  @override
  State<DownloadsManager> createState() => _DownloadsManagerState();
}

class _DownloadsManagerState extends State<DownloadsManager> {
  bool _isEditing = false;
  final Set<String> _selectedItemsToDelete = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        // Filter out movies that have some download state
        final downloadedMovies = widget.state.movies
            .where((m) => m.downloadState != DownloadState.notDownloaded)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Storage Indicator Widget
                  _buildStorageWidget(),
                  const SizedBox(height: 24),

                  // Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENTLY DOWNLOADED',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            _selectedItemsToDelete.clear();
                          });
                        },
                        child: Text(
                          _isEditing ? 'DONE' : 'EDIT',
                          style: const TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Downloaded List
                  downloadedMovies.isEmpty
                      ? _buildEmptyState()
                      : _buildDownloadList(downloadedMovies),
                  const SizedBox(height: 20),

                  // Smart Downloads Toggle Tile
                  _buildSmartDownloadsTile(),
                  const SizedBox(height: 20),

                  // Find More to Download Button
                  _buildFindMoreButton(context),
                  const SizedBox(height: 100), // Bottom nav padding
                ],
              ),
            ),
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
      title: const Text(
        'Downloads',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            widget.state.activeNavBarIndex = 1; // Search tab
          },
        ),
        // User Profile circle avatar thumbnail
        Container(
          margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
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
        ),
      ],
    );
  }

  Widget _buildStorageWidget() {
    double currentUsed = widget.state.storageUsedGb;
    double maxStorage = 128.0;
    double percentage = (currentUsed / maxStorage) * 100;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2229),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.02),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Title, Usage text, Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STORAGE USED',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}% Full',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Large Crimson numbers
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$currentUsed GB',
                  style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' / $maxStorage GB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sleek progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: Colors.white.withOpacity(0.1),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: currentUsed / maxStorage,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend dots
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE50914),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'FlixNoir',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Free Space',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadList(List<Movie> list) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = list[index];
        final bool isSelected = _selectedItemsToDelete.contains(movie.id);

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE50914).withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Checkbox visible during Edit Mode
              if (_isEditing)
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFFE50914),
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedItemsToDelete.add(movie.id);
                      } else {
                        _selectedItemsToDelete.remove(movie.id);
                      }
                    });
                  },
                ),

              // Thumbnail (mini poster gradient)
              InkWell(
                onTap: () {
                  widget.state.selectMovie(movie.id);
                  widget.onNavigateToDetails();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: movie.posterColors,
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Center(
                      child: movie.downloadState == DownloadState.downloading
                          ? const Icon(Icons.arrow_downward, color: Colors.white30, size: 18)
                          : const Icon(Icons.play_arrow, color: Colors.white54, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info Title & Metadata
              Expanded(
                child: InkWell(
                  onTap: () {
                    widget.state.selectMovie(movie.id);
                    widget.onNavigateToDetails();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${movie.genres.split(' • ').first} • ${movie.runtime}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusLabel(movie),
                    ],
                  ),
                ),
              ),

              // Right Action Buttons
              _buildRightActionButton(context, movie),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusLabel(Movie movie) {
    if (movie.downloadState == DownloadState.downloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFE50914), size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${movie.downloadSize} • Downloaded',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (movie.downloadState == DownloadState.downloading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${movie.downloadSize} • ${(movie.downloadProgress * 100).toInt()}% Downloading',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (movie.downloadState == DownloadState.expired) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: const Text(
              'Expired • Renew Required',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildRightActionButton(BuildContext context, Movie movie) {
    if (_isEditing) {
      return IconButton(
        icon: const Icon(Icons.delete_outline, color: Color(0xFFE50914), size: 20),
        onPressed: () {
          widget.state.toggleDownload(movie.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted download for "${movie.title}"')),
          );
        },
      );
    }

    if (movie.downloadState == DownloadState.downloaded) {
      return IconButton(
        icon: const Icon(Icons.play_circle_fill, color: Colors.white70, size: 24),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playing offline file for "${movie.title}"')),
          );
        },
      );
    } else if (movie.downloadState == DownloadState.downloading) {
      return InkWell(
        onTap: () {
          widget.state.toggleDownload(movie.id);
        },
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: movie.downloadProgress,
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              const Icon(Icons.close, color: Colors.white70, size: 14),
            ],
          ),
        ),
      );
    } else if (movie.downloadState == DownloadState.expired) {
      return IconButton(
        icon: const Icon(Icons.refresh, color: Color(0xFFE50914), size: 22),
        onPressed: () {
          widget.state.toggleDownload(movie.id);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.download_for_offline_outlined, size: 48, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            'No active or completed downloads.',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartDownloadsTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2229),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.settings_suggest_outlined, color: Color(0xFFE50914), size: 20),
        title: const Text(
          'Smart Downloads',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Automatically download next episodes and delete watched ones.',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
        value: widget.state.smartDownloadsEnabled,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFE50914),
        inactiveTrackColor: Colors.white24,
        onChanged: (val) {
          widget.state.toggleSmartDownloads();
        },
      ),
    );
  }

  Widget _buildFindMoreButton(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.state.activeNavBarIndex = 1; // Directs to Search tab
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Browse trending searches to download movies.')),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2229),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Find More to Download',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
