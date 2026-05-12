import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Local development can run without a committed .env file.
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = FirebaseAuthRepository();
  final authCubit = AuthCubit(repository: authRepository);
  await authCubit.bootstrap();

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
