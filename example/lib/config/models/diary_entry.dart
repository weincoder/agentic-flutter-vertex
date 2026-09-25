import 'package:flutter/material.dart';

/// Enum para representar los diferentes tipos de sentimientos
enum Sentiment {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
  mixed;

  /// Obtener emoji representativo del sentimiento
  String get emoji {
    switch (this) {
      case Sentiment.veryPositive:
        return '😄';
      case Sentiment.positive:
        return '😊';
      case Sentiment.neutral:
        return '😐';
      case Sentiment.negative:
        return '😔';
      case Sentiment.veryNegative:
        return '😢';
      case Sentiment.mixed:
        return '🤔';
    }
  }

  /// Obtener color representativo del sentimiento
  Color get color {
    switch (this) {
      case Sentiment.veryPositive:
        return const Color(0xFF10B981); // Verde brillante
      case Sentiment.positive:
        return const Color(0xFF34D399); // Verde suave
      case Sentiment.neutral:
        return const Color(0xFF6B7280); // Gris
      case Sentiment.negative:
        return const Color(0xFFF59E0B); // Naranja
      case Sentiment.veryNegative:
        return const Color(0xFFEF4444); // Rojo
      case Sentiment.mixed:
        return const Color(0xFF8B5CF6); // Púrpura
    }
  }

  /// Obtener etiqueta legible
  String get label {
    switch (this) {
      case Sentiment.veryPositive:
        return 'Muy Positivo';
      case Sentiment.positive:
        return 'Positivo';
      case Sentiment.neutral:
        return 'Neutral';
      case Sentiment.negative:
        return 'Negativo';
      case Sentiment.veryNegative:
        return 'Muy Negativo';
      case Sentiment.mixed:
        return 'Mixto';
    }
  }
}

/// Modelo de datos para una entrada del diario
class DiaryEntry {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String title;
  final String content;
  final String? audioPath;
  final List<String> imagePaths;
  final Sentiment sentiment;
  final List<String> tags;
  final String? aiSummary;
  final Map<String, dynamic>? metadata;

  DiaryEntry({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.title,
    required this.content,
    this.audioPath,
    this.imagePaths = const [],
    this.sentiment = Sentiment.neutral,
    this.tags = const [],
    this.aiSummary,
    this.metadata,
  });

  /// Verificar si la entrada tiene audio
  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  /// Verificar si la entrada tiene imágenes
  bool get hasImages => imagePaths.isNotEmpty;

  /// Verificar si la entrada tiene contenido multimodal
  bool get hasMultimedia => hasAudio || hasImages;

  /// Obtener preview del contenido (primeras 3 líneas)
  String get contentPreview {
    final lines = content.split('\n');
    if (lines.length <= 3) return content;
    return '${lines.take(3).join('\n')}...';
  }

  /// Obtener fecha formateada
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Hoy ${_formatTime(createdAt)}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${_formatTime(createdAt)}';
    } else if (difference.inDays < 7) {
      return '${_getWeekday(createdAt)} ${_formatTime(createdAt)}';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return weekdays[date.weekday - 1];
  }

  /// Crear copia con modificaciones
  DiaryEntry copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? content,
    String? audioPath,
    List<String>? imagePaths,
    Sentiment? sentiment,
    List<String>? tags,
    String? aiSummary,
    Map<String, dynamic>? metadata,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      content: content ?? this.content,
      audioPath: audioPath ?? this.audioPath,
      imagePaths: imagePaths ?? this.imagePaths,
      sentiment: sentiment ?? this.sentiment,
      tags: tags ?? this.tags,
      aiSummary: aiSummary ?? this.aiSummary,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convertir a Map para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'title': title,
      'content': content,
      'audioPath': audioPath,
      'imagePaths': imagePaths,
      'sentiment': sentiment.name,
      'tags': tags,
      'aiSummary': aiSummary,
      'metadata': metadata,
    };
  }

  /// Crear desde Map
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      title: json['title'] as String,
      content: json['content'] as String,
      audioPath: json['audioPath'] as String?,
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sentiment: Sentiment.values.firstWhere(
        (e) => e.name == json['sentiment'],
        orElse: () => Sentiment.neutral,
      ),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      aiSummary: json['aiSummary'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Crear entrada de ejemplo para testing
  factory DiaryEntry.example({
    String? title,
    String? content,
    Sentiment? sentiment,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      title: title ?? 'Entrada de ejemplo',
      content:
          content ??
          'Este es un contenido de ejemplo para probar la interfaz.\n\nPuede contener múltiples líneas y párrafos.\n\nPerfecto para visualizar el diseño.',
      sentiment: sentiment ?? Sentiment.positive,
      tags: tags ?? ['ejemplo', 'prueba'],
    );
  }
}
