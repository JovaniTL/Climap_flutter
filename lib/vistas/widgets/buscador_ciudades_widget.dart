import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/clima_bloc.dart';
import '../../bloc/clima_event.dart';
import '../../bloc/clima_state.dart';
import '../../modelos/ciudad_modelo.dart';

class BuscadorCiudadesWidget extends StatefulWidget {
  const BuscadorCiudadesWidget({super.key});

  @override
  State<BuscadorCiudadesWidget> createState() => _BuscadorCiudadesWidgetState();
}

class _BuscadorCiudadesWidgetState extends State<BuscadorCiudadesWidget> {
  final TextEditingController _controladorTexto = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controladorTexto.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enviarBusqueda() {
    _debounce?.cancel();
    final texto = _controladorTexto.text.trim();
    _focusNode.unfocus();
    context.read<ClimaBloc>().add(ConsultarClimaPorTextoEvent(texto));
  }

  void _limpiarBusqueda() {
    _debounce?.cancel();
    _controladorTexto.clear();
    context.read<ClimaBloc>().add(const LimpiarSugerenciasEvent());
  }

  void _seleccionarCiudad(CiudadModelo ciudad) {
    _debounce?.cancel();
    _controladorTexto.text = ciudad.nombre;
    _focusNode.unfocus();
    context.read<ClimaBloc>().add(SeleccionarCiudadSugeridaEvent(ciudad));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClimaBloc, ClimaEstado>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _filaBusqueda(context),
            if (state.cargandoSugerencias)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (state.sugerencias.isNotEmpty)
              _ListaSugerencias(
                sugerencias: state.sugerencias,
                onSeleccionar: _seleccionarCiudad,
              ),
          ],
        );
      },
    );
  }

  Widget _filaBusqueda(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _controladorTexto,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onChanged: (valor) {
                _debounce?.cancel();
                if (valor.trim().length < 2) {
                  context.read<ClimaBloc>().add(const LimpiarSugerenciasEvent());
                  return;
                }
                final bloc = context.read<ClimaBloc>();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (!mounted) return;
                  bloc.add(BuscarSugerenciasEvent(valor));
                });
              },
              onSubmitted: (_) => _enviarBusqueda(),
              decoration: InputDecoration(
                hintText: 'Ingresa una ciudad (ej. Zitácuaro, Morelia)...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controladorTexto,
                  builder: (context, valor, _) {
                    if (valor.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: _limpiarBusqueda,
                    );
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _enviarBusqueda,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: const Row(
            children: [
              Icon(Icons.send_rounded, size: 18),
              SizedBox(width: 6),
              Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListaSugerencias extends StatelessWidget {
  final List<CiudadModelo> sugerencias;
  final ValueChanged<CiudadModelo> onSeleccionar;

  const _ListaSugerencias({
    required this.sugerencias,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(31),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: sugerencias.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ciudad = sugerencias[index];
            return ListTile(
              dense: true,
              leading: const Icon(
                Icons.location_on_outlined,
                color: Colors.blueAccent,
              ),
              title: Text(
                ciudad.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                ciudad.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onSeleccionar(ciudad),
            );
          },
        ),
      ),
    );
  }
}
