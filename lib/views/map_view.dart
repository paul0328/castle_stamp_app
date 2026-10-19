import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/lang_service.dart';

class CastleMapView extends StatefulWidget {
  final List<Map<String, dynamic>> castles;
  const CastleMapView({super.key, required this.castles});

  @override
  State<CastleMapView> createState() => _CastleMapViewState();
}

class _CastleMapViewState extends State<CastleMapView> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      color: const Color(0xFFF7F5F0), // 經典和紙基調色
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500), // 改用 constraints 來限制最大寬度
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD9D4C7), width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 頂部和風地圖標籤
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC92A2A), // 朱紅背景
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  loc != null ? loc.translate('castle_map') : '名城地圖',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 32),
              // 模擬真實地圖雷達的朱紅定位圈
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFC92A2A).withValues(alpha: 0.1),
                    ),
                  ),
                  const Icon(Icons.location_on, size: 54, color: Color(0xFFC92A2A)),
                ],
              ),
              const SizedBox(height: 32),
              // 動態語系轉換之城堡標題
              Text(
                loc != null ? loc.translate('castle_okayama') : '岡山城',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'N 34°39\'54.7" / E 133°56\'10.3"',
                style: TextStyle(color: Color(0xFF8C8273), fontSize: 14, fontStyle: FontStyle.italic, letterSpacing: 1),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Color(0xFFEBE9E4), thickness: 1),
              ),
              // 底部地理圍欄狀態狀態列
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    kIsWeb ? '網頁模擬定位已就緒 (500m 圍欄內)' : 'GPS 衛星定位中',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
