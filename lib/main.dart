import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/clima_bloc.dart';
import 'bloc/comparacion_cubit.dart';
import 'vistas/pantalla_principal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiAplicacionClima());
}

/// Punto de entrada de la aplicación.
/// Inyecta los BLoCs globales (ClimaBloc y ComparacionCubit) para que estén
/// disponibles en cualquier pantalla.
class MiAplicacionClima extends StatelessWidget {
  const MiAplicacionClima({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ClimaBloc>(
          create: (_) => ClimaBloc(),
        ),
        BlocProvider<ComparacionCubit>(
          create: (_) => ComparacionCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'App Clima',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const PantallaPrincipal(),
      ),
    );
  }
}
