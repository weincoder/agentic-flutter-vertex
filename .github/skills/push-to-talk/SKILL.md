---
name: push-to-talk
description: Implementar push-to-talk con mic siempre encendido enviando silencio
---

# Push-to-Talk con Mic Siempre Encendido

## Cuándo usar
Para controlar cuándo el usuario habla sin cerrar el stream de audio.

## Concepto
El micrófono captura continuamente pero solo envía audio real cuando `_userSpeaking == true`. Cuando NO habla, se envía **silencio** (bytes en cero) para mantener el stream vivo.

## Implementación

```dart
_micSubscription = stream.listen((data) {
  final ctrl = _micStreamController;
  if (ctrl == null || ctrl.isClosed) return;

  if (_userSpeaking) {
    ctrl.add(data);                    // Audio real
  } else {
    ctrl.add(Uint8List(data.length));  // Silencio
  }
});
```

## ¿Por qué silencio y no pausar?
Pausar cierra el stream y **pierde la conexión** con Gemini. Enviar silencio mantiene el WebSocket activo.

## Interrupción del modelo (barge-in)

Cuando el usuario presiona mientras el modelo habla:

```dart
void _startRecording() {
  if (!_sessionOpened || _userSpeaking) return;

  if (_modelSpeaking) {
    _clearAudioBuffer();   // Parar la voz del modelo
    _modelSpeaking = false;
  }

  setState(() => _userSpeaking = true);
}

void _clearAudioBuffer() {
  final src = audioSrc;
  if (src != null && handle != null) {
    SoLoud.instance.setDataIsEnded(src);
    SoLoud.instance.stop(handle!);
    _setupAudioOutput();  // Re-crear buffer
  }
}
```
