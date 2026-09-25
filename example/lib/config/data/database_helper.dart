import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper para gestionar la base de datos SQLite del diario
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtener instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  /// Inicializar base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Crear tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';

    // Tabla de entradas del diario
    await db.execute('''
      CREATE TABLE entries (
        id $idType,
        createdAt $textType,
        updatedAt $textTypeNullable,
        title $textType,
        content $textType,
        audioPath $textTypeNullable,
        sentiment $textType,
        aiSummary $textTypeNullable
      )
    ''');

    // Tabla de imágenes (relación one-to-many con entries)
    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entryId $textType,
        imagePath $textType,
        FOREIGN KEY (entryId) REFERENCES entries (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de tags (relación many-to-many con entries)
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name $textType UNIQUE
      )
    ''');

    // Tabla de relación entre entries y tags
    await db.execute('''
      CREATE TABLE entry_tags (
        entryId $textType,
        tagId $integerType,
        PRIMARY KEY (entryId, tagId),
        FOREIGN KEY (entryId) REFERENCES entries (id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejorar el rendimiento de búsquedas
    await db.execute(
      'CREATE INDEX idx_entries_createdAt ON entries(createdAt)',
    );
    await db.execute(
      'CREATE INDEX idx_entries_sentiment ON entries(sentiment)',
    );
    await db.execute('CREATE INDEX idx_tags_name ON tags(name)');
  }

  /// Cerrar base de datos
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
