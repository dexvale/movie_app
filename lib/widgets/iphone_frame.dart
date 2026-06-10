import 'package:flutter/material.dart';

class IPhoneFrame extends StatefulWidget {
  final Widget child;
  final String screenTitle;
  final VoidCallback onFocusPressed;
  final bool isFocused;

  const IPhoneFrame({
    super.key,
    required this.child,
    required this.screenTitle,
    required this.onFocusPressed,
    this.isFocused = false,
  });

  @override
  State<IPhoneFrame> createState() => _IPhoneFrameState();
}

class _IPhoneFrameState extends State<IPhoneFrame> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title Bar & Action
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.screenTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  widget.isFocused ? Icons.zoom_out_map : Icons.fullscreen,
                  color: const Color(0xFFE50914),
                  size: 18,
                ),
                tooltip: widget.isFocused ? 'Back to Ecosystem View' : 'Focus Screen',
                onPressed: widget.onFocusPressed,
              ),
            ],
          ),
        ),
        
        // The Device Frame
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(
                color: _isHovered || widget.isFocused
                    ? const Color(0xFFE50914)
                    : const Color(0xFF1F2229),
                width: 10,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered || widget.isFocused
                      ? const Color(0xFFE50914).withOpacity(0.3)
                      : Colors.black.withOpacity(0.6),
                  blurRadius: _isHovered || widget.isFocused ? 24 : 16,
                  spreadRadius: _isHovered || widget.isFocused ? 6 : 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Stack(
                children: [
                  // Child Screen
                  Positioned.fill(child: widget.child),
                  
                  // Status Bar (Top bar)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 44,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          const Text(
                            '12:12',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          
                          // Spacing for Dynamic Island
                          const SizedBox(width: 80),
                          
                          // System Icons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Icon(Icons.wifi, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Icon(Icons.battery_5_bar, color: Colors.white, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic Island Notch
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 110,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1F2229).withOpacity(0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F0F0F),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Home Indicator Bar
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 130,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
