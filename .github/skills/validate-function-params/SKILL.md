---
name: validate-function-params
description: Validar parámetros de function calls contra datos reales antes de ejecutar
---

# Validación de Datos en Function Calls

## Cuándo usar
Antes de ejecutar cualquier operación con parámetros del modelo (transferencias, búsquedas, etc.).

## Principio
Validar parámetros ANTES de preparar la operación. Si falla, retornar un error descriptivo con las opciones válidas.

## Implementación

```dart
case 'transferMoney':
  // Obtener nicknames dinámicamente de los datos
  final validNicknames = _getRegisteredNicknames();
  final nicknameMatch = validNicknames
      .where((n) => n.toLowerCase() == nickname.toLowerCase())
      .firstOrNull;

  if (nicknameMatch == null) {
    functionResponses.add(
      FunctionResponse(functionCall.name, {
        'response':
            'ERROR: La cuenta "$nickname" NO está inscrita. '
            'Las cuentas disponibles son: ${validNicknames.join(", ")}. '
            'Informa al usuario y lista las cuentas válidas.',
      }),
    );
  } else {
    // Preparar operación con nicknameMatch (case correcto)
  }
```

## Reglas
1. **Nunca hardcodear** listas de validación. Extraerlas dinámicamente de la fuente de datos.
2. Comparar **case-insensitive** (`toLowerCase()`).
3. Usar el valor **original** de la fuente (ej: `nicknameMatch`) no el del usuario.
4. En el error, **listar las opciones válidas** para que el modelo se las diga al usuario.
5. Retornar un `FunctionResponse` con texto natural describiendo el error.

## Ejemplo de helper dinámico

```dart
List<String> _getRegisteredNicknames() {
  return _registeredAccountsList
      .expand((entry) => (entry['registeredAccounts'] as List))
      .map((account) => account['nickname'] as String)
      .toList();
}
```
