// Dominio: la entidad Consumo y la regla de los litros.
// Dart puro: si se apaga Flutter, esto sigue teniendo sentido.

// Laboratorios donde se registra consumo. Es una constante, no estado:
// nunca cambia mientras corre la app.
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

// Un consumo de agua registrado en un laboratorio.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

// Tope de litros que se aceptan en un solo registro.
const _topeLitros = 10000;

// Regresa el mensaje de error o null si los litros son válidos.
// Las reglas se revisan en orden: no es número, menor o igual a cero, tope.
String? validarLitros(double? litros) {
  if (litros == null || litros.isNaN) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > _topeLitros) return 'Los litros superan el tope de $_topeLitros';
  return null;
}
