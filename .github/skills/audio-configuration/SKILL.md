---
name: audio-configuration
description: Configurar micrófono (record) y reproducción (SoLoud) para Gemini Live
---

# Configuración de Audio (Mic + SoLoud)

## Cuándo usar
Al inicializar audio para sesión de voz bidireccional.

## Regla fundamental
Mic y SoLoud DEBEN estar a **24000 Hz, mono, PCM 16-bit**.

## Micrófono (record)

```dart
RecordConfig(
  encoder: AudioEncoder.pcm16bits,
  sampleRate: 24000,
  numChannels: 1,
  echoCancel: true,
  noiseSuppress: true,
  autoGain: true,
  androidConfig: AndroidRecordConfig(
    audioSource: AndroidAudioSource.voiceCommunication,
  ),
  iosConfig: IosRecordConfig(
    categoryOptions: [
      IosAudioCategoryOption.defaultToSpeaker,
      IosAudioCategoryOption.allowBluetooth,
    ],
  ),
);
```

## Reproducción (SoLoud)

```dart
// Inicializar con misma tasa que el modelo
await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);

// Buffer stream para reproducción en tiempo real
var source = SoLoud.instance.setBufferStream(
  bufferingType: BufferingType.released,
  bufferingTimeNeeds: 0.1,
);
var handle = SoLoud.instance.play(source);

// Cuando llega audio del modelo:
SoLoud.instance.addAudioDataStream(source, audioBytes);
```

## Errores comunes
- Audio crackling: sample rate diferente entre mic y SoLoud.
- "invalid argument": usar AAC/MP4 en vez de PCM. Solución: `AudioEncoder.pcm16bits` con MIME `audio/pcm`.
