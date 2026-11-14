import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getdatabacken/screens/auth_gate.dart';
import '../providers/color_notifer_provider.dart';
import '../providers/theme_notifier_provider.dart';

List<Color> colorList = const [
  Color(0xFF2E7D32), // បៃតង (លំនាំដើម)
  Color(0xFF00796B), // Teal
  Color(0xFF1565C0), // ខៀវ
  Color(0xFFE65100), // ទឹកក្រូច
  Color(0xFFC62828), // ក្រហម
  Color(0xFF6A1B9A), // ស្វាយ
  Color(0xFFAD1457), // ផ្កាឈូក
  Color(0xFF37474F), // ប្រផេះខៀវ
  Color(0xFF4E342E), // ប្រាក់
  Color(0xFF827717), // លឿងស្រាល
  Color(0xFF00838F), // ខៀវស្រាល
  Color(0xFF5D4037), // ប្រាក់ស្រាល
  Color(0xFF1A237E), // ខៀវខ្ពស់
  Color(0xFF880E4F), // ផ្កាឈូក
  Color(0xFF263238), // ប្រផេះខ្មៅ

];



  ThemeData buildTheme(Color seed, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: scheme.primary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surface,
      selectedColor: scheme.primary,
      showCheckmark: false,
    ),
  );
}
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool dark = ref.watch(themeNotifierProvider);
    int index = ref.watch(colorNotifierProvider);
    Color seedColor = colorList[index % colorList.length];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: buildTheme(seedColor, Brightness.light),
      darkTheme: buildTheme(seedColor, Brightness.dark),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
                return MaterialPageRoute(builder: (context) => const AuthGate());

          // case '/detail':
          //   return MaterialPageRoute(
          //     builder: (context) => DetailScreen(),
          //     settings: settings,
          //   );
          // case '/add':
          //   return MaterialPageRoute(builder: (context) => StudentAddScreen());
          // case '/edit':
          //   return MaterialPageRoute(
          //     builder: (context) => StudentEditScreen(),
          //     settings: settings,
          //   );
          default:
            return MaterialPageRoute(
              builder: (context) => Text("No Screen Found"),
            );
        }
      },
    );
  }
}
