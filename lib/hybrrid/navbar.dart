import 'package:flutter/material.dart';
import 'dart:ui';

class StreamXNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StreamXNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<StreamXNavBar> createState() => _StreamXNavBarState();
}

class _StreamXNavBarState extends State<StreamXNavBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: "Home",
    ),
    NavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: "Search",
    ),
    NavItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: "Favorites",
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: "Settings",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.02)).animate(
          CurvedAnimation(
            parent: _slideController,
            curve:
                Curves.easeInOut, // Changed from elasticOut to smooth easeInOut
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StreamXNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _triggerScreenChangeAnimation();
    }
  }

  void _triggerScreenChangeAnimation() {
    _slideController.forward().then((_) {
      _slideController.reverse();
    });
  }

  void _onItemTap(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value.dy * 8),
          child: Container(
            margin: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.00),
                        Colors.white.withOpacity(0.00),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Stack(
                      children: [
                        // Selection Indicator with smooth movement (no bounce)
                        AnimatedPositioned(
                          duration: const Duration(
                            milliseconds: 300,
                          ), // Smooth duration
                          curve: Curves
                              .easeInOut, // Changed from elasticOut to smooth easeInOut
                          left: _calculateIndicatorPosition(screenWidth),
                          top: 4,
                          child: Container(
                            width: _calculateItemWidth(screenWidth),
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.28),
                                  Colors.white.withOpacity(0.14),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.18),
                                  blurRadius: 14,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.12),
                                  blurRadius: 18,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Navigation Items
                        SizedBox(
                          height: 68,
                          child: Row(
                            children: _navItems.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final NavItem item = entry.value;
                              return _buildNavItem(
                                icon: item.icon,
                                activeIcon: item.activeIcon,
                                label: item.label,
                                index: index,
                                screenWidth: screenWidth,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateIndicatorPosition(double screenWidth) {
    final double availableWidth = screenWidth - 48;
    final double itemWidth = _calculateItemWidth(screenWidth);
    final double itemSpacing = availableWidth / 4;

    return (itemSpacing * widget.currentIndex) +
        ((itemSpacing - itemWidth) / 2);
  }

  double _calculateItemWidth(double screenWidth) {
    final double availableWidth = screenWidth - 48;
    return (availableWidth / 4) * 0.88;
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required double screenWidth,
  }) {
    final bool isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth transition
              SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 200,
                    ), // Faster, smoother transition
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey('${index}_${isSelected}'),
                      color: isSelected
                          ? Colors.red
                          : Colors.white.withOpacity(0.80),
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Label with smooth transition
              SizedBox(
                height: 14,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(
                      milliseconds: 200,
                    ), // Faster, smoother transition
                    curve: Curves.easeInOut, // Smooth curve
                    style: TextStyle(
                      fontSize: isSelected ? 10.5 : 9.5,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.78),
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({required this.icon, required this.activeIcon, required this.label});
}
