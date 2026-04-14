import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/bloc/student_bloc.dart';

void main() {
  runApp(const SamsApp());
}

class SamsApp extends StatelessWidget {
  const SamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentBloc()..add(const StudentRequested()),
      child: MaterialApp.router(
        title: 'SAMS Student Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
