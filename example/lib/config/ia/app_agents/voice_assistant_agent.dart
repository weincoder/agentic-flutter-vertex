import 'dart:convert';
import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/ia/app_agents/diary_agent.dart';
import 'package:example/config/ia/models/ia_models.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

/// Agente de asistente de voz para comandos interactivos
class VoiceAssistantAgent {
  static final VoiceAssistantAgent _instance = VoiceAssistantAgent._internal();
  factory VoiceAssistantAgent() => _instance;
  VoiceAssistantAgent._internal();

  final _gemini = FirebaseAI.vertexAI().generativeModel(
    model: IAModels.chatModelGemini,
  );

  final _diaryAgent = DiaryAgent();
  final _repository = DiaryRepository();

  /// Procesa un comando de voz y ejecuta la acción correspondiente
  Future<VoiceCommandResult> processCommand(String transcription) async {
    try {
      // Primero, clasificar el comando
      final commandType = await _classifyCommand(transcription);

      switch (commandType) {
        case VoiceCommandType.createEntry:
          return await _handleCreateEntry(transcription);

        case VoiceCommandType.changeColor:
          return await _handleColorChange(transcription);

        case VoiceCommandType.answerQuestion:
          return await _handleQuestion(transcription);

        case VoiceCommandType.summarize:
          return await _handleSummary(transcription);

        case VoiceCommandType.deleteEntry:
          return await _handleDelete(transcription);

        case VoiceCommandType.unknown:
          return VoiceCommandResult(
            type: VoiceCommandType.unknown,
            message:
                'No entendí el comando. Prueba con: "agrega una entrada", "cambia el color", "¿qué tiempo hace?", "resumen del día" o "elimina la última entrada"',
            success: false,
          );
      }
    } catch (e) {
      debugPrint('Error en processCommand: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.unknown,
        message: 'Error al procesar comando: $e',
        success: false,
      );
    }
  }

  /// Clasifica el tipo de comando usando Gemini
  Future<VoiceCommandType> _classifyCommand(String transcription) async {
    final prompt = '''
Clasifica el siguiente comando de voz en una de estas categorías:

CATEGORÍAS:
1. CREATE_ENTRY: Usuario quiere crear, agregar, guardar, registrar o escribir una nueva entrada o nota en el diario
   Ejemplos: 
   - "agrega una entrada que diga hoy fue un gran día"
   - "crea una entrada sobre mi viaje"
   - "escribe en mi diario que me siento feliz"
   - "anota que hoy terminé mi proyecto"
   - "nueva entrada: salí a correr en el parque"
   - "guarda esta nota en el diario"

2. CHANGE_COLOR: Usuario quiere cambiar el color/tema de la aplicación
   Ejemplos: "cambia el color", "pon el tema oscuro", "color azul"
   
3. ANSWER_QUESTION: Usuario hace una pregunta sobre cualquier tema
   Ejemplos: "¿qué tiempo hace?", "¿cuál es la capital de Francia?", "dame un consejo"
   
4. SUMMARIZE: Usuario quiere un resumen de sus entradas
   Ejemplos: "resume mi día", "resumen de la semana", "qué he escrito hoy"
   
5. DELETE_ENTRY: Usuario quiere eliminar una entrada
   Ejemplos: "elimina la última entrada", "borra la nota de ayer", "elimina mi entrada"
   
6. UNKNOWN: No encaja en ninguna categoría

Comando: "$transcription"

Responde SOLO con una de estas palabras: CREATE_ENTRY, CHANGE_COLOR, ANSWER_QUESTION, SUMMARIZE, DELETE_ENTRY, UNKNOWN
''';

    final response = await _gemini.generateContent([Content.text(prompt)]);
    final result = response.text?.trim().toUpperCase() ?? 'UNKNOWN';

    if (result.contains('CREATE_ENTRY')) {
      return VoiceCommandType.createEntry;
    }
    if (result.contains('CHANGE_COLOR')) {
      return VoiceCommandType.changeColor;
    }
    if (result.contains('ANSWER_QUESTION')) {
      return VoiceCommandType.answerQuestion;
    }
    if (result.contains('SUMMARIZE')) {
      return VoiceCommandType.summarize;
    }
    if (result.contains('DELETE_ENTRY')) {
      return VoiceCommandType.deleteEntry;
    }
    return VoiceCommandType.unknown;
  }

  /// Maneja comandos de cambio de color
  Future<VoiceCommandResult> _handleColorChange(String transcription) async {
    try {
      final prompt =
          '''
El usuario quiere cambiar el color de la aplicación.

Comando: "$transcription"

Basándote en el comando, elige UN color apropiado de esta lista:
- blue (azul)
- red (rojo)
- green (verde)
- purple (morado)
- orange (naranja)
- pink (rosa)
- teal (turquesa)
- indigo (índigo)
- brown (café)
- amber (ámbar)

Responde SOLO con el nombre del color en inglés (sin explicación).
Si no mencionan un color específico, elige uno aleatorio y menciona cuál elegiste.
''';

      final response = await _gemini.generateContent([Content.text(prompt)]);
      final colorName = response.text?.trim().toLowerCase() ?? 'blue';

      // Mapear a MaterialColor
      final color = _getColorFromName(colorName);

      return VoiceCommandResult(
        type: VoiceCommandType.changeColor,
        message: 'Color cambiado a ${_getColorSpanishName(colorName)}',
        success: true,
        data: {'color': color, 'colorName': colorName},
      );
    } catch (e) {
      debugPrint('Error en _handleColorChange: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.changeColor,
        message: 'No pude cambiar el color',
        success: false,
      );
    }
  }

