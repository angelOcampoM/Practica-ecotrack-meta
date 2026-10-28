// Presentación: ViewModel de consumos y meta semanal.
// Es el único dueño del estado compartido. Avisa con notifyListeners(),
// no dibuja y no sabe de dónde salen los datos: solo conoce el contrato.

// foundation.dart y no material.dart: el ViewModel no dibuja.
import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  // Recibe el contrato por constructor; nunca crea un repositorio.
  ConsumosViewModel(ConsumoRepository repositorio) : _repositorio = repositorio;

  final ConsumoRepository _repositorio;

  // Estado compartido: lo leen las tres pestañas.
  List<Consumo> consumos = const [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // Estado derivado: se calcula cada vez, no se guarda.
  double get total =>
      consumos.fold<double>(0, (suma, consumo) => suma + consumo.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  // Lee la fuente de verdad y avisa.
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  // Valida con el dominio, guarda en el repositorio y regresa true si se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    // Acepta coma decimal y espacios: " 12,5 " se lee como 12.5.
    final litros = double.tryParse(litrosTexto.trim().replaceAll(',', '.'));
    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      await _repositorio.guardar(
        Consumo(laboratorio: laboratorio, litros: litros!),
      );
      // Se reasigna con lo que regresa la fuente de verdad, no se agrega a mano.
      consumos = await _repositorio.todos();
    } finally {
      guardando = false;
      notifyListeners();
    }
    return true;
  }

  // El mínimo lo decide ajustarMeta en el dominio, no el ViewModel.
  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
