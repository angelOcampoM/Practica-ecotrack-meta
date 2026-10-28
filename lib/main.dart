// Arranque principal: variante B (provider).
//   flutter run

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/b_provider.dart';

void main() {
  // Junto con main_change_notifier.dart, el único lugar que elige la fuente
  // de datos.
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}