  /// Responde preguntas generales
  Future<VoiceCommandResult> _handleQuestion(String transcription) async {
    try {
      final prompt =
          '''
El usuario te hace una pregunta. Responde de forma natural, amigable y concisa (máximo 3 oraciones).

Pregunta: "$transcription"

Responde como un asistente personal útil. Si no sabes algo, sé honesto.
''';

      final response = await _gemini.generateContent([Content.text(prompt)]);
      final answer = response.text?.trim() ?? 'No pude encontrar una respuesta';

      return VoiceCommandResult(
        type: VoiceCommandType.answerQuestion,
        message: answer,
        success: true,
      );
    } catch (e) {
      debugPrint('Error en _handleQuestion: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.answerQuestion,
        message: 'No pude procesar tu pregunta',
        success: false,
      );
    }
  }

  /// Genera resumen de entradas
  Future<VoiceCommandResult> _handleSummary(String transcription) async {
    try {
      // Determinar el rango temporal
      final timeRange = await _getTimeRange(transcription);

      // Obtener entradas del rango
      final entries = await _repository.getEntries(limit: 100);

      if (entries.isEmpty) {
        return VoiceCommandResult(
          type: VoiceCommandType.summarize,
          message: 'No tienes entradas para resumir',
          success: false,
        );
      }

      // Filtrar por fecha si es necesario
      final now = DateTime.now();
      final filteredEntries = entries.where((entry) {
        final diff = now.difference(entry.createdAt);
        switch (timeRange) {
          case 'today':
            return diff.inHours < 24;
          case 'week':
            return diff.inDays < 7;
          case 'month':
            return diff.inDays < 30;
          case 'all':
          default:
            return true;
        }
      }).toList();

      if (filteredEntries.isEmpty) {
        return VoiceCommandResult(
          type: VoiceCommandType.summarize,
          message: 'No tienes entradas en ese período',
          success: false,
        );
      }

      // Crear resumen con Gemini
      final entriesText = filteredEntries
          .take(10)
          .map((e) {
            return '${e.formattedDate}: ${e.title.isNotEmpty ? '${e.title} - ' : ''}${e.contentPreview}';
          })
          .join('\n\n');

      final prompt =
          '''
Resume estas entradas de diario de forma natural y amigable (2-3 oraciones):

$entriesText

Resume los temas principales, el estado emocional general y momentos destacados.
''';

      final response = await _gemini.generateContent([Content.text(prompt)]);
      final summary = response.text?.trim() ?? 'No pude crear el resumen';

      return VoiceCommandResult(
        type: VoiceCommandType.summarize,
        message: '📊 Resumen (${filteredEntries.length} entradas):\n\n$summary',
        success: true,
        data: {'entries': filteredEntries},
      );
    } catch (e) {
      debugPrint('Error en _handleSummary: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.summarize,
        message: 'No pude crear el resumen',
        success: false,
      );
    }
  }

  /// Elimina una entrada
  Future<VoiceCommandResult> _handleDelete(String transcription) async {
    try {
      // Determinar qué entrada eliminar
      final deleteTarget = await _identifyDeleteTarget(transcription);

      final entries = await _repository.getEntries(limit: 10);

      if (entries.isEmpty) {
        return VoiceCommandResult(
          type: VoiceCommandType.deleteEntry,
          message: 'No hay entradas para eliminar',
          success: false,
        );
      }

      DiaryEntry? entryToDelete;

      switch (deleteTarget) {
        case 'last':
        case 'ultima':
          entryToDelete = entries.first;
          break;
        case 'first':
        case 'primera':
          entryToDelete = entries.last;
          break;
        default:
          entryToDelete = entries.first;
      }

      return VoiceCommandResult(
        type: VoiceCommandType.deleteEntry,
        message:
            '¿Estás seguro de eliminar "${entryToDelete.title.isNotEmpty ? entryToDelete.title : entryToDelete.contentPreview}"?',
        success: true,
        data: {'entry': entryToDelete},
        requiresConfirmation: true,
      );
    } catch (e) {
      debugPrint('Error en _handleDelete: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.deleteEntry,
        message: 'No pude procesar la eliminación',
        success: false,
      );
    }
  }

  Future<String> _getTimeRange(String transcription) async {
    final text = transcription.toLowerCase();
    if (text.contains('hoy') || text.contains('día')) return 'today';
    if (text.contains('semana')) return 'week';
    if (text.contains('mes')) return 'month';
    return 'all';
  }

  Future<String> _identifyDeleteTarget(String transcription) async {
    final text = transcription.toLowerCase();
    if (text.contains('última') ||
        text.contains('ultimo') ||
        text.contains('last')) {
      return 'last';
    }
    if (text.contains('primera') ||
        text.contains('primero') ||
        text.contains('first')) {
      return 'first';
    }
    return 'last';
  }

