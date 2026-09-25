import 'dart:io';
import 'package:example/config/ia/models/ia_models.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Agente especializado en análisis de entradas del diario usando Gemini
class DiaryAgent {
  static final DiaryAgent _instance = DiaryAgent._internal();
  factory DiaryAgent() => _instance;
  DiaryAgent._internal();

  final _gemini = FirebaseAI.vertexAI().generativeModel(
    model: IAModels.chatModelGemini,
  );

  final _imageModel = FirebaseAI.vertexAI().imagenModel(
    model: IAModels.imageModelGemini,
    generationConfig: ImagenGenerationConfig(numberOfImages: 1),
  );

  /// Analiza el sentimiento de una entrada del diario
  /// Retorna el Sentiment detectado basándose en texto e imágenes
  Future<Sentiment> analyzeSentiment({
    required String content,
    String? title,
    List<String>? imagePaths,
  }) async {
    try {
      final prompt = _buildSentimentPrompt(content, title);
      final parts = <Part>[TextPart(prompt)];

      // Agregar imágenes si existen (máximo 3 para no saturar)
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (var i = 0; i < imagePaths.length && i < 3; i++) {
          try {
            final imageFile = File(imagePaths[i]);
            if (await imageFile.exists()) {
              final bytes = await imageFile.readAsBytes();
              parts.add(InlineDataPart('image/jpeg', bytes));
            }
          } catch (e) {
            debugPrint('Error al cargar imagen para análisis: $e');
          }
        }
      }

      final response = await _gemini.generateContent([Content.multi(parts)]);

      final text = response.text?.trim().toLowerCase() ?? '';
      return _parseSentiment(text);
    } catch (e) {
      debugPrint('Error en analyzeSentiment: $e');
      return Sentiment.neutral;
    }
  }

  /// Genera tags relevantes para la entrada
  /// Retorna una lista de strings con los tags detectados
  Future<List<String>> generateTags({
    required String content,
    String? title,
    List<String>? imagePaths,
  }) async {
    try {
      final prompt = _buildTagsPrompt(content, title);
      final parts = <Part>[TextPart(prompt)];

      // Agregar una imagen si existe (para contexto visual)
      if (imagePaths != null && imagePaths.isNotEmpty) {
        try {
          final imageFile = File(imagePaths.first);
          if (await imageFile.exists()) {
            final bytes = await imageFile.readAsBytes();
            parts.add(InlineDataPart('image/jpeg', bytes));
          }
        } catch (e) {
          debugPrint('Error al cargar imagen para tags: $e');
        }
      }

      final response = await _gemini.generateContent([Content.multi(parts)]);

      final text = response.text?.trim() ?? '';
      return _parseTags(text);
    } catch (e) {
      debugPrint('Error en generateTags: $e');
      return [];
    }
  }

  /// Crea un resumen conciso de la entrada
  /// Útil para entradas largas
  Future<String?> createSummary({
    required String content,
    String? title,
  }) async {
    // Solo crear resumen si el contenido es largo (más de 300 caracteres)
    if (content.length < 300) {
      return null;
    }

    try {
      final prompt = _buildSummaryPrompt(content, title);
      final response = await _gemini.generateContent([Content.text(prompt)]);

      return response.text?.trim();
    } catch (e) {
      debugPrint('Error en createSummary: $e');
      return null;
    }
  }

  /// Análisis completo de una entrada (sentimiento + tags + resumen)
  /// Retorna un Map con todos los resultados
  Future<Map<String, dynamic>> analyzeEntry(DiaryEntry entry) async {
    try {
      // Ejecutar análisis en paralelo para mayor eficiencia
      final results = await Future.wait([
        analyzeSentiment(
          content: entry.content,
          title: entry.title,
          imagePaths: entry.imagePaths,
        ),
        generateTags(
          content: entry.content,
          title: entry.title,
          imagePaths: entry.imagePaths,
        ),
        createSummary(content: entry.content, title: entry.title),
      ]);

      return {
        'sentiment': results[0] as Sentiment,
        'tags': results[1] as List<String>,
        'summary': results[2] as String?,
      };
    } catch (e) {
      debugPrint('Error en analyzeEntry: $e');
      return {
        'sentiment': Sentiment.neutral,
        'tags': <String>[],
        'summary': null,
      };
    }
  }

  // ==================== PROMPTS ====================

  String _buildSentimentPrompt(String content, String? title) {
    return '''
Analiza el sentimiento emocional de esta entrada de diario.

${title != null && title.isNotEmpty ? 'Título: $title\n' : ''}
Contenido: $content

Responde SOLO con una de estas palabras exactas (sin explicación adicional):
- veryPositive: Muy feliz, emocionado, eufórico, celebrando
- positive: Contento, satisfecho, optimista, tranquilo
- neutral: Equilibrado, reflexivo, descriptivo, sin emociones fuertes
- negative: Triste, frustrado, preocupado, molesto
- veryNegative: Muy triste, devastado, furioso, desesperado
- mixed: Emociones mezcladas, agridulce, ambivalente

Considera también las imágenes adjuntas si las hay.
''';
  }

  String _buildTagsPrompt(String content, String? title) {
    return '''
Genera tags (etiquetas) relevantes para esta entrada de diario.

${title != null && title.isNotEmpty ? 'Título: $title\n' : ''}
Contenido: $content

Instrucciones:
- Genera entre 2 y 5 tags
- Cada tag debe ser una palabra o frase corta (máximo 2 palabras)
- Los tags deben capturar temas, actividades, lugares, personas o emociones clave
- Usa minúsculas y sin caracteres especiales
- Considera también las imágenes adjuntas si las hay

Responde SOLO con los tags separados por comas, sin numeración ni explicación.
Ejemplo: trabajo, familia, viaje, reflexión
''';
  }

  String _buildSummaryPrompt(String content, String? title) {
    return '''
Crea un resumen conciso de esta entrada de diario.

${title != null && title.isNotEmpty ? 'Título: $title\n' : ''}
Contenido: $content

Instrucciones:
- Máximo 2 oraciones (aproximadamente 40-60 palabras)
- Captura los puntos más importantes
- Usa lenguaje natural y fluido
- No uses frases como "Esta entrada habla de..." o "El autor menciona..."
- Ve directo al punto

Responde SOLO con el resumen, sin introducción ni explicación adicional.
''';
  }

  // ==================== PARSERS ====================

  Sentiment _parseSentiment(String text) {
    if (text.contains('verypositive') || text.contains('very positive')) {
      return Sentiment.veryPositive;
    } else if (text.contains('verynegative') ||
        text.contains('very negative')) {
      return Sentiment.veryNegative;
    } else if (text.contains('positive')) {
      return Sentiment.positive;
    } else if (text.contains('negative')) {
      return Sentiment.negative;
    } else if (text.contains('mixed')) {
      return Sentiment.mixed;
    } else {
      return Sentiment.neutral;
    }
  }

  List<String> _parseTags(String text) {
    // Limpiar y separar por comas
    final tags = text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty && tag.length <= 30)
        .take(5) // Máximo 5 tags
        .toList();

    return tags;
  }

  /// Transcribe audio a texto usando Gemini
  /// Retorna el texto transcrito o null si falla
  Future<String?> transcribeAudio(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        debugPrint('Archivo de audio no existe: $audioPath');
        return null;
      }

      final bytes = await audioFile.readAsBytes();
      debugPrint('Audio cargado, tamaño: ${bytes.length} bytes');

      // Determinar el mime type basado en la extensión
      String mimeType = 'audio/mp4';
      if (audioPath.endsWith('.wav')) {
        mimeType = 'audio/wav';
      } else if (audioPath.endsWith('.mp3')) {
        mimeType = 'audio/mpeg';
      } else if (audioPath.endsWith('.m4a')) {
        mimeType = 'audio/mp4';
      }

      final prompt = '''
Transcribe el siguiente audio a texto.

Reglas importantes:
- Escribe exactamente lo que se dice en el audio
- Usa puntuación apropiada y párrafos si es necesario
- Corrige errores obvios de pronunciación o gramática
- Si no puedes entender alguna parte, omítela (no inventes)
- Responde SOLO con el texto transcrito, sin comentarios adicionales

Transcripción:
''';

      final response = await _gemini.generateContent([
        Content.multi([TextPart(prompt), InlineDataPart(mimeType, bytes)]),
      ]);

      final transcription = response.text?.trim() ?? '';

      if (transcription.isEmpty) {
        debugPrint('La transcripción está vacía');
        return null;
      }

      debugPrint(
        'Transcripción exitosa: ${transcription.substring(0, transcription.length > 50 ? 50 : transcription.length)}...',
      );
      return transcription;
    } catch (e) {
      debugPrint('Error en transcribeAudio: $e');
      return null;
    }
  }

  /// Genera una imagen artística basada en el contenido de la entrada
  /// Retorna el path de la imagen generada o null si falla
  Future<String?> generateImage({
    required String content,
    String? title,
  }) async {
    try {
      final prompt = _buildImagePrompt(content, title);
      debugPrint('Generando imagen con prompt: $prompt');

      final response = await _imageModel.generateImages(prompt);

      if (response.images.isEmpty) {
        debugPrint('No se generó ninguna imagen');
        return null;
      }

      final imageBytes = response.images.first.bytesBase64Encoded;

      // Guardar imagen en el directorio de la app
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/diary_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'generated_$timestamp.jpg';
      final filePath = path.join(imagesDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint('Imagen generada y guardada en: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error en generateImage: $e');
      return null;
    }
  }

  String _buildImagePrompt(String content, String? title) {
    // Extraer los primeros 200 caracteres para el prompt
    final summary = content.length > 200 ? content.substring(0, 200) : content;

    return '''
Create a beautiful, artistic illustration that captures the essence of this diary entry.

${title != null && title.isNotEmpty ? 'Title: $title\n' : ''}
Content: $summary

Style: Minimalist, warm colors, dreamy atmosphere, suitable for a personal diary.
Focus on mood and emotions rather than literal representation.
''';
  }
}
