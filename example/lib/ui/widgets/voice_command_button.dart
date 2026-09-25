import 'dart:io';
import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/ia/app_agents/diary_agent.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Botón para grabar y crear entradas por comando de voz
class VoiceCommandButton extends StatefulWidget {
  final VoidCallback? onEntryCreated;

  const VoiceCommandButton({super.key, this.onEntryCreated});

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  final _audioRecorder = AudioRecorder();
  final _repository = DiaryRepository();
  final _diaryAgent = DiaryAgent();

  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00897B).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'voice_command_fab',
          onPressed: null,
          backgroundColor: const Color(0xFF00897B).withOpacity(0.6),
          elevation: 8,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_isRecording) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(
                    _animationController.value * 0.6,
                  ),
                  blurRadius: 25 + (_animationController.value * 25),
                  spreadRadius: 6 + (_animationController.value * 12),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              heroTag: 'voice_command_fab',
              onPressed: _stopRecording,
              backgroundColor: Colors.red.shade600,
              elevation: 8,
              icon: Opacity(
                opacity: 0.3 + (_animationController.value * 0.7),
                child: const Icon(
                  Icons.stop_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              label: const Text(
                'Detener',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'voice_command_fab',
        onPressed: _startRecording,
        backgroundColor: const Color(0xFF00897B), // Teal 600
        elevation: 8,
        tooltip: 'Grabar nota de voz',
        child: const Icon(Icons.mic, size: 26, color: Colors.white),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      // Verificar permiso de micrófono
      if (await _audioRecorder.hasPermission()) {
        // Obtener directorio temporal
        final directory = await getApplicationDocumentsDirectory();
        final audioDir = Directory('${directory.path}/diary_audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${audioDir.path}/voice_note_$timestamp.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });

        _showMessage('🎤 Grabando... Habla ahora');
      } else {
        _showMessage('Se necesita permiso de micrófono', isError: true);
      }
    } catch (e) {
      _showMessage('Error al iniciar grabación: $e', isError: true);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (path != null && path.isNotEmpty) {
        // Transcribir audio con Gemini
        _showMessage('✨ Procesando tu nota de voz...');

        final transcription = await _diaryAgent.transcribeAudio(path);

        if (transcription != null && transcription.isNotEmpty) {
          // Crear entrada del diario con la transcripción
          await _createEntryFromTranscription(transcription, path);
        } else {
          _showMessage(
            'No se pudo transcribir el audio. Intenta de nuevo.',
            isError: true,
          );
          setState(() => _isProcessing = false);
        }
      } else {
        _showMessage('No se grabó audio', isError: true);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Error al procesar audio: $e', isError: true);
    }
  }

  Future<void> _createEntryFromTranscription(
    String transcription,
    String audioPath,
  ) async {
    try {
      // Crear entrada temporal
      final tempEntry = DiaryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        title: '',
        content: transcription,
        audioPath: audioPath,
        sentiment: Sentiment.neutral,
        tags: [],
      );

      // Analizar con IA y generar imagen si es necesario
      final results = await Future.wait([
        _diaryAgent.analyzeEntry(tempEntry),
        _diaryAgent.generateImage(content: transcription, title: ''),
      ]);

      final analysisResult = results[0] as Map<String, dynamic>;
      final generatedImagePath = results[1] as String?;

      // Crear entrada final con todos los datos
      final entry = tempEntry.copyWith(
        sentiment: analysisResult['sentiment'] as Sentiment,
        tags: analysisResult['tags'] as List<String>,
        aiSummary: analysisResult['summary'] as String?,
        imagePaths: generatedImagePath != null ? [generatedImagePath] : [],
      );

      await _repository.saveEntry(entry);

      setState(() => _isProcessing = false);

      if (mounted) {
        _showMessage('✓ Nota de voz guardada exitosamente');
        widget.onEntryCreated?.call();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Error al crear entrada: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
