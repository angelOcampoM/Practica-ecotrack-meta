// Variante B: provider sobre el MISMO ConsumosViewModel de la variante A.
// Un ChangeNotifierProvider lo cuelga arriba de MaterialApp y los
// adaptadores lo piden al árbol: watch para mostrar, read para actuar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

// Raíz de la variante B. No guarda nada: provider es el dueño del ViewModel.
class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    // provider lo crea una sola vez y lo libera cuando sale del árbol.
    return ChangeNotifierProvider<ConsumosViewModel>(
      create: (_) => ConsumosViewModel(repositorio)..cargar(),
      child: MaterialApp(
        title: 'EcoTrack Meta',
        debugShowCheckedModeBanner: false,
        theme: temaEcoTrack,
        home: const PantallasEcoTrack(
          titulo: 'B · provider',
          // Los adaptadores no reciben nada por constructor.
          registro: RegistroProvider(),
          historial: HistorialProvider(),
          meta: MetaProvider(),
        ),
      ),
    );
  }
}

// Adaptador de Registro.
class RegistroProvider extends StatelessWidget {
  const RegistroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // watch para mostrar: este widget se redibuja cuando el ViewModel avisa.
    final vm = context.watch<ConsumosViewModel>();
    return FormularioRegistro(
      // read para actuar: dentro de un callback no se escucha.
      alGuardar: (laboratorio, litros) =>
          context.read<ConsumosViewModel>().guardar(laboratorio, litros),
      error: vm.error,
      guardando: vm.guardando,
    );
  }
}

// Adaptador de Historial.
class HistorialProvider extends StatelessWidget {
  const HistorialProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return ListaHistorial(consumos: vm.consumos, total: vm.total);
  }
}

// Adaptador de Meta.
class MetaProvider extends StatelessWidget {
  const MetaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return PanelMeta(
      usado: vm.total,
      meta: vm.meta,
      avance: vm.avance,
      superada: vm.metaSuperada,
      alSubir: () => context.read<ConsumosViewModel>().subirMeta(),
      alBajar: () => context.read<ConsumosViewModel>().bajarMeta(),
    );
  }
}
