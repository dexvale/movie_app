import 'package:flutter/material.dart';
import '../state/app_state.dart';

class UserProfile extends StatelessWidget {
  final AppState state;

  const UserProfile({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B0C10),
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Prominent Central Avatar
                _buildAvatar(context),
                const SizedBox(height: 16),

                // Username
                Text(
                  state.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Premium Badge
                _buildPremiumBadge(),
                const SizedBox(height: 24),

                // Watched / Watchlist Counters
                _buildCounterWidget(context),
                const SizedBox(height: 32),

                // Settings List
                _buildSettingsList(context),
                const SizedBox(height: 32),

                // Sign Out
                _buildSignOutButton(context),
                const SizedBox(height: 90), // Bottom nav space padding
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0B0C10),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accessing global app settings...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Glowing Circle Bezel
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE50914),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE50914).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFF1F2229),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE50914), Color(0xFF0F0C20)],
                  ),
                ),
                child: Center(
                  child: Text(
                    state.username.split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Edit Pencil overlay icon
          Positioned(
            bottom: 2,
            right: 2,
            child: InkWell(
              onTap: () => _showEditNameDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE50914),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE50914).withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.star,
            color: Color(0xFFE50914),
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            'PREMIUM MEMBER',
            style: TextStyle(
              color: Color(0xFFE50914),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Watched count box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2229),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.03),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${state.watchedCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'WATCHED',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Watchlist count box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2229),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.03),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${state.watchlistCount}',
                    style: const TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'WATCHLIST',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final List<_SettingsItem> items = [
      _SettingsItem(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        onTap: () => _showEditNameDialog(context),
      ),
      _SettingsItem(
        icon: Icons.bookmark_border,
        title: 'Watchlist',
        onTap: () {
          // Go to home, filter watchlist
          state.activeNavBarIndex = 0;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watchlist filtered in Home Dashboard!')),
          );
        },
      ),
      _SettingsItem(
        icon: Icons.settings_outlined,
        title: 'App Settings',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App configuration loaded.')),
          );
        },
      ),
      _SettingsItem(
        icon: Icons.help_outline,
        title: 'Help Center',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connecting to Help Center...')),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2229),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.04),
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(item.icon, color: Colors.white70, size: 20),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.2),
                    size: 14,
                  ),
                  onTap: item.onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signing out... reset watchlist state.')),
          );
          // Uncheck watchlist for demonstration
          for (var movie in state.movies) {
            if (movie.isInWatchlist && movie.id != 'aetheria') {
              state.toggleWatchlist(movie.id);
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: const Text(
            'Sign Out',
            style: TextStyle(
              color: Color(0xFFE50914),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final textController = TextEditingController(text: state.username);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2229),
          title: const Text('Edit Username', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new username',
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE50914)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE50914), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  state.updateUsername(textController.text);
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, required this.onTap});
}
