// lib/main.dart (Simplified - No GraphQL)
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mkobasmart_app/provider/auth_provider.dart';
import 'package:mkobasmart_app/provider/budget_provider.dart';
import 'package:mkobasmart_app/provider/category_provider.dart';
import 'package:mkobasmart_app/provider/debt_provider.dart';
import 'package:mkobasmart_app/provider/otp_provider.dart';
import 'package:mkobasmart_app/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

import 'themes/theme_provider.dart';
import 'themes/app_theme.dart';
import 'localization/app_localizations.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MkobaSmartApp());
}

class MkobaSmartApp extends StatelessWidget {
  const MkobaSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), 
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MkobaSmart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('sw', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
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
              return const Locale('en');
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}