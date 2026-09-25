---
name: process-responses
description: Procesar respuestas del modelo Live correctamente con un solo await for
---

# Procesamiento de Respuestas (receive)

## Cuándo usar
Al implementar el listener de respuestas del modelo en una sesión Live.

## APRENDIZAJE CRÍTICO

`receive()` en `LiveSession` usa un **broadcast stream** que hace `break` al recibir `turnComplete`.

## ❌ Patrón INCORRECTO (pierde eventos)

```dart
// MAL: El while re-suscribe y pierde eventos en el gap
while (shouldContinue) {
  await for (final response in _session.receive()) {
    await _handleMessage(response.message);
  }
}
```

## ✅ Patrón CORRECTO

```dart
Future<void> processMessagesContinuously({
  required StreamController<bool> stopSignal,
}) async {
  bool shouldContinue = true;
  stopSignal.stream.listen((stop) {
    if (stop) shouldContinue = false;
  });

  try {
    await for (final response in _session.receive()) {
      if (!shouldContinue) break;
      await _handleLiveServerMessage(response.message);
    }
  } catch (e) {
    log('Error: $e');
  }
}
```

## ¿Por qué?
Un solo `await for` mantiene la suscripción activa. No hay gap entre `turnComplete` y la siguiente respuesta del modelo.

## Manejo de mensajes

```dart
Future<void> _handleLiveServerMessage(LiveServerMessage response) async {
  if (response is LiveServerContent) {
    if (response.modelTurn != null) {
      _modelSpeaking = true;
      // Reproducir audio
    }
    if (response.turnComplete == true) {
      await Future.delayed(Duration(milliseconds: 300));
      _modelSpeaking = false;
    }
    if (response.interrupted == true) {
      _modelSpeaking = false;
      _clearAudioBuffer();
    }
  }

  if (response is LiveServerToolCall && response.functionCalls != null) {
    _modelSpeaking = false;
    await _handleLiveServerToolCall(response);
  }
}
```
