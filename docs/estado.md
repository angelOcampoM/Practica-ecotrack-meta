# Gestión de estado — EcoTrack Meta

**Equipo:** Angel Ocampo
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa al armazón y cambia con `setState`. | `_PantallasEcoTrackState._pestana` en `lib/presentacion/vistas.dart` (`onDestinationSelected` de la `NavigationBar`). |
| Texto del campo de litros | Efímero: vive en el `State` del formulario y se limpia solo si `alGuardar` regresa `true`. | `TextEditingController _litros` en `_FormularioRegistroState` (`lib/presentacion/vistas.dart`), liberado en su `dispose()`. |
| consumos y meta | Compartido: un solo dueño que leen Registro, Historial y Meta. | Campos `consumos` y `meta` de `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`); prueba "Dato compartido" de etapa 4 y 5. |
| total y metaSuperada | Derivado: se calculan de `consumos` y `meta` cada vez, no se guardan. | Getters `double get total` y `bool get metaSuperada` de `ConsumosViewModel`; prueba "total, avance y metaSuperada se derivan de consumos y meta" (etapa 3). |
| Lo que regresa todos() | Persistido: es la fuente de verdad; el ViewModel solo reasigna su copia. | Lista privada `_consumos` de `MemoriaConsumoRepository` (`lib/datos/memoria_consumo_repository.dart`), que regresa `List.unmodifiable`; prueba "todos() no deja modificar la lista interna" (etapa 2). |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Un solo `ConsumosViewModel` creado en `_AppChangeNotifierState` llega a `RegistroCN`, `HistorialCN` y `MetaCN`; pasa "Dato compartido" en `test/etapa4_change_notifier_test.dart`. | Un solo `ChangeNotifierProvider<ConsumosViewModel>` arriba de `MaterialApp` en `AppProvider`; pasa "Dato compartido" en `test/etapa5_provider_test.dart`. |
| Capas | `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`; el error de `validarLitros` llega a la vista sin guardar nada (prueba "Capas", etapa 4; puntos 2 a 5 de `verificar_estado.sh` en OK). | Mismas vistas y mismo ViewModel: el commit `feat(variante-b)` solo toca `b_provider.dart` y `main.dart`; pasa "Capas" en etapa 5 y el punto 6 del script. |
| Encaje con el diagrama | Vista tonta → adaptador con `ListenableBuilder` → `ConsumosViewModel` → `ConsumoRepository`; el Observer es `notifyListeners()` + `ListenableBuilder` (`lib/variantes/a_change_notifier.dart`). | Vista tonta → adaptador con `context.watch`/`context.read` → el mismo `ConsumosViewModel` → `ConsumoRepository`; provider solo cambia el cable entre ViewModel y vista (`lib/variantes/b_provider.dart`). |
| Constructores que reciben vm | 3: `RegistroCN`, `HistorialCN` y `MetaCN` con `required this.vm`; una subpantalla de detalle en Meta sumaría uno más por cada nivel que lo pase. | 0: los adaptadores son `const RegistroProvider()`, `const HistorialProvider()` y `const MetaProvider()`; prueba "Los adaptadores piden el ViewModel al árbol, no al constructor". |
| Quién libera el ViewModel | Su creador: `_AppChangeNotifierState.dispose()` llama a `_vm.dispose()`; ningún adaptador lo libera. | `ChangeNotifierProvider` lo libera al salir del árbol; en `b_provider.dart` no escribimos ningún `dispose()`. |
| Costo de adoptarla ahora | Cero dependencias, pero cableado manual: cada pantalla nueva pide otro parámetro `vm` y otro `ListenableBuilder` en `a_change_notifier.dart`. | Una dependencia (`provider: ^6.1.5+1` en `pubspec.yaml`) y aprender `watch`/`read`; `b_provider.dart` se escribió sin cambiar `consumos_view_model.dart` ni `vistas.dart`. |
| Sustitución de la fuente de datos | `AppChangeNotifier(repositorio: RepositorioEspia([...]))` funciona sin tocar pantallas (prueba "Sustitución", etapa 4); solo `main_change_notifier.dart` importa `MemoriaConsumoRepository`. | `AppProvider(repositorio: RepositorioEspia([...]))` funciona igual (prueba "Sustitución", etapa 5); solo `main.dart` elige la fuente (punto 8 del script). |

## Elección

Elegimos: **B · provider** (`lib/main.dart` arranca `AppProvider`), porque con el mismo ViewModel y las mismas vistas baja de 3 a 0 los constructores que reciben `vm` y deja el `dispose()` en manos de `ChangeNotifierProvider`.
Se mantiene esta pieza del diagrama: `ConsumosViewModel` con las vistas tontas de `vistas.dart` y el contrato `ConsumoRepository`; no cambió ni una línea de ellos entre la etapa 4 y la 5.
Esta pieza es la que podría sustituirse después: la fuente de datos, `MemoriaConsumoRepository`, por una de disco o nube que implemente `ConsumoRepository`, cambiando solo `main.dart`, como ya lo demuestra `RepositorioEspia` en las pruebas de "Sustitución".
