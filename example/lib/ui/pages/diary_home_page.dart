import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:example/ui/pages/new_entry_page.dart';
import 'package:example/ui/widgets/entry_card.dart';
import 'package:example/ui/widgets/live_voice_assistant.dart';
import 'package:example/ui/widgets/voice_assistant_button.dart';
import 'package:example/ui/widgets/voice_command_button.dart';
import 'package:example/ui/widgets/voice_commands_help_dialog.dart';
import 'package:flutter/material.dart';

/// Pantalla principal del diario con lista de entradas
class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final DiaryRepository _repository = DiaryRepository();
  List<DiaryEntry> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => isLoading = true);

    try {
      final loadedEntries = await _repository.getEntries();

      // Si no hay entradas, crear algunas de ejemplo
      if (loadedEntries.isEmpty) {
        await _createExampleEntries();
        final newEntries = await _repository.getEntries();
        setState(() {
          entries = newEntries;
          isLoading = false;
        });
      } else {
        setState(() {
          entries = loadedEntries;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar entradas: $e')));
      }
    }
  }

  Future<void> _createExampleEntries() async {
    // Crear entradas de ejemplo
    final exampleEntries = [
      DiaryEntry.example(
        title: 'Reflexiones de la tarde',
        content:
            'Hoy tuve una reunión muy productiva con el equipo. Logramos definir los objetivos del próximo trimestre y todos están muy motivados.\n\nMe siento agradecido por trabajar con gente tan talentosa.',
        sentiment: Sentiment.veryPositive,
        tags: ['trabajo', 'productivo', 'gratitud'],
      ),
      DiaryEntry(
        id: DateTime.now()
            .subtract(const Duration(hours: 5))
            .millisecondsSinceEpoch
            .toString(),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Momento de reflexión',
        content:
            'A veces necesito tomarme un momento para reflexionar sobre el día. No todo salió perfecto, pero aprendí mucho.',
        sentiment: Sentiment.neutral,
        tags: ['reflexión', 'aprendizaje'],
      ),
      DiaryEntry(
        id: DateTime.now()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch
            .toString(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        title: '',
        content:
            'Día difícil en el trabajo. Las cosas no salieron como esperaba y me sentí un poco abrumado. Pero mañana será mejor.',
        sentiment: Sentiment.negative,
        tags: ['trabajo', 'desafío'],
      ),
      DiaryEntry(
        id: DateTime.now()
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch
            .toString(),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Viaje a la montaña',
        content:
            '¡Qué experiencia increíble! La vista desde la cima era impresionante. Tomé muchas fotos y grabé algunos momentos.',
        sentiment: Sentiment.veryPositive,
        tags: ['viaje', 'naturaleza', 'aventura'],
      ),
    ];

    for (final entry in exampleEntries) {
      await _repository.saveEntry(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
          ? _buildEmptyState()
          : _buildEntriesList(),
      floatingActionButton: _buildFAB(colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Mi Diario',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const VoiceCommandsHelpDialog(),
            );
          },
          tooltip: 'Comandos de voz',
        ),
        IconButton(
          icon: const Icon(Icons.insights_outlined),
          onPressed: () {
            // TODO: Navegar a estadísticas
          },
          tooltip: 'Estadísticas',
        ),
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () {
            // TODO: Abrir búsqueda
          },
          tooltip: 'Buscar',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Abrir configuración
          },
          tooltip: 'Configuración',
        ),
      ],
    );
  }

  Widget _buildEntriesList() {
    // Agrupar entradas por fecha
    final groupedEntries = _groupEntriesByDate(entries);

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: groupedEntries.length,
        itemBuilder: (context, index) {
          final dateGroup = groupedEntries[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Separador de fecha
              _buildDateSeparator(dateGroup['date'] as String),

              // Lista de entradas de ese día
              ...(dateGroup['entries'] as List<DiaryEntry>).map(
                (entry) => Dismissible(
                  key: Key(entry.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await _confirmDelete(context, entry);
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteEntry(entry);
                    }
                  },
                  child: EntryCard(
                    entry: entry,
                    onTap: () => _openEntryDetail(entry),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupEntriesByDate(List<DiaryEntry> entries) {
    final Map<String, List<DiaryEntry>> grouped = {};

    for (var entry in entries) {
      final dateKey = _getDateKey(entry.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }

    return grouped.entries
        .map((e) => {'date': e.key, 'entries': e.value})
        .toList();
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return '${date.day} ${_getMonth(date.month)} ${date.year}';
    }
  }

  String _getMonth(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Comienza tu viaje',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          Text(
            'Captura tus pensamientos, momentos\ny emociones con IA',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewEntry,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Primera Entrada'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 🔮 Botón de asistente EN TIEMPO REAL (Gemini Live)
        LiveVoiceAssistant(onDataChanged: _loadEntries),
        const SizedBox(height: 12),
        // 🎤 Botón de asistente TRADICIONAL (graba → transcribe → procesa)
        VoiceAssistantButton(onDataChanged: _loadEntries),
        const SizedBox(height: 12),
        // 🎙️ Botón de comando de voz para crear nota
        VoiceCommandButton(onEntryCreated: _loadEntries),
        const SizedBox(height: 12),
        // ✏️ Botón de nueva entrada manual
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _createNewEntry,
            icon: const Icon(
              Icons.edit_outlined,
              size: 24,
              color: Colors.white,
            ),
            label: const Text(
              'Nueva Entrada',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            backgroundColor: colorScheme.primary,
            elevation: 8,
            heroTag: 'new_entry_fab',
          ),
        ),
      ],
    );
  }

  void _createNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewEntryPage()),
    );

    // Si se guardó una entrada, recargar la lista
    if (result == true) {
      _loadEntries();
    }
  }

  void _openEntryDetail(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewEntryPage(entry: entry)),
    );

    // Si se editó la entrada, recargar la lista
    if (result == true) {
      _loadEntries();
    }
  }

  Future<bool> _confirmDelete(BuildContext context, DiaryEntry entry) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar entrada'),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${entry.title.isNotEmpty ? entry.title : 'esta entrada'}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    try {
      await _repository.deleteEntry(entry.id);
      await _loadEntries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada eliminada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
