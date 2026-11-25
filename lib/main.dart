import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/clima_bloc.dart';
import 'bloc/comparacion_cubit.dart';
import 'config/tema/app_tema.dart';
import 'servicios/clima_api_servicio.dart';
import 'vistas/pantalla_principal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiAplicacionClima());
}

class MiAplicacionClima extends StatefulWidget {
  const MiAplicacionClima({super.key});

  @override
  State<MiAplicacionClima> createState() => _MiAplicacionClimaState();
}

class _MiAplicacionClimaState extends State<MiAplicacionClima> {
  final _servicio = ClimaApiServicio();

  @override
  void dispose() {
    _servicio.cerrar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ClimaBloc>(create: (_) => ClimaBloc(servicio: _servicio)),
        BlocProvider<ComparacionCubit>(
          create: (_) => ComparacionCubit(servicio: _servicio),
        ),
      ],
      child: MaterialApp(
        title: 'App Clima',
        debugShowCheckedModeBanner: false,
        theme: const AppTema(brillo: Brightness.light).getTema(),
        darkTheme: const AppTema(brillo: Brightness.dark).getTema(),
        themeMode: ThemeMode.system,
        home: PantallaPrincipal(servicio: _servicio),
      ),
    );
  }
}
