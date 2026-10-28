// Variante A: ChangeNotifier puro, sin paquetes extra.
// El ViewModel viaja por constructor y cada adaptador lo escucha
// con ListenableBuilder.

import 'package:flutter/material.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

// Dueño del ViewModel: lo crea una vez, lo carga y lo libera.
class AppChangeNotifier extends StatefulWidget {
  const AppChangeNotifier({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  State<AppChangeNotifier> createState() => _AppChangeNotifierState();
}

class _AppChangeNotifierState extends State<AppChangeNotifier> {
  // En el State y no en build: si no, cada redibujo crearía uno nuevo.
  late final _vm = ConsumosViewModel(widget.repositorio);

  @override
  void initState() {
    super.initState();
    _vm.cargar();
  }

  @override
  void dispose() {
    // Quien crea el ViewModel es quien lo libera.
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack Meta',
      debugShowCheckedModeBanner: false,
      theme: temaEcoTrack,
      home: PantallasEcoTrack(
        titulo: 'A · ChangeNotifier',
        // Las tres pestañas reciben el MISMO ViewModel.
        registro: RegistroCN(vm: _vm),
        historial: HistorialCN(vm: _vm),
        meta: MetaCN(vm: _vm),
      ),
    );
  }
}

// Adaptador de Registro: escucha al ViewModel y entrega datos y callbacks.
class RegistroCN extends StatelessWidget {
  const RegistroCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => FormularioRegistro(
        alGuardar: vm.guardar,
        error: vm.error,
        guardando: vm.guardando,
      ),
    );
  }
}

// Adaptador de Historial.
class HistorialCN extends StatelessWidget {
  const HistorialCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) =>
          ListaHistorial(consumos: vm.consumos, total: vm.total),
    );
  }
}

// Adaptador de Meta.
class MetaCN extends StatelessWidget {
  const MetaCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => PanelMeta(
        usado: vm.total,
        meta: vm.meta,
        avance: vm.avance,
        superada: vm.metaSuperada,
        alSubir: vm.subirMeta,
        alBajar: vm.bajarMeta,
      ),
    );
  }
}
