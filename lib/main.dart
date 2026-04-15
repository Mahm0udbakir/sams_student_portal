import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/bloc/theme/theme_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/bloc/locale_bloc.dart';
import 'shared/bloc/student_bloc.dart';

void main() {
  runApp(const SamsApp());
}

class SamsApp extends StatelessWidget {
  const SamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: const _SamsAppView(),
    );
  }
}

class _SamsAppView extends StatefulWidget {
  const _SamsAppView();

  @override
  State<_SamsAppView> createState() => _SamsAppViewState();
}

class _SamsAppViewState extends State<_SamsAppView> {
  late final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StudentBloc()..add(const StudentRequested()),
        ),
        BlocProvider(create: (_) => LocaleBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: locale.languageCode == 'ar'
                    ? 'بوابة طلاب سامز'
                    : 'SAMS Student Portal',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                themeAnimationDuration: const Duration(milliseconds: 360),
                themeAnimationCurve: Curves.easeInOutCubic,
                locale: locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: _router,
              );
            },
          );
        },
      ),
    );
  }
}
