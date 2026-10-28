// Datos: implementación del contrato que guarda en memoria.

import '../dominio/consumo.dart';
import 'consumo_repository.dart';

// Fuente de verdad mientras la app está abierta. Se pierde al cerrarla.
class MemoriaConsumoRepository implements ConsumoRepository {
  // Lista privada: solo este repositorio la modifica.
  final List<Consumo> _consumos = [];

  // Es async aunque responda al instante: una fuente real tardaría.
  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  // Copia que nadie puede modificar desde fuera.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}
