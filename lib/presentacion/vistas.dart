// Presentación: vistas tontas. Reciben datos y callbacks; no saben si
// arriba hay un ChangeNotifier por constructor o un gestor en el árbol.
// Solo conocen material.dart y la entidad del dominio.

import 'package:flutter/material.dart';

import '../dominio/consumo.dart';

// Tema oscuro compartido para que las dos variantes se vean igual.
final temaEcoTrack = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00ACC1),
    brightness: Brightness.dark,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
);

// Pestaña Registro: elegir laboratorio, escribir litros y guardar.
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  // Regresa true si el consumo se guardó.
  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  // Estado efímero: solo le importa a este formulario.
  String _laboratorio = laboratoriosUtez.first;
  final _litros = TextEditingController();

  @override
  void dispose() {
    _litros.dispose();
    super.dispose();
  }

  Future<void> _alTocarGuardar() async {
    final guardado = await widget.alGuardar(_laboratorio, _litros.text);
    // Después del await la pantalla pudo haberse cerrado.
    if (!mounted || !guardado) return;
    _litros.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Consumo guardado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Encabezado(
          icono: Icons.water_drop_outlined,
          titulo: 'Registrar consumo',
          detalle: 'Anota cuánta agua usó cada laboratorio.',
        ),
        const SizedBox(height: 28),
        DropdownButtonFormField<String>(
          initialValue: _laboratorio,
          decoration: const InputDecoration(
            labelText: 'Laboratorio',
            prefixIcon: Icon(Icons.science_outlined),
          ),
          items: [
            for (final laboratorio in laboratoriosUtez)
              DropdownMenuItem(value: laboratorio, child: Text(laboratorio)),
          ],
          onChanged: (laboratorio) {
            if (laboratorio != null) setState(() => _laboratorio = laboratorio);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('litros'),
          controller: _litros,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Litros',
            hintText: 'Ej. 12.5',
            suffixText: 'L',
            prefixIcon: const Icon(Icons.opacity),
            errorText: widget.error,
          ),
          onSubmitted: (_) {
            if (!widget.guardando) _alTocarGuardar();
          },
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          // Desactivado mientras el ViewModel guarda.
          onPressed: widget.guardando ? null : _alTocarGuardar,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: widget.guardando
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Pestaña Historial: el total arriba y una fila por consumo.
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({
    super.key,
    required this.consumos,
    required this.total,
  });

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;

    if (consumos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: esquema.outline),
            const SizedBox(height: 12),
            Text('Sin consumos', style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Lo que guardes en Registro aparecerá aquí.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: esquema.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final registros = consumos.length == 1
        ? '1 registro'
        : '${consumos.length} registros';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: esquema.primaryContainer,
          child: ListTile(
            leading: Icon(Icons.functions, color: esquema.onPrimaryContainer),
            title: Text(
              'Total: ${total.toStringAsFixed(1)} L',
              style: tema.textTheme.titleLarge?.copyWith(
                color: esquema.onPrimaryContainer,
              ),
            ),
            subtitle: Text(
              registros,
              style: TextStyle(color: esquema.onPrimaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final consumo in consumos)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: esquema.secondaryContainer,
                foregroundColor: esquema.onSecondaryContainer,
                child: const Icon(Icons.science_outlined),
              ),
              title: Text(consumo.laboratorio),
              trailing: Text(
                '${consumo.litros.toStringAsFixed(1)} L',
                style: tema.textTheme.titleMedium,
              ),
            ),
          ),
      ],
    );
  }
}

// Pestaña Meta: cuánto se ha usado contra la meta y botones para moverla.
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final color = superada ? esquema.error : esquema.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: avance,
                  minHeight: 12,
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(avance * 100).round()} % de la meta semanal',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: esquema.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      superada
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      superada ? 'Te pasaste de la meta' : 'Dentro de la meta',
                      style: tema.textTheme.titleMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('bajarMeta'),
                onPressed: alBajar,
                icon: const Icon(Icons.remove),
                label: const Text('Bajar meta'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                key: const Key('subirMeta'),
                onPressed: alSubir,
                icon: const Icon(Icons.add),
                label: const Text('Subir meta'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Armazón con AppBar, barra inferior de tres destinos y la pestaña elegida.
class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  // Estado efímero: qué pestaña se ve. A nadie más le importa.
  var _pestana = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      // IndexedStack mantiene montadas las tres pestañas y solo enseña una.
      body: IndexedStack(
        index: _pestana,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (indice) => setState(() => _pestana = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Registro',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Meta',
          ),
        ],
      ),
    );
  }
}

// Encabezado con ícono para la pestaña Registro.
class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: esquema.primaryContainer,
          foregroundColor: esquema.onPrimaryContainer,
          child: Icon(icono, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: tema.textTheme.titleLarge),
              Text(
                detalle,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: esquema.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