  MaterialColor _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'brown':
        return Colors.brown;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _getColorSpanishName(String name) {
    switch (name.toLowerCase()) {
      case 'red':
        return 'rojo';
      case 'blue':
        return 'azul';
      case 'green':
        return 'verde';
      case 'purple':
        return 'morado';
      case 'orange':
        return 'naranja';
      case 'pink':
        return 'rosa';
      case 'teal':
        return 'turquesa';
      case 'indigo':
        return 'índigo';
      case 'brown':
        return 'café';
      case 'amber':
        return 'ámbar';
      default:
        return name;
    }
  }

  /// Maneja comandos de creación de entrada en el diario
  Future<VoiceCommandResult> _handleCreateEntry(String transcription) async {
    try {
      final prompt = '''
El usuario quiere guardar una entrada en su diario mediante el siguiente comando de voz:
"$transcription"

Tu tarea es extraer:
1. "title": Un título breve y adecuado (máximo 5 palabras). Si el usuario mencionó un título explícito (por ejemplo "con título...", "que se llame..."), úsalo. Si no mencionó título, genera uno conciso y representativo basado en el contenido.
2. "content": El contenido principal que el usuario quiere guardar en su diario. Limpia y quita las frases de comando introductorias como "agrega una entrada que diga", "crea una entrada", "escribe en mi diario", "anota en el diario", "guarda que", etc., dejando únicamente la vivencia, pensamiento o nota del usuario.

Responde ÚNICAMENTE con un JSON válido con la siguiente estructura (sin bloques markdown ni explicaciones):
{
  "title": "Título aquí",
  "content": "Contenido aquí"
}
''';

      final response = await _gemini.generateContent([Content.text(prompt)]);
      final rawText = response.text?.trim() ?? '';

      String title = '';
      String content = '';

      try {
        String jsonText = rawText;
        if (jsonText.startsWith('```')) {
          jsonText = jsonText
              .replaceAll(RegExp(r'^```(json)?\n?'), '')
              .replaceAll(RegExp(r'\n?```$'), '')
              .trim();
        }
        final Map<String, dynamic> parsed =
            jsonDecode(jsonText) as Map<String, dynamic>;
        title = parsed['title']?.toString().trim() ?? '';
        content = parsed['content']?.toString().trim() ?? '';
      } catch (jsonError) {
        debugPrint(
          'Error parseando JSON de entrada: $jsonError. Usando fallback.',
        );
      }

      if (content.isEmpty) {
        content = _cleanCommandContent(transcription);
        title = 'Nota de voz';
      }

      // Utilizar DiaryAgent para crear y guardar la entrada con análisis completo de IA e imagen artística
      final entry = await _diaryAgent.createEntry(
        content: content,
        title: title.isNotEmpty ? title : null,
        autoGenerateImage: true,
      );

      final displayTitle =
          entry.title.isNotEmpty ? entry.title : entry.contentPreview;

      return VoiceCommandResult(
        type: VoiceCommandType.createEntry,
        message: '✓ Entrada agregada al diario: "$displayTitle"',
        success: true,
        data: {'entry': entry},
      );
    } catch (e) {
      debugPrint('Error en _handleCreateEntry: $e');
      return VoiceCommandResult(
        type: VoiceCommandType.createEntry,
        message: 'No pude crear la entrada: $e',
        success: false,
      );
    }
  }

  String _cleanCommandContent(String text) {
    String cleaned = text.trim();
    final prefixes = [
      RegExp(
        r'^(por favor\s+)?(agrega|agregar|crea|crear|escribe|escribir|anota|anotar|guarda|guardar)(\s+una|\s+la)?\s+(nueva\s+)?(entrada|nota)(\s+(en|a|al)\s+mi\s+diario|\s+en\s+el\s+diario)?(\s+que\s+diga|\s*:\s*|\s+diciendo\s+que|\s+diciendo|\s+sobre|\s+que|\s+de)?\s*',
        caseSensitive: false,
      ),
      RegExp(
        r'^(nueva\s+entrada|nueva\s+nota)(\s*:\s*|\s+que\s+diga\s+|\s+que\s+|\s+)\s*',
        caseSensitive: false,
      ),
    ];
    for (final prefix in prefixes) {
      if (prefix.hasMatch(cleaned)) {
        cleaned = cleaned.replaceFirst(prefix, '').trim();
        break;
      }
    }
    return cleaned.isNotEmpty ? cleaned : text.trim();
  }
}

/// Tipos de comandos de voz
enum VoiceCommandType {
  createEntry,
  changeColor,
  answerQuestion,
  summarize,
  deleteEntry,
  unknown,
}

/// Resultado de un comando de voz
class VoiceCommandResult {
  final VoiceCommandType type;
  final String message;
  final bool success;
  final Map<String, dynamic>? data;
  final bool requiresConfirmation;

  VoiceCommandResult({
    required this.type,
    required this.message,
    required this.success,
    this.data,
    this.requiresConfirmation = false,
  });
}
