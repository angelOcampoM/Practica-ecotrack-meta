// Datos: contrato de la fuente de consumos.
// Habla como el dominio (guardar, todos); no dice si es lista, JSON o HTTP.

import '../dominio/consumo.dart';

// Cualquier fuente de datos (memoria, disco, nube) que cumpla esto sirve.
abstract class ConsumoRepository {
  // Guarda un consumo en la fuente de verdad.
  Future<void> guardar(Consumo consumo);

  // Regresa todos los consumos guardados, en el orden en que llegaron.
  Future<List<Consumo>> todos();
}
