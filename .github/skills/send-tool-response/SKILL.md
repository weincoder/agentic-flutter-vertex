---
name: send-tool-response
description: Enviar respuestas de function calls correctamente con sendToolResponse
---

# Manejo de Tool Calls — sendToolResponse

## Cuándo usar
Cada vez que el modelo ejecute una function call y necesites devolver el resultado.

## APRENDIZAJE CRÍTICO

Existen dos métodos. **Solo uno es correcto.**

## ❌ INCORRECTO

```dart
// MAL: Envía como contenido de usuario, no como respuesta de herramienta
await _session.send(
  input: Content.functionResponses(functionResponses),
);
```

## ✅ CORRECTO

```dart
// BIEN: Usa el método dedicado del protocolo
await _session.sendToolResponse(functionResponses);
```

## ¿Por qué?
`sendToolResponse()` envía un `LiveClientToolResponse` (tipo de mensaje correcto del protocolo WebSocket). `send()` envía un `LiveClientContent` que el modelo interpreta como mensaje del usuario y puede ignorar.

## Estructura de FunctionResponse para Voz

Un solo campo `response` con **texto natural** que el modelo retransmita como voz:

### ❌ Datos estructurados (el modelo no sabe qué decir)

```dart
FunctionResponse('getBalance', {
  'result': 'success',
  'balance': 10000000,
  'instruction': 'Dile al usuario su saldo.',
});
```

### ✅ Texto natural con directiva

```dart
FunctionResponse('getBalance', {
  'response':
      'El cliente tiene dos cuentas: '
      'Cuenta de ahorros con saldo de diez millones de pesos. '
      'Cuenta corriente con saldo de cincuenta y tres millones. '
      'Comunica estos saldos al usuario AHORA.',
});
```

## Reglas para function responses en voz
1. Un solo campo `response` con texto natural.
2. Datos YA formateados para lectura en voz alta.
3. Terminar con directiva clara: "Comunica esto al usuario AHORA".
4. Montos en palabras, no en números.
