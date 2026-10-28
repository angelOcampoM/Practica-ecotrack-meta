// Dominio: reglas de la meta semanal de litros. Dart puro.

// Meta con la que arranca la semana.
const metaInicial = 100.0;
// Cuánto sube o baja la meta con cada botón.
const pasoMeta = 10.0;
// La meta nunca puede quedar por debajo de este valor.
const metaMinima = 10.0;

// Suma el cambio a la meta actual sin bajar nunca de metaMinima.
double ajustarMeta(double actual, double cambio) {
  final nueva = actual + cambio;
  return nueva < metaMinima ? metaMinima : nueva;
}

// Fracción de la meta ya usada, entre 0 y 1. Si se rebasó, regresa 1.
double avanceDeMeta({required double total, required double meta}) {
  // Sin meta positiva no hay fracción que calcular: se evita dividir entre 0.
  if (meta <= 0) return total > 0 ? 1 : 0;
  return (total / meta).clamp(0, 1).toDouble();
}
