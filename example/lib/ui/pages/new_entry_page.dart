import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/ia/app_agents/diary_agent.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Pantalla para crear o editar una entrada del diario
class NewEntryPage extends StatefulWidget {
  final DiaryEntry? entry; // null = nueva entrada, no null = editar

  const NewEntryPage({super.key, this.entry});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _repository = DiaryRepository();
  final _imagePicker = ImagePicker();
  final _diaryAgent = DiaryAgent();

  List<String> _imagePaths = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _imagePaths = List.from(widget.entry!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check),
              label: const Text('Guardar'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de título
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Título (opcional)',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 8),

              // Fecha y hora
              Text(
                _getFormattedDateTime(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // Campo de contenido
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '¿Qué pasó hoy?',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              // Preview de imágenes
              if (_imagePaths.isNotEmpty) ...[
                _buildImageGrid(),
                const SizedBox(height: 24),
              ],

              // Barra de herramientas
              _buildToolbar(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          final imagePath = _imagePaths[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _imagePaths.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildToolButton(
            icon: Icons.image_outlined,
            label: 'Foto',
            onTap: _pickImage,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          _buildToolButton(
            icon: Icons.camera_alt_outlined,
            label: 'Cámara',
            onTap: _takePhoto,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          _buildToolButton(
            icon: Icons.mic_outlined,
            label: 'Audio',
            onTap: () {
              // TODO: Implementar grabación de audio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Grabación de audio'),
                ),
              );
            },
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekday = weekdays[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$weekday, $day de $month de $year · $hour:$minute';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _imagePaths.add(photo.path);
        });
      }
    } catch (e) {
      _showError('Error al tomar foto: $e');
    }
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      _showError('El contenido no puede estar vacío');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Generar imagen si no hay ninguna
      List<String> finalImagePaths = List.from(_imagePaths);
      if (finalImagePaths.isEmpty) {
        final generatedImagePath = await _diaryAgent.generateImage(
          content: content,
          title: _titleController.text.trim(),
        );
        if (generatedImagePath != null) {
          finalImagePaths.add(generatedImagePath);
        }
      }

      // Crear entrada temporal
      final tempEntry = DiaryEntry(
        id:
            widget.entry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        updatedAt: widget.entry != null ? DateTime.now() : null,
        title: _titleController.text.trim(),
        content: content,
        imagePaths: finalImagePaths,
        sentiment: Sentiment.neutral,
        tags: [],
      );

      // Analizar con IA (en paralelo al guardado inicial)
      final analysisResult = await _diaryAgent.analyzeEntry(tempEntry);

      // Crear entrada con resultados del análisis
      final entry = tempEntry.copyWith(
        sentiment: analysisResult['sentiment'] as Sentiment,
        tags: analysisResult['tags'] as List<String>,
        aiSummary: analysisResult['summary'] as String?,
      );

      if (widget.entry != null) {
        await _repository.updateEntry(entry);
      } else {
        await _repository.saveEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context, true); // true = entrada guardada
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Error al guardar: $e');
    }
  }

  void _handleClose(BuildContext context) {
    final hasContent =
        _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty ||
        _imagePaths.isNotEmpty;

    if (hasContent) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Cerrar página
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
