import 'dart:io';
import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/ia/app_agents/diary_agent.dart';
import 'package:example/config/ia/app_agents/voice_assistant_agent.dart';
import 'package:example/config/models/diary_entry.dart';
import 'package:example/config/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

/// Botón de asistente de voz con comandos interactivos (Tradicional)
/// Graba → Transcribe → Procesa → Responde
class VoiceAssistantButton extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const VoiceAssistantButton({super.key, this.onDataChanged});

  @override
  State<VoiceAssistantButton> createState() => _VoiceAssistantButtonState();
}

class _VoiceAssistantButtonState extends State<VoiceAssistantButton>
    with SingleTickerProviderStateMixin {
  final _audioRecorder = AudioRecorder();
  final _diaryAgent = DiaryAgent();
  final _assistantAgent = VoiceAssistantAgent();
  final _repository = DiaryRepository();

  bool _isRecording = false;
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _pulseController.dispose();
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
              color: const Color(0xFF5E35B1).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'voice_assistant_fab',
          onPressed: null,
          backgroundColor: const Color(0xFF5E35B1).withOpacity(0.6),
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
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF5E35B1,
                  ).withOpacity(_pulseController.value * 0.6),
                  blurRadius: 25 + (_pulseController.value * 25),
                  spreadRadius: 6 + (_pulseController.value * 12),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'voice_assistant_fab',
              onPressed: _stopRecording,
              backgroundColor: const Color(0xFF5E35B1),
              elevation: 8,
              child: const Icon(
                Icons.stop_rounded,
                color: Colors.white,
                size: 28,
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
            color: const Color(0xFF5E35B1).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'voice_assistant_fab',
        onPressed: _startRecording,
        backgroundColor: const Color(0xFF5E35B1), // Deep Purple 600
        elevation: 8,
        tooltip: 'Asistente tradicional (graba → procesa)',
        child: const Icon(
          Icons.record_voice_over,
          size: 26,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final audioDir = Directory('${directory.path}/diary_audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${audioDir.path}/assistant_$timestamp.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() => _isRecording = true);

        _showMessage('🎙️ ¿Qué necesitas? Habla ahora...', duration: 2);
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
        _showMessage('✨ Procesando comando...', duration: 2);

        // Transcribir audio
        final transcription = await _diaryAgent.transcribeAudio(path);

        if (transcription != null && transcription.isNotEmpty) {
          // Procesar comando
          await _processCommand(transcription);
        } else {
          _showMessage('No pude entender el comando', isError: true);
          setState(() => _isProcessing = false);
        }
      } else {
        _showMessage('No se grabó audio', isError: true);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Error al procesar: $e', isError: true);
    }
  }

  Future<void> _processCommand(String transcription) async {
    try {
      final result = await _assistantAgent.processCommand(transcription);

      setState(() => _isProcessing = false);

      if (result.requiresConfirmation) {
        // Mostrar diálogo de confirmación
        await _showConfirmationDialog(result);
      } else if (result.success) {
        // Ejecutar acción según el tipo de comando
        await _executeCommandAction(result);
        _showMessage(result.message, duration: 4);
      } else {
        _showMessage(result.message, isError: true, duration: 4);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Error al ejecutar comando: $e', isError: true);
    }
  }

  Future<void> _executeCommandAction(VoiceCommandResult result) async {
    switch (result.type) {
      case VoiceCommandType.changeColor:
        if (result.data != null && result.data!['color'] != null) {
          // Usar Provider para cambiar el color de la app
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setAppColor(result.data!['color'] as MaterialColor);
        }
        break;

      case VoiceCommandType.summarize:
        // El mensaje ya contiene el resumen
        break;

      case VoiceCommandType.answerQuestion:
        // El mensaje ya contiene la respuesta
        break;

      case VoiceCommandType.deleteEntry:
        // Ya se manejó en la confirmación
        break;

      case VoiceCommandType.unknown:
        break;
    }
  }

  Future<void> _showConfirmationDialog(VoiceCommandResult result) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && result.data != null) {
      final entry = result.data!['entry'] as DiaryEntry;
      await _repository.deleteEntry(entry.id);
      widget.onDataChanged?.call();
      _showMessage('✓ Entrada eliminada', duration: 2);
    }
  }

  void _showMessage(String message, {bool isError = false, int duration = 3}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade600
              : const Color(0xFF5E35B1),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: duration),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
