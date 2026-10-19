import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/lang_service.dart';
import 'camera_view.dart';
import 'stamp_animation.dart';
import '../main.dart';

class CastleListView extends StatelessWidget {
  final List<Map<String, dynamic>> castles;
  final VoidCallback onCheckInComplete;

  const CastleListView({super.key, required this.castles, required this.onCheckInComplete});

  void _handleCastleTap(BuildContext context, Map<String, dynamic> castle) async {
    bool canCheckIn = false;

    if (kIsWeb) {
      canCheckIn = true;
    } else {
      try {
        Position pos = await LocationService().getCurrentLocation();
        canCheckIn = LocationService.isWithinFence(castle['latitude'], castle['longitude'], pos);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('定位失敗: $e')));
        canCheckIn = true;
      }
    }

    if (!context.mounted) return;

    if (canCheckIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraView(
            cameras: globalCameras,
            onPhotoTaken: (photoPath) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
// 修改後（大約在第 45 行附近，改餵 nameKey）
                  builder: (context) => StampAnimation(
                    nameKey: castle['nameKey'] ?? '', // 💡 將目前的 nameKey 傳遞給動畫
                    onComplete: () async {
                      await databaseInsertWebOrMobile(castle['id'], photoPath);
                      onCheckInComplete();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: castles.length,
      itemBuilder: (context, index) {
        final castle = castles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          color: const Color(0xFFF7F5F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Color(0xFFD9D4C7), width: 1)),
          child: ListTile(
            onTap: () => _handleCastleTap(context, castle),
            title: Text(
              AppLocalizations.of(context)!.translate(castle['nameKey'] ?? ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ID: ${castle['id']} | Region: ${castle['area']}'),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF8C8273)),
          ),
        );
      },
    );
  }
}
