import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;

  const VideoPlayerScreen({
    super.key,
    required this.movie,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPlaying = true;
  double _currentSeconds = 0.0;
  final double _totalSeconds = 8040.0; // 2 hours, 14 minutes default
  Timer? _playbackTimer;
  Timer? _loadTimer;
  bool _isMuted = false;
  double _volume = 0.8;
  double _playbackSpeed = 1.0;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  
  // Animation for neon scanline effect in video player
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.1, end: 0.35).animate(_pulseController);

    // Simulate video buffering/loading
    _loadTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startPlaybackTimer();
        _startHideControlsTimer();
      }
    });
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && !_isLoading && mounted) {
        setState(() {
          if (_currentSeconds < _totalSeconds) {
            _currentSeconds += _playbackSpeed;
          } else {
            _isPlaying = false;
            _playbackTimer?.cancel();
          }
        });
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_isLoading) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _showControls = true;
    });
    if (_isPlaying) {
      _startPlaybackTimer();
      _startHideControlsTimer();
    } else {
      _playbackTimer?.cancel();
      _hideControlsTimer?.cancel();
    }
  }

  void _seekRelative(double seconds) {
    setState(() {
      _currentSeconds = (_currentSeconds + seconds).clamp(0.0, _totalSeconds);
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  void _changeSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final currentIdx = speeds.indexOf(_playbackSpeed);
    final nextIdx = (currentIdx + 1) % speeds.length;
    setState(() {
      _playbackSpeed = speeds[nextIdx];
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  String _formatDuration(double seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = (seconds % 60).toInt();
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _loadTimer?.cancel();
    _hideControlsTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdrop = widget.movie.backdropPath;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 1. Simulated Video Feed background
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdrop != null)
                    Image.network(
                      '${ApiService.imageBaseUrlUrlOriginal}$backdrop',
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.movie.posterColors,
                        ),
                      ),
                    ),
                  
                  // Scanning micro-animation overlay (cyberpunk ambient style)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0C10).withOpacity(0.4),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, _pulseAnimation.value, 1.0],
                            colors: [
                              Colors.transparent,
                              const Color(0xFFE50914).withOpacity(0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Overall dark vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.95),
                        ],
                        radius: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Loading / Buffering Spinner Overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Buffering Digital Stream...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Establishing secure connection to TMDB servers',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Playback Controls Overlay
            if (!_isLoading)
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // A. Top Action Bar
                          _buildTopBar(context),

                          // B. Middle Player Actions
                          _buildMiddleControls(),

                          // C. Bottom Progress Seekbar and Subtitles Row
                          _buildBottomControls(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          
          // Title / Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.movie.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          '1080P',
                          style: TextStyle(color: Color(0xFFE50914), fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HDR • DOLBY ATMOS 5.1',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Subtitles/Audio Select mockup
          IconButton(
            icon: const Icon(Icons.subtitles_outlined, color: Colors.white, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio: English [Original] • Subtitles: English [CC]'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek backward 10s
        InkWell(
          onTap: () => _seekRelative(-10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.replay_10, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(width: 32),

        // Large Play / Pause button
        InkWell(
          onTap: _togglePlayPause,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE50914).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Seek forward 10s
        InkWell(
          onTap: () => _seekRelative(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forward_10, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    double progressPercent = (_currentSeconds / _totalSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seekbar slider
          Row(
            children: [
              Text(
                _formatDuration(_currentSeconds),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFE50914),
                    inactiveTrackColor: Colors.white.withOpacity(0.25),
                    thumbColor: const Color(0xFFE50914),
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                    value: _currentSeconds,
                    min: 0.0,
                    max: _totalSeconds,
                    onChanged: (value) {
                      setState(() {
                        _currentSeconds = value;
                        _showControls = true;
                      });
                      _startHideControlsTimer();
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_totalSeconds - _currentSeconds),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
          
          // Audio / Speed and Toggles Bottom Row
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Volume controller
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isMuted || _volume == 0
                            ? Icons.volume_off
                            : _volume < 0.4
                                ? Icons.volume_down
                                : Icons.volume_up,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                          _showControls = true;
                        });
                        _startHideControlsTimer();
                      },
                    ),
                    SizedBox(
                      width: 70,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          thumbColor: Colors.white,
                          trackHeight: 2.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                        ),
                        child: Slider(
                          value: _isMuted ? 0.0 : _volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) {
                            setState(() {
                              _volume = val;
                              _isMuted = val == 0.0;
                              _showControls = true;
                            });
                            _startHideControlsTimer();
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Speed Controller & Picture-in-picture Mockup
                Row(
                  children: [
                    // Playback speed selection button
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: _changeSpeed,
                      child: Text(
                        '${_playbackSpeed}x',
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Expand / rotate helper icon
                    IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
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
}
