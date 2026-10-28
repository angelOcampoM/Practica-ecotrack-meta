# EcoTrack Meta — `ChangeNotifier` y provider desde cero

App Flutter (tema oscuro) con tres pestañas que comparten el mismo dato:
**Registro** guarda un consumo, **Historial** lista los consumos y su total, y
**Meta** compara ese total con una meta semanal que se sube y se baja.

El mismo `ConsumosViewModel` se cablea dos veces:

- **A · ChangeNotifier:** el ViewModel viaja por constructor y se escucha con `ListenableBuilder` (`lib/variantes/a_change_notifier.dart`).
- **B · provider:** el ViewModel se cuelga con `ChangeNotifierProvider` y se pide con `context.watch` / `context.read` (`lib/variantes/b_provider.dart`).

La comparación con evidencia está en [`docs/estado.md`](docs/estado.md).

## Cómo correrlo

```bash
flutter pub get
flutter test                               # 35 pruebas
bash verificar_estado.sh                   # todo en OK
flutter run                                # variante B (provider)
flutter run -t lib/main_change_notifier.dart   # variante A (ChangeNotifier)
```

## Estructura

```
lib/
├── dominio/        consumo.dart, meta.dart (Dart puro)
├── datos/          consumo_repository.dart (contrato), memoria_consumo_repository.dart
├── presentacion/   consumos_view_model.dart, vistas.dart (vistas tontas)
├── variantes/      a_change_notifier.dart, b_provider.dart
├── main_change_notifier.dart
└── main.dart
docs/estado.md
```

## Puntuación

| Concepto | Resultado | Puntos |
|---|---|---|
| Etapa 1 en verde | 10/10 pruebas | 1 |
| Etapa 2 en verde | 4/4 pruebas | 1 |
| Etapa 3 en verde | 11/11 pruebas | 2 |
| Etapa 4 en verde | 5/5 pruebas | 2 |
| Etapa 5 en verde | 5/5 pruebas | 2 |
| `verificar_estado.sh` todo en OK | todo OK | 1 |
| `docs/estado.md` con evidencia en cada celda | lleno | 1 |
| **Total** | **35/35 pruebas** | **10** |

`test/` y `verificar_estado.sh` son los del kit, sin modificar.
