class IAModels {
  IAModels._();

  static const String chatModelGemini = 'gemini-2.5-flash';
  static const String imageModelGemini = 'imagen-3.0-generate-002';

  /// Modelo para la Live API (audio bidireccional en tiempo real).
  /// `gemini-2.5-flash` NO sirve aquí: la Live API requiere un modelo
  /// "live" con audio nativo, si no la sesión conecta pero nunca responde.
  static const String liveModelGemini = 'gemini-live-2.5-flash-native-audio';
}
