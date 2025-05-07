// lib/widgets/custom_animated_toggle_tab.dart
import 'package:flutter/material.dart';

class CustomAnimatedToggleTab extends StatefulWidget {
  final Function(int) callback;
  final List<String> tabTexts;
  final double width;
  final double height;
  final int initialIndex; // Ensure this parameter is defined

  const CustomAnimatedToggleTab({
    super.key,
    required this.callback,
    required this.tabTexts,
    required this.width,
    required this.height,
    this.initialIndex = 0, // Default to 0 if not provided
  });

  @override
  _CustomAnimatedToggleTabState createState() =>
      _CustomAnimatedToggleTabState();
}

class _CustomAnimatedToggleTabState extends State<CustomAnimatedToggleTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    // Set initial animation position based on initialIndex
    if (_selectedIndex == 1) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.callback(index);
    if (index == 0) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabWidth = widget.width / widget.tabTexts.length;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 255, 255),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: tabWidth * _animation.value,
                top: 0,
                child: Container(
                  width: tabWidth,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 67, 118, 199),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [],
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.tabTexts.length, (index) {
              return GestureDetector(
                onTap: () => _onTabTap(index),
                child: Container(
                  width: tabWidth,
                  height: widget.height,
                  alignment: Alignment.center,
                  child: Text(
                    widget.tabTexts[index],
                    style: TextStyle(
                      color:
                          _selectedIndex == index
                              ? Colors.white
                              : const Color.fromARGB(255, 114, 153, 214),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
