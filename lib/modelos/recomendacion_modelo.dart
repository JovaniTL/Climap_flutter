import 'package:flutter/material.dart';

/// Modelo para mostrar tarjetas y chips de recomendaciones de acuerdo al clima actual.
class RecomendacionModelo {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;

  const RecomendacionModelo({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
  });
}

