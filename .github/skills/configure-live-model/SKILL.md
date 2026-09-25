---
name: configure-live-model
description: Configurar LiveGenerativeModel con Gemini Live API para audio bidireccional
---

# Configuración del LiveGenerativeModel

## Cuándo usar
Cuando necesites crear una sesión de chat de voz en vivo con Gemini.

## Implementación

```dart
final LiveGenerativeModel _liveModel = FirebaseAI.vertexAI()
    .liveGenerativeModel(
      systemInstruction: Content.text('...'),
      model: 'gemini-live-2.5-flash-native-audio',
      liveGenerationConfig: LiveGenerationConfig(
        speechConfig: SpeechConfig(voiceName: 'Achernar'),
        responseModalities: [ResponseModalities.audio],
      ),
      tools: [
        Tool.functionDeclarations([/* herramientas */]),
      ],
    );
```

## Puntos clave
- Modelo: `gemini-live-2.5-flash-native-audio`
- `ResponseModalities.audio` para respuestas de voz.
- `SpeechConfig(voiceName: 'Achernar')` para voz en español.
- Las herramientas se declaran con `Tool.functionDeclarations(...)`.
