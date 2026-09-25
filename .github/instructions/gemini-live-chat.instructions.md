---
applyTo: "voice_flutter/**"
---

# Instrucciones: Chat en Vivo con Gemini Live API (Flutter)

## Contexto

Este proyecto implementa un chat de voz bidireccional con **Gemini Live API** (`gemini-live-2.5-flash-native-audio`) usando `firebase_ai` en Flutter. El archivo de referencia es `audio_app_manager_demo.dart`.

## Arquitectura

```
┌──────────────┐     PCM audio      ┌──────────────────┐
│  Micrófono   │ ──────────────────► │                  │
│  (record)    │   sendMediaStream   │  Gemini Live     │
│              │                     │  Session          │
│  SoLoud     │ ◄────────────────── │  (WebSocket)     │
│  (playback)  │   receive() stream  │                  │
└──────────────┘                     └──────────────────┘
       ▲                                    │
       │                                    ▼
       │                            ┌──────────────────┐
       │                            │  Tool Calls      │
       │                            │  (Function Calls)│
       │                            └──────┬───────────┘
       │                                   │
       │                                   ▼
       │                            ┌──────────────────┐
       └────────────────────────────│  sendToolResponse│
                                    └──────────────────┘
```

## Dependencias

```yaml
firebase_ai: ^3.11.0        # Gemini Live API
record: ^6.1.2              # Captura de audio del micrófono
flutter_soloud: ^4.0.2      # Reproducción de audio PCM en tiempo real
```

## Versiones Probadas

| Componente | Versión |
|------------|---------|
| Flutter SDK | 3.10.1+ |
| firebase_ai | 3.11.0 |
| record | 6.1.2 |
| flutter_soloud | 4.0.2 |
| Modelo | gemini-live-2.5-flash-native-audio |
| Voz | Achernar (español) |

## Reglas Generales

1. Audio siempre a **24000 Hz, mono, PCM 16-bit** en mic y SoLoud.
2. El micrófono NUNCA se pausa; se envía silencio cuando el usuario no habla.
3. Usar `sendToolResponse()` para respuestas de function calls, NUNCA `send(input: Content.functionResponses(...))`.
4. Un solo `await for` sobre `receive()`, NUNCA un loop `while` que re-suscribe.
5. Las FunctionResponse deben tener un solo campo `response` con texto natural.
6. Montos siempre en palabras en las function responses ("diez millones", no "10000000").
7. El system prompt DEBE incluir regla explícita de respuesta inmediata post-function-call.
8. Validar parámetros de function calls contra datos reales antes de ejecutar.
9. Git: usar conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`).

## Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| Modelo no habla tras function call | `send()` en vez de `sendToolResponse()` | Usar `_session.sendToolResponse(responses)` |
| Se pierden respuestas de audio | Loop `while` con múltiples `receive()` | Un solo `await for` sobre `receive()` |
| Modelo se queda callado | System prompt sin regla de respuesta | Agregar REGLA CRÍTICA en system prompt |
| Audio cortado | Sample rate diferente | Ambos a 24000 Hz, mono, PCM 16-bit |
| Stream se cierra | Pausar mic en vez de enviar silencio | Enviar `Uint8List(data.length)` |
| "invalid argument" en audio | Formato AAC/MP4 | Usar `AudioEncoder.pcm16bits` con `audio/pcm` |

## Checklist de Implementación

- [ ] `SoLoud.init()` con `sampleRate: 24000, channels: Channels.mono`
- [ ] `RecordConfig` con `AudioEncoder.pcm16bits, sampleRate: 24000`
- [ ] System prompt incluye REGLA CRÍTICA de respuesta post-function-call
- [ ] `processMessagesContinuously` usa UN SOLO `await for`
- [ ] Tool calls usan `sendToolResponse()`, NO `send(input: Content.functionResponses(...))`
- [ ] FunctionResponse tiene campo `response` con texto natural
- [ ] Mic envía silencio cuando el usuario no habla
- [ ] Interrupción limpia buffer de audio y re-crea `AudioSource`
- [ ] Validación de parámetros en function calls
- [ ] Montos en palabras en function responses
