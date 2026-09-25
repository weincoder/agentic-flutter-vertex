import 'package:example/config/data/database_helper.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:sqflite/sqflite.dart';

/// Repositorio para gestionar las operaciones CRUD de entradas del diario
class DiaryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Guardar una nueva entrada
  Future<void> saveEntry(DiaryEntry entry) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Insertar entrada principal
      await txn.insert('entries', {
        'id': entry.id,
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt?.toIso8601String(),
        'title': entry.title,
        'content': entry.content,
        'audioPath': entry.audioPath,
        'sentiment': entry.sentiment.name,
        'aiSummary': entry.aiSummary,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insertar imágenes
      if (entry.imagePaths.isNotEmpty) {
        for (final imagePath in entry.imagePaths) {
          await txn.insert('images', {
            'entryId': entry.id,
            'imagePath': imagePath,
          });
        }
      }

      // Insertar tags
      if (entry.tags.isNotEmpty) {
        for (final tag in entry.tags) {
          // Insertar tag si no existe
          final tagId = await _getOrCreateTag(txn, tag);

          // Crear relación entre entrada y tag
          await txn.insert('entry_tags', {
            'entryId': entry.id,
            'tagId': tagId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    });
  }

  /// Obtener o crear un tag
  Future<int> _getOrCreateTag(Transaction txn, String tagName) async {
    // Buscar tag existente
    final existingTags = await txn.query(
      'tags',
      where: 'name = ?',
      whereArgs: [tagName],
    );

    if (existingTags.isNotEmpty) {
      return existingTags.first['id'] as int;
    }

    // Crear nuevo tag
    return await txn.insert('tags', {'name': tagName});
  }

  /// Obtener todas las entradas ordenadas por fecha (más reciente primero)
  Future<List<DiaryEntry>> getEntries({int? limit, int? offset}) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'entries',
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Obtener una entrada por ID
  Future<DiaryEntry?> getEntryById(String id) async {
    final db = await _dbHelper.database;

    final maps = await db.query('entries', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    return await _mapToEntry(maps.first);
  }

  /// Obtener entradas por fecha
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final db = await _dbHelper.database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'entries',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'createdAt DESC',
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Obtener entradas por rango de fechas
  Future<List<DiaryEntry>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'entries',
      where: 'createdAt >= ? AND createdAt <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'createdAt DESC',
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Buscar entradas por tag
  Future<List<DiaryEntry>> searchByTag(String tag) async {
    final db = await _dbHelper.database;

    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT e.*
      FROM entries e
      INNER JOIN entry_tags et ON e.id = et.entryId
      INNER JOIN tags t ON et.tagId = t.id
      WHERE t.name = ?
      ORDER BY e.createdAt DESC
    ''',
      [tag],
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Buscar entradas por sentimiento
  Future<List<DiaryEntry>> getEntriesBySentiment(Sentiment sentiment) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'entries',
      where: 'sentiment = ?',
      whereArgs: [sentiment.name],
      orderBy: 'createdAt DESC',
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Buscar entradas por texto (título o contenido)
  Future<List<DiaryEntry>> searchByText(String query) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    final entries = <DiaryEntry>[];
    for (final map in maps) {
      final entry = await _mapToEntry(map);
      entries.add(entry);
    }

    return entries;
  }

  /// Actualizar una entrada existente
  Future<void> updateEntry(DiaryEntry entry) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Actualizar entrada principal
      await txn.update(
        'entries',
        {
          'updatedAt': DateTime.now().toIso8601String(),
          'title': entry.title,
          'content': entry.content,
          'audioPath': entry.audioPath,
          'sentiment': entry.sentiment.name,
          'aiSummary': entry.aiSummary,
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );

      // Eliminar imágenes antiguas
      await txn.delete('images', where: 'entryId = ?', whereArgs: [entry.id]);

      // Insertar nuevas imágenes
      if (entry.imagePaths.isNotEmpty) {
        for (final imagePath in entry.imagePaths) {
          await txn.insert('images', {
            'entryId': entry.id,
            'imagePath': imagePath,
          });
        }
      }

      // Eliminar tags antiguos
      await txn.delete(
        'entry_tags',
        where: 'entryId = ?',
        whereArgs: [entry.id],
      );

      // Insertar nuevos tags
      if (entry.tags.isNotEmpty) {
        for (final tag in entry.tags) {
          final tagId = await _getOrCreateTag(txn, tag);
          await txn.insert('entry_tags', {
            'entryId': entry.id,
            'tagId': tagId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    });
  }

  /// Eliminar una entrada
  Future<void> deleteEntry(String id) async {
    final db = await _dbHelper.database;

    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Obtener todos los tags únicos
  Future<List<String>> getAllTags() async {
    final db = await _dbHelper.database;

    final maps = await db.query('tags', orderBy: 'name ASC');

    return maps.map((map) => map['name'] as String).toList();
  }

  /// Obtener estadísticas de sentimientos
  Future<Map<Sentiment, int>> getSentimentStats() async {
    final db = await _dbHelper.database;

    final maps = await db.rawQuery('''
      SELECT sentiment, COUNT(*) as count
      FROM entries
      GROUP BY sentiment
    ''');

    final stats = <Sentiment, int>{};
    for (final map in maps) {
      final sentimentName = map['sentiment'] as String;
      final count = map['count'] as int;
      final sentiment = Sentiment.values.firstWhere(
        (e) => e.name == sentimentName,
        orElse: () => Sentiment.neutral,
      );
      stats[sentiment] = count;
    }

    return stats;
  }

  /// Obtener total de entradas
  Future<int> getTotalEntries() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Convertir Map de base de datos a DiaryEntry
  Future<DiaryEntry> _mapToEntry(Map<String, dynamic> map) async {
    final db = await _dbHelper.database;

    // Obtener imágenes
    final imageMaps = await db.query(
      'images',
      where: 'entryId = ?',
      whereArgs: [map['id']],
    );
    final imagePaths = imageMaps.map((m) => m['imagePath'] as String).toList();

    // Obtener tags
    final tagMaps = await db.rawQuery(
      '''
      SELECT t.name
      FROM tags t
      INNER JOIN entry_tags et ON t.id = et.tagId
      WHERE et.entryId = ?
    ''',
      [map['id']],
    );
    final tags = tagMaps.map((m) => m['name'] as String).toList();

    return DiaryEntry(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      title: map['title'] as String,
      content: map['content'] as String,
      audioPath: map['audioPath'] as String?,
      imagePaths: imagePaths,
      sentiment: Sentiment.values.firstWhere(
        (e) => e.name == map['sentiment'],
        orElse: () => Sentiment.neutral,
      ),
      tags: tags,
      aiSummary: map['aiSummary'] as String?,
    );
  }
}
