import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'core/bootstrap/url_strategy_stub.dart'
    if (dart.library.html) 'core/bootstrap/url_strategy_web.dart' as url_strategy;
import 'core/services/env_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/bloc/theme/theme_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'shared/bloc/locale_bloc.dart';
import 'shared/bloc/student_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    url_strategy.configureWebUrlStrategy();
  }
  await loadEnvSafe(); // Loads .env safely for all platforms
  try {
    await Firebase.app().delete(); // Force re-init if already initialized
  } catch (_) {}
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize Firebase: $e'),
        ),
      ),
    ));
    return;
  }

  final authRepository = FirebaseAuthRepository();
  final authCubit = AuthCubit(repository: authRepository);
  try {
    await authCubit.bootstrap();
  } catch (e) {
    // Optionally show error UI or log
  }

  runApp(SamsApp(authCubit: authCubit));
}

class SamsApp extends StatelessWidget {
  const SamsApp({super.key, required this.authCubit});

  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocProvider.value(
        value: authCubit,
        child: _SamsAppView(authCubit: authCubit),
      ),
    );
  }
}

class _SamsAppView extends StatefulWidget {
  const _SamsAppView({required this.authCubit});

  final AuthCubit authCubit;

  @override
  State<_SamsAppView> createState() => _SamsAppViewState();
}

class _SamsAppViewState extends State<_SamsAppView> {
  late final _router = AppRouter.createRouter(widget.authCubit);

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
