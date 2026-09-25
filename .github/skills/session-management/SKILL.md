---
name: session-management
description: Gestionar conexión y desconexión de sesiones Live con Gemini
---

# Gestión de Sesión (Connect/Disconnect)

## Cuándo usar
Al iniciar o finalizar una sesión de voz bidireccional.

## Conexión — Orden crítico

```dart
Future<void> _connectSession() async {
  // 1. Conectar sesión
  _session = await _liveModel.connect();
  _sessionOpened = true;

  // 2. Crear stream de mic y enviarlo
  _micStreamController = StreamController<Uint8List>();
  Stream<InlineDataPart> inlineDataStream = _micStreamController!.stream
      .map((data) => InlineDataPart('audio/pcm', data));
  _session.sendMediaStream(inlineDataStream);

  // 3. Iniciar captura de mic
  await _startMicStream();

  // 4. Configurar salida de audio (SoLoud)
  _setupAudioOutput();

  // 5. Escuchar respuestas del modelo
  unawaited(processMessagesContinuously(stopSignal: _stopController));
}
```

## Desconexión

```dart
Future<void> _disconnectSession() async {
  _userSpeaking = false;

  // Parar mic
  await _micSubscription?.cancel();
  await _recorder.stop();

  // Cerrar stream de mic
  await _micStreamController?.close();

  // Limpiar audio
  _teardownAudioOutput();

  // Cerrar sesión
  await _session.close();
  _stopController.add(true);
  await _stopController.close();
  _stopController = StreamController<bool>();
  _sessionOpened = false;
}
```

## Punto clave
El orden de conexión es crítico: **mic → audio output → listener**.
