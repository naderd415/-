import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/stock_provider.dart';
import 'localization/app_localizations.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockProvider(),
      child: Consumer<StockProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Offline Stock Closing',
            debugShowCheckedModeBanner: false,
            
            // Themes configuration
            themeMode: provider.themeMode,
            
            // Dark Theme - Sleek Slate & Teal Glow
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Colors.tealAccent,
                secondary: Colors.teal,
                background: Color(0xFF0F0F12),
                surface: Color(0xFF16161D),
              ),
              scaffoldBackgroundColor: const Color(0xFF0F0F12),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F0F12),
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
              ),
            ),
            
            // Light Theme - High Contrast Slate & Deep Teal
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.light(
                primary: Colors.teal,
                secondary: Colors.teal.shade700,
                background: Colors.grey.shade50,
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.grey.shade50,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey.shade50,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
              ),
            ),

            // Localization
            locale: provider.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },

            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
