import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modelos/clima_modelo.dart';
import 'monito_clima_widget.dart';

/// Muestra una notificación flotante animada en la parte superior de la pantalla
/// con el meme climático y recomendación principal de la ubicación consultada.
class NotificacionClimaOverlay {
  NotificacionClimaOverlay._();

  static OverlayEntry? _entradaActual;
  static Timer? _temporizador;

  /// Cierra la notificación actual si existe alguna en pantalla.
  static void cerrarActual() {
    _temporizador?.cancel();
    _temporizador = null;
    if (_entradaActual != null) {
      if (_entradaActual!.mounted) {
        _entradaActual!.remove();
      }
      _entradaActual = null;
    }
  }

  /// Muestra la notificación flotante animada para el [clima] consultado.
  static void mostrar(BuildContext context, ClimaModelo clima) {
    cerrarActual();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final navigatorContext =
        Navigator.maybeOf(context, rootNavigator: true)?.context ??
            overlay.context;

    HapticFeedback.lightImpact();

    final entrada = OverlayEntry(
      builder: (_) => _BannerNotificacionClima(
        clima: clima,
        onCerrar: cerrarActual,
        onTocar: () {
          cerrarActual();
          if (navigatorContext.mounted) {
            MonitoClimaWidget.mostrarMemeEnGrande(navigatorContext, clima);
          }
        },
      ),
    );

    _entradaActual = entrada;
    overlay.insert(entrada);
    _temporizador = Timer(const Duration(milliseconds: 4500), cerrarActual);
  }
}

class _BannerNotificacionClima extends StatefulWidget {
  final ClimaModelo clima;
  final VoidCallback onCerrar;
  final VoidCallback onTocar;

  const _BannerNotificacionClima({
    required this.clima,
    required this.onCerrar,
    required this.onTocar,
  });

  @override
  State<_BannerNotificacionClima> createState() =>
      _BannerNotificacionClimaState();
}

class _BannerNotificacionClimaState extends State<_BannerNotificacionClima>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<Offset> _desplazamiento;
  late final Animation<double> _opacidad;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curva = CurvedAnimation(
      parent: _controlador,
      curve: Curves.easeOutCubic,
    );
    _desplazamiento = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(curva);
    _opacidad = Tween<double>(begin: 0, end: 1).animate(curva);
    _controlador.forward();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datos = MonitoClimaWidget.obtenerDatos(widget.clima);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ciudad = widget.clima.nombreLugar.split(',').first;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SlideTransition(
              position: _desplazamiento,
              child: FadeTransition(
                opacity: _opacidad,
                child: Dismissible(
                  key: ValueKey(widget.clima.fechaConsulta),
                  direction: DismissDirection.up,
                  onDismissed: (_) => widget.onCerrar(),
                  child: Material(
                    elevation: 10,
                    color: theme.cardColor,
                    shadowColor: Colors.black.withValues(alpha: 0.28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: datos.colorFondo.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onTocar,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Encabezado estilo notificación móvil
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_rounded,
                                  size: 15,
                                  color: datos.colorFondo,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'CliMap • Alerta climática · Ahora',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    color: colorScheme.onSurfaceVariant,
                                    onPressed: widget.onCerrar,
                                    icon: const Icon(Icons.close_rounded),
                                    tooltip: 'Cerrar',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Cuerpo: miniatura del meme + texto
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    datos.rutaImagenAsset,
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 58,
                                        height: 58,
                                        color: datos.colorFondo,
                                        child: Icon(
                                          datos.iconoPrincipal,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${datos.etiquetaEstado} · $ciudad (${widget.clima.temperatura.round()}°C)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${datos.tituloAccion} — ${datos.descripcion}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
