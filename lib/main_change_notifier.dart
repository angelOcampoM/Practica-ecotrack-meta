// Arranque de la variante A (ChangeNotifier puro).
//   flutter run -t lib/main_change_notifier.dart

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/a_change_notifier.dart';

void main() {
  // Junto con main.dart, el único lugar que elige la fuente de datos.
  runApp(AppChangeNotifier(repositorio: MemoriaConsumoRepository()));
}
