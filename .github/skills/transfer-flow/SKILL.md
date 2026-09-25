---
name: transfer-flow
description: Flujo completo de transferencia con preparación, confirmación verbal y ejecución
---

# Flujo Completo de Transferencia

## Cuándo usar
Al implementar operaciones que requieren confirmación del usuario antes de ejecutarse.

## Flujo

```
Usuario: "Quiero enviar 500 mil pesos a Nano"
    │
    ▼
Gemini llama: transferMoney(amount: "500000", nickname: "Nano", accountType: "ahorros")
    │
    ▼
App valida nickname ✅ → Prepara FunctionResponse con datos
    │
    ▼
App envía: sendToolResponse([FunctionResponse(...)])
    │
    ▼
Gemini habla: "Tengo lista una transferencia de quinientos mil pesos
              a Nano desde tu cuenta de ahorros. ¿La confirmas?"
    │
    ▼
Usuario: "Sí, confirmo"
    │
    ▼
Gemini llama: confirmTransferMoney(...)
    │
    ▼
App ejecuta → Muestra pantalla de éxito → sendToolResponse(...)
    │
    ▼
Gemini habla: "Listo, se transfirieron quinientos mil pesos a Nano."
```

## Patrón de dos pasos

### Paso 1: Preparar (transferMoney)

```dart
case 'transferMoney':
  _pendingAmount = amount;
  _pendingNickname = nicknameMatch;
  _pendingAccountType = accountType;

  functionResponses.add(FunctionResponse(functionCall.name, {
    'response':
        'Transferencia PREPARADA pero NO ejecutada. '
        'Datos: monto $amount pesos, destinatario $nicknameMatch, '
        'tipo de cuenta $accountType. '
        'AHORA pregúntale al usuario: ¿Confirmas esta transferencia?',
  }));
```

### Paso 2: Confirmar (confirmTransferMoney)

```dart
case 'confirmTransferMoney':
  final amount = _pendingAmount ?? functionCall.args['amount']?.toString() ?? '0';
  final nickname = _pendingNickname ?? '...';

  // Ejecutar la operación
  // Mostrar pantalla de éxito
  
  _pendingAmount = null;
  _pendingNickname = null;
  _pendingAccountType = null;

  functionResponses.add(FunctionResponse(functionCall.name, {
    'response':
        'Transferencia ejecutada EXITOSAMENTE. '
        'Se transfirieron $amount pesos a $nickname. '
        'Comprobante número 0000091900. '
        'Confirma esto al usuario de forma amigable.',
  }));
```

## Puntos clave
- Guardar datos pendientes en variables de instancia (`_pendingAmount`, etc.).
- Limpiar datos pendientes tras confirmar o cancelar.
- El system prompt debe instruir al modelo a SOLO confirmar cuando el usuario diga "sí".
