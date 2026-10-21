import 'package:flutter/material.dart';
import '../services/lang_service.dart';
import '../services/database_service.dart';
import 'area_complete_view.dart';

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
    // 💡 即時動態比對：滿足全收集，且資料庫記錄「尚未領取」時才亮起橫幅
    bool showBanner = false;
    if (_allCastles.isNotEmpty && widget.checkIns.isNotEmpty && !DatabaseService.instance.isChugokuBadgeClaimed) {
      final chugokuCastles = _allCastles.where((c) => c['area'] == 'Chugoku').toList();
      if (chugokuCastles.isNotEmpty) {
        showBanner = chugokuCastles.every((castle) =>
          widget.checkIns.any((checkIn) => checkIn['castleId'].toString().trim() == castle['id'].toString().trim())
        );
      }
    }

    return Column(
      children: [
        // 💡 榮譽勳章領取列（加入 showBanner 判斷）
        if (showBanner)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 28),
                    SizedBox(width: 8),
                    Text('中國地區已達成全收集！', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AreaCompleteView(
                          areaName: '中國地區',
                          onClose: () {
                            // 💡 關鍵點：使用者關閉制霸窗時，標記為已領取並重整介面
                            setState(() {
                              DatabaseService.instance.isChugokuBadgeClaimed = true;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium, size: 16),
                  label: const Text('領取勳章', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

        // 下方 100 名城集章網格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: 100,
            itemBuilder: (context, index) {
              final castleId = (index + 1).toString().padLeft(3, '0');
              final isChecked = widget.checkIns.any((c) => c['castleId'].toString().trim() == castleId);
              
              String nameKey = 'castle_okayama';
              if (_allCastles.isNotEmpty) {
                try {
                  final matched = _allCastles.firstWhere((c) => c['id'] == castleId);
                  nameKey = matched['nameKey'] ?? 'castle_okayama';
                } catch (_) {
                  if (castleId == '071') nameKey = 'castle_tottori';
                  if (castleId == '072') nameKey = 'castle_matsue';
                  if (castleId == '073') nameKey = 'castle_yonago';
                  if (castleId == '074') nameKey = 'castle_bitchu_matsuyama';
                }
              }

              return GestureDetector(
                onTap: isChecked ? () => _showDetailDialog(context, widget.checkIns.firstWhere((c) => c['castleId'].toString().trim() == castleId), nameKey) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.white : const Color(0xFFEBE9E4),
                    border: Border.all(color: isChecked ? const Color(0xFFC92A2A) : const Color(0xFFD9D4C7), width: isChecked ? 2 : 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: isChecked 
                      ? ClipOval(
                          child: Image.asset('assets/images/stamp_$nameKey.png', width: 65, fit: BoxFit.contain),
                        )
                      : Text(castleId, style: const TextStyle(color: Color(0xFF8C8273), fontWeight: FontWeight.bold)),
                ),
              ));
            },
          ),
        ),
      ],
    );
  }
}
