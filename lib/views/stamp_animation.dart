import 'package:flutter/material.dart';
import '../services/lang_service.dart';

class StampAnimation extends StatefulWidget {
  final String nameKey; // 💡 改為傳入 nameKey
  final VoidCallback onComplete;
  const StampAnimation({super.key, required this.nameKey, required this.onComplete});

  @override State<StampAnimation> createState() => _StampAnimationState();
}

class _StampAnimationState extends State<StampAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _inkOpacity;
  late Animation<double> _stampScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
    _inkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.57, curve: Curves.easeIn)));
    _stampScale = Tween<double>(begin: 4.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.57, 1.0, curve: Curves.bounceOut)));
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: _inkOpacity.value, child: Image.asset('assets/images/ink_wash.png', width: 320)),
                if (_controller.value < 0.57)
                  Text(loc != null ? loc.translate('ink_writing') : '揮毫中...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.8), letterSpacing: 4)),
                if (_controller.value > 0.57)
                  Transform.scale(
                    scale: _stampScale.value,
                    child: ClipOval(
                      // 💡 依據方案 B 規格動態組合檔名
                      child: Image.asset('assets/images/stamp_${widget.nameKey}.png', width: 140, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
