import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'services/database_service.dart';
import 'services/lang_service.dart';
import 'views/list_view.dart';
import 'views/map_view.dart';
import 'views/notebook_view.dart';

late List<CameraDescription> globalCameras;

Future<void> databaseInsertWebOrMobile(String castleId, String photoPath) async {
  final cleanId = castleId.trim(); // 確保無任何隱形換行或空格
  await DatabaseService.instance.insertCheckIn({
    'castleId': cleanId,
    'checkInTime': DateTime.now().toString().split('.').first,
    'photoPath': photoPath,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { globalCameras = await availableCameras(); } catch (e) { globalCameras = []; }
  await DatabaseService.instance.database;
  runApp(const CastleStampApp());
}

class CastleStampApp extends StatefulWidget {
  const CastleStampApp({super.key});
  static void setLocale(BuildContext context, Locale newLocale) {
    _CastleStampAppState? state = context.findAncestorStateOfType<_CastleStampAppState>();
    state?.changeLocale(newLocale);
  }
  @override State<CastleStampApp> createState() => _CastleStampAppState();
}

class _CastleStampAppState extends State<CastleStampApp> {
  Locale _locale = const Locale('zh');
  void changeLocale(Locale locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日本名城朱印收集手札',
      theme: ThemeData(primaryColor: const Color(0xFFC92A2A)),
      locale: _locale,
      supportedLocales: const [Locale('zh'), Locale('ja'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
      ],
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _castles = [];
  List<Map<String, dynamic>> _checkIns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final castles = await DatabaseService.instance.fetchCastles();
    final checkIns = await DatabaseService.instance.fetchCheckIns();
    setState(() { _castles = castles; _checkIns = checkIns; });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final List<Widget> pages = [
      CastleListView(castles: _castles, onCheckInComplete: _loadData), 
      CastleMapView(castles: _castles), 
      NotebookView(checkIns: _checkIns), 
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc != null ? loc.translate('app_title') : '日本100名城收集手札', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7F5F0),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 1,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) => CastleStampApp.setLocale(context, locale),
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('zh'), child: Text('繁體中文')),
              PopupMenuItem(value: Locale('ja'), child: Text('日本語')),
              PopupMenuItem(value: Locale('en'), child: Text('English')),
            ],
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFC92A2A),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.fort), label: loc != null ? loc.translate('castle_list') : '名城列表'),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: loc != null ? loc.translate('castle_map') : '名城地圖'),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: loc != null ? loc.translate('notebook') : '御朱印帳'),
        ],
      ),
    );
  }
}
