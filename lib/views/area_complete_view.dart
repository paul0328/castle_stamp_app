import 'package:flutter/material.dart';

class AreaCompleteView extends StatelessWidget {
  final String areaName;
  final VoidCallback onClose;

  const AreaCompleteView({super.key, required this.areaName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // 極具暗色質感的曜變黑漆背景
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 完全制霸金色大勳章主體
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // 外圍奢華金箔光暈
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  // 💡 讀取您剛剛放入的實體 AI 金色大徽章圖檔
                  child: Image.asset(
                    'assets/images/area_badge_chugoku.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                
                // 2. 榮譽文字軌
                Text(
                  '$areaName 完全制霸',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Color(0xFFFFD700), // 經典盛上金箔色
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '已成功收集該地區所有名城之朱印落款',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 56),
                
                // 3. 和風收下按鈕
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700), // 金黃色
                    foregroundColor: const Color(0xFF141414), // 深色字
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // 方正和風剪裁
                    ),
                    elevation: 5,
                  ),
                  onPressed: onClose,
                  child: const Text(
                    '收下勳章',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
