import 'package:flutter/material.dart';
import '../services/lang_service.dart';
import '../services/database_service.dart';

class NotebookView extends StatefulWidget {
  final List<Map<String, dynamic>> checkIns;
  const NotebookView({super.key, required this.checkIns});

  @override
  State<NotebookView> createState() => _NotebookViewState();
}

class _NotebookViewState extends State<NotebookView> {
  List<Map<String, dynamic>> _allCastles = [];

  @override
  void initState() {
    super.initState();
    _loadCastleData();
  }

  // 💡 內建動態加載，徹底解決跨畫面狀態不同步的問題
  Future<void> _loadCastleData() async {
    final castles = await DatabaseService.instance.fetchCastles();
    if (mounted) {
      setState(() {
        _allCastles = castles;
      });
    }
  }

  void _showDetailDialog(BuildContext context, Map<String, dynamic> checkIn, String nameKey) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7F5F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFD9D4C7))),
        title: Text('${checkIn['castleId']} ${loc != null ? loc.translate('cert_title') : '登城證明'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset('assets/images/stamp_$nameKey.png', width: 120, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text('${loc != null ? loc.translate('cert_time') : '登城時間：'}${checkIn['checkInTime']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: 100,
      itemBuilder: (context, index) {
        final castleId = (index + 1).toString().padLeft(3, '0');
        final isChecked = widget.checkIns.any((c) => c['castleId'] == castleId);
        
        // 💡 依據 ID 從本地載入的資料庫中比對 nameKey
        String nameKey = 'castle_okayama';
        if (_allCastles.isNotEmpty) {
          try {
            final matched = _allCastles.firstWhere((c) => c['id'] == castleId);
            nameKey = matched['nameKey'] ?? 'castle_okayama';
          } catch (_) {
            // 如果比對失敗，動態依據常規邏輯組合名稱
            if (castleId == '071') nameKey = 'castle_tottori';
            if (castleId == '072') nameKey = 'castle_matsue';
            if (castleId == '073') nameKey = 'castle_yonago';
            if (castleId == '074') nameKey = 'castle_bitchu_matsuyama';
          }
        } else {
          // 資料庫非同步載入中的安全降級防線
          if (castleId == '071') nameKey = 'castle_tottori';
          if (castleId == '072') nameKey = 'castle_matsue';
          if (castleId == '073') nameKey = 'castle_yonago';
          if (castleId == '074') nameKey = 'castle_bitchu_matsuyama';
        }

        return GestureDetector(
          onTap: isChecked ? () => _showDetailDialog(context, widget.checkIns.firstWhere((c) => c['castleId'] == castleId), nameKey) : null,
          child: Container(
            decoration: BoxDecoration(
              color: isChecked ? Colors.white : const Color(0xFFEBE9E4),
              border: Border.all(color: isChecked ? const Color(0xFFC92A2A) : const Color(0xFFD9D4C7), width: isChecked ? 2 : 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: isChecked 
                ? ClipOval(
                    child: Image.asset('assets/images/stamp_$nameKey.png', width: 55, fit: BoxFit.cover),
                  )
                : Text(castleId, style: const TextStyle(color: Color(0xFF8C8273), fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
