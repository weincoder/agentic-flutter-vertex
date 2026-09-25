import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:example/config/data/diary_repository.dart';
import 'package:example/config/ia/models/ia_models.dart';
import 'package:example/config/state/app_state.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

/// Asistente de voz en tiempo real usando Gemini Live API
class LiveVoiceAssistant extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const LiveVoiceAssistant({super.key, this.onDataChanged});

  @override
  State<LiveVoiceAssistant> createState() => _LiveVoiceAssistantState();
}

class _LiveVoiceAssistantState extends State<LiveVoiceAssistant>
    with SingleTickerProviderStateMixin {
  // Gemini Live
  late final LiveGenerativeModel _liveModel;
  late LiveSession _session;
  bool _settingUpSession = false;
  bool _sessionOpened = false;
  bool _conversationActive = false;

  // Audio
  final _recorder = AudioRecorder();
  late Stream<Uint8List> _inputStream;
  AudioSource? _audioSource;
  SoundHandle? _soundHandle;
  bool _audioReady = false;
  StreamController<bool> _stopController = StreamController<bool>();

  // Push-to-talk: el mic siempre captura, pero solo se envía audio real
  // cuando _userSpeaking es true; si no, se envía silencio para mantener
  // viva la sesión sin cerrar el stream.
  bool _userSpeaking = false;
  bool _modelSpeaking = false;
  StreamController<Uint8List>? _micStreamController;
  StreamSubscription<Uint8List>? _micSubscription;

  // Repository
  final _repository = DiaryRepository();

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  // UI State
  Color _statusColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _initializeLiveModel();
    _initializeAudio();
    _initializeAnimation();
  }

  void _initializeLiveModel() {
    _liveModel = FirebaseAI.vertexAI().liveGenerativeModel(
      systemInstruction: Content.text('''
Eres un asistente personal inteligente para una aplicación de diario.
Hablas español de forma natural, amigable y conversacional.

CAPACIDADES:
1. Cambiar el color/tema de la aplicación
2. Responder preguntas sobre cualquier tema
3. Crear resúmenes de las entradas del diario
4. Eliminar entradas (con confirmación del usuario)

INSTRUCCIONES IMPORTANTES:
- Responde de forma concisa (máximo 3 oraciones)
- Sé amigable y empático
- COLORES: Cuando el usuario pida cambiar color, SIEMPRE usa los nombres en INGLÉS en el tool call:
  * "rojo" → usa "red"
  * "azul" → usa "blue"
  * "verde" → usa "green"
  * "morado/púrpura" → usa "purple"
  * "naranja" → usa "orange"
  * "rosa" → usa "pink"
  * "turquesa" → usa "teal"
  * "índigo" → usa "indigo"
  * "café/marrón" → usa "brown"
  * "ámbar" → usa "amber"
- Antes de eliminar algo, SIEMPRE pide confirmación explícita
- Para resúmenes, sé breve pero informativo

REGLA CRÍTICA (IMPORTANTE):
Después de ejecutar CUALQUIER herramienta (function call), SIEMPRE debes
responder de inmediato al usuario por voz con el resultado. NUNCA te quedes
en silencio tras una function call. Lee la respuesta de la herramienta y
comunícala al usuario en español de forma natural AHORA.

EJEMPLOS DE USO DE HERRAMIENTAS:
- Usuario: "Cambia el color a morado" → Llamar setAppColor con "purple"
- Usuario: "Pon la app en verde" → Llamar setAppColor con "green"
- Usuario: "¿Qué tiempo hace?" → Responder directamente (sin tool)
- Usuario: "Resume mi semana" → Llamar getDiarySummary con timeRange "week"
- Usuario: "Elimina la última entrada" → Llamar deleteEntry y pedir confirmación
      '''),
      model: IAModels.liveModelGemini,
      liveGenerationConfig: LiveGenerationConfig(
        speechConfig: SpeechConfig(
          voiceName: 'Achernar', // Voz en español
        ),
        responseModalities: [ResponseModalities.audio],
      ),
      tools: [
        Tool.functionDeclarations([
          _buildChangeColorTool(),
          _buildGetSummaryTool(),
          _buildDeleteEntryTool(),
        ]),
      ],
    );
  }

  Future<void> _initializeAudio() async {
    try {
      await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);
      setState(() {
        _audioReady = true;
      });
      log('Audio initialized successfully');
    } catch (e) {
      log('Error during audio initialization: $e');
      _updateStatus('Error de audio', Colors.red);
    }
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _micSubscription?.cancel();
    _micStreamController?.close();
    _recorder.dispose();
    _stopController.close();
    _pulseController.dispose();
    if (_sessionOpened) {
      _session.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Botón de control de turno: solo visible durante la conversación.
        if (_conversationActive) ...[
          _buildTurnButton(),
          const SizedBox(height: 12),
        ],
        _buildMainButton(),
      ],
    );
  }

  /// Botón de micrófono push-to-talk: mantener pulsado para hablar,
  /// soltar para que la IA responda. Se usa `Listener` (eventos de puntero
  /// crudos) en vez de onLongPress para que responda al instante y no compita
  /// con el InkWell del FloatingActionButton.
  Widget _buildTurnButton() {
    final speaking = _userSpeaking;
    return Listener(
      onPointerDown: (_) => _startRecording(),
      onPointerUp: (_) => _stopRecording(),
      onPointerCancel: (_) => _stopRecording(),
      child: FloatingActionButton(
        heroTag: 'live_voice_turn_fab',
        backgroundColor: speaking ? Colors.green : Colors.blueGrey,
        onPressed: () {},
        tooltip: 'Mantén pulsado para hablar',
        child: Icon(speaking ? Icons.mic : Icons.mic_none, color: Colors.white),
      ),
    );
  }

  Widget _buildMainButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _conversationActive ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: _conversationActive
                  ? [
                      BoxShadow(
                        color: _statusColor.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: _statusColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
            ),
            child: FloatingActionButton.large(
              heroTag: 'live_voice_assistant_fab',
              onPressed: _audioReady ? _toggleConversation : null,
              backgroundColor: _statusColor,
              elevation: 8,
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (_settingUpSession) {
      return const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      );
    }

    if (_conversationActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stop_circle_outlined, size: 32, color: Colors.white),
          const SizedBox(height: 4),
          const Text(
            'Cerrar',
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.chat_bubble_outline, size: 32, color: Colors.white),
        const SizedBox(height: 4),
        const Text(
          'Hablar',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }

  void _toggleConversation() async {
    if (_conversationActive) {
      await _stopConversation();
    } else {
      await _startConversation();
    }
  }

  /// El usuario empieza a hablar (mantener pulsado). Si la IA está hablando,
  /// se corta su audio (barge-in). NO se envía turnComplete: el modelo usa
  /// VAD automático y responde cuando deja de recibir audio real.
  void _startRecording() {
    if (!_sessionOpened || _userSpeaking) return;

    if (_modelSpeaking) {
      unawaited(_clearAudioBuffer());
      _modelSpeaking = false;
    }

    setState(() => _userSpeaking = true);
    _updateStatus('Hablando...', Colors.green);
    log('Push-to-talk: enviando audio ON');
  }

  /// El usuario suelta el botón: se deja de enviar audio real (se envía
  /// silencio). El VAD del modelo detecta el fin del habla y responde.
  void _stopRecording() {
    if (!_userSpeaking) return;

    setState(() => _userSpeaking = false);
    _updateStatus('Escuchando a la IA...', Colors.blue);
    log('Push-to-talk: enviando audio OFF');
  }

  Future<void> _startConversation() async {
    setState(() {
      _settingUpSession = true;
    });

    try {
      // Verificar permiso de micrófono
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _updateStatus('Permiso de micrófono requerido', Colors.red);
        setState(() => _settingUpSession = false);
        return;
      }

      // Conectar sesión de Gemini Live
      await _connectLiveSession();

      // Controlador intermedio: permite enviar audio real o silencio
      // según _userSpeaking (push-to-talk) sin cerrar el stream.
      _micStreamController = StreamController<Uint8List>();
      final inlineDataStream = _micStreamController!.stream.map(
        (data) => InlineDataPart('audio/pcm', data),
      );
      _session.sendMediaStream(inlineDataStream);

      // Iniciar grabación de audio del micrófono
      _inputStream = await _startRecordingStream();
      log('Input stream recording started');

      // El usuario aún no habla: se envía silencio hasta que mantenga
      // pulsado el botón del micrófono (push-to-talk).
      _userSpeaking = false;
      _micSubscription = _inputStream.listen((data) {
        final ctrl = _micStreamController;
        if (ctrl == null || ctrl.isClosed) return;
        if (_userSpeaking) {
          ctrl.add(data); // Audio real
        } else {
          ctrl.add(Uint8List(data.length)); // Silencio
        }
      });

      // Iniciar reproducción de audio de salida
      await _setupAudioOutput();

      log('Output stream playing');

      _pulseController.repeat(reverse: true);
      _updateStatus('Mantén pulsado para hablar', Colors.deepPurple);

      setState(() {
        _conversationActive = true;
        _settingUpSession = false;
      });
    } catch (e) {
      log('Error starting conversation: $e');
      _updateStatus('Error al iniciar', Colors.red);
      setState(() => _settingUpSession = false);
    }
  }

  Future<void> _stopConversation() async {
    _userSpeaking = false;

    // Detener captura del micrófono y cerrar el controlador intermedio
    await _micSubscription?.cancel();
    _micSubscription = null;
    await _recorder.stop();
    await _micStreamController?.close();
    _micStreamController = null;

    // Detener reproducción
    if (_audioSource != null && _soundHandle != null) {
      SoLoud.instance.setDataIsEnded(_audioSource!);
      await SoLoud.instance.stop(_soundHandle!);
    }

    // Cerrar sesión
    await _disconnectLiveSession();

    _pulseController.stop();
    _updateStatus('Toca para hablar', Colors.deepPurple);

    setState(() {
      _conversationActive = false;
    });
  }

  Future<void> _connectLiveSession() async {
    if (!_sessionOpened) {
      _session = await _liveModel.connect();
      _sessionOpened = true;
      unawaited(_processMessagesContinuously());
      log('Live session connected');
    }
  }

  Future<void> _disconnectLiveSession() async {
    if (_sessionOpened) {
      await _session.close();
      _stopController.add(true);
      await _stopController.close();
      _stopController = StreamController<bool>();
      _sessionOpened = false;
      log('Live session disconnected');
    }
  }

  Future<Stream<Uint8List>> _startRecordingStream() async {
    final recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 24000,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      autoGain: true,
      androidConfig: AndroidRecordConfig(
        audioSource: AndroidAudioSource.voiceCommunication,
      ),
      iosConfig: IosRecordConfig(
        categoryOptions: [
          IosAudioCategoryOption.defaultToSpeaker,
          IosAudioCategoryOption.allowBluetooth,
        ],
      ),
    );
    return await _recorder.startStream(recordConfig);
  }

  Future<void> _processMessagesContinuously() async {
    bool shouldContinue = true;

    _stopController.stream.listen((stop) {
      if (stop) shouldContinue = false;
    });

    // UN SOLO await for: re-suscribir con un while pierde eventos de audio
    // en el gap tras turnComplete y provoca que el audio se entrecorte.
    try {
      await for (final response in _session.receive()) {
        if (!shouldContinue) break;
        await _handleLiveServerMessage(response.message);
      }
    } catch (e) {
      log('Error processing messages: $e');
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerMessage message) async {
    if (message is LiveServerContent) {
      if (message.modelTurn != null) {
        _modelSpeaking = true;
        await _handleServerContent(message);
      }

      if (message.turnComplete == true) {
        log('Turno del modelo completo.');
        await Future.delayed(const Duration(milliseconds: 300));
        _modelSpeaking = false;
      }

      // Barge-in: el usuario interrumpió al modelo. Limpiar el buffer
      // para que no se solape el audio viejo con la nueva respuesta.
      if (message.interrupted == true) {
        _modelSpeaking = false;
        await _clearAudioBuffer();
        log('Interrumpido — buffer de audio limpiado');
      }
    }

    if (message is LiveServerToolCall && message.functionCalls != null) {
      _modelSpeaking = false;
      await _handleToolCalls(message);
    }
  }

  /// Crea (o re-crea) el buffer stream de salida de SoLoud.
  Future<void> _setupAudioOutput() async {
    final source = SoLoud.instance.setBufferStream(
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: 0.1,
    );
    _audioSource = source;
    _soundHandle = await SoLoud.instance.play(source);
  }

  /// Limpia el buffer de audio de salida (barge-in / interrupción)
  /// re-creándolo para descartar el audio pendiente del modelo.
  Future<void> _clearAudioBuffer() async {
    final source = _audioSource;
    final h = _soundHandle;
    if (source != null && h != null) {
      SoLoud.instance.setDataIsEnded(source);
      await SoLoud.instance.stop(h);
      await _setupAudioOutput();
    }
  }

  Future<void> _handleServerContent(LiveServerContent content) async {
    final parts = content.modelTurn?.parts;
    if (parts != null) {
      for (final part in parts) {
        if (part is InlineDataPart) {
          // Reproducir audio de respuesta
          await _playAudioPart(part);
        } else if (part is TextPart) {
          log('Text response: ${part.text}');
        }
      }
    }
  }

  Future<void> _playAudioPart(InlineDataPart part) async {
    if (_audioSource != null && part.mimeType.contains('audio')) {
      SoLoud.instance.addAudioDataStream(_audioSource!, part.bytes);
    }
  }

  Future<void> _handleToolCalls(LiveServerToolCall toolCall) async {
    final functionCalls = toolCall.functionCalls;
    if (functionCalls == null || functionCalls.isEmpty) return;

    for (var call in functionCalls) {
      log('Tool call: ${call.name}');

      switch (call.name) {
        case 'setAppColor':
          await _handleColorChange(call);
          break;
        case 'getDiarySummary':
          await _handleGetSummary(call);
          break;
        case 'deleteEntry':
          await _handleDeleteEntry(call);
          break;
      }
    }
  }

  Future<void> _handleColorChange(FunctionCall call) async {
    final colorName = call.args['color']?.toString() ?? 'blue';
    final color = _getColorFromName(colorName);

    log('Cambiando color a: $colorName (${color.toString()})');

    if (mounted) {
      try {
        final appState = Provider.of<AppState>(context, listen: false);
        log('AppState encontrado, llamando setAppColor...');

        appState.setAppColor(color);

        log('Color cambiado en AppState exitosamente');

        await _session.sendToolResponse([
          FunctionResponse(call.name, {
            'response':
                'El color de la aplicación ahora es $colorName. '
                'Confirma al usuario en español que el color cambió AHORA.',
          }),
        ]);
      } catch (e) {
        log('Error al cambiar color: $e');
        await _session.sendToolResponse([
          FunctionResponse(call.name, {
            'response':
                'Hubo un error al cambiar el color. '
                'Informa al usuario en español AHORA.',
          }),
        ]);
      }
    } else {
      log('Widget no está montado, no se puede cambiar el color');
    }
  }

  Future<void> _handleGetSummary(FunctionCall call) async {
    final timeRange = call.args['timeRange']?.toString() ?? 'all';

    final entries = await _repository.getEntries(limit: 100);
    if (entries.isEmpty) {
      await _session.sendToolResponse([
        FunctionResponse(call.name, {
          'response':
              'No hay entradas en el diario. Informa al usuario en español AHORA.',
        }),
      ]);
      return;
    }

    // Filtrar por tiempo
    final now = DateTime.now();
    final filtered = entries.where((e) {
      final diff = now.difference(e.createdAt);
      switch (timeRange) {
        case 'today':
          return diff.inHours < 24;
        case 'week':
          return diff.inDays < 7;
        case 'month':
          return diff.inDays < 30;
        default:
          return true;
      }
    }).toList();

    if (filtered.isEmpty) {
      await _session.sendToolResponse([
        FunctionResponse(call.name, {
          'response':
              'No hay entradas en ese período. Informa al usuario en español AHORA.',
        }),
      ]);
      return;
    }

    // Crear resumen
    final summaryText = filtered
        .take(10)
        .map((e) {
          return '${e.formattedDate}: ${e.contentPreview}';
        })
        .join('\n');

    await _session.sendToolResponse([
      FunctionResponse(call.name, {
        'response':
            'Estas son las ${filtered.length} entradas del diario:\n'
            '$summaryText\n\n'
            'Crea un resumen breve (2-3 oraciones) de los temas principales '
            'y el estado emocional general, y comunícalo al usuario en español AHORA.',
      }),
    ]);
  }

  Future<void> _handleDeleteEntry(FunctionCall call) async {
    final target = call.args['target']?.toString() ?? 'last';

    final entries = await _repository.getEntries(limit: 10);
    if (entries.isEmpty) {
      await _session.sendToolResponse([
        FunctionResponse(call.name, {
          'response':
              'No hay entradas para eliminar. Informa al usuario en español AHORA.',
        }),
      ]);
      return;
    }

    final entryToDelete = target == 'first' ? entries.last : entries.first;

    // TODO: Implementar lógica de confirmación con siguiente mensaje del usuario
    // Por ahora, eliminamos directamente
    await _repository.deleteEntry(entryToDelete.id);
    widget.onDataChanged?.call();

    final entryName = entryToDelete.title.isNotEmpty
        ? entryToDelete.title
        : entryToDelete.contentPreview;

    await _session.sendToolResponse([
      FunctionResponse(call.name, {
        'response':
            'La entrada "$entryName" fue eliminada. '
            'Confirma al usuario en español AHORA.',
      }),
    ]);
  }

  // Tool declarations
  FunctionDeclaration _buildChangeColorTool() {
    return FunctionDeclaration(
      'setAppColor',
      'Cambia el color primario de la aplicación',
      parameters: {
        'color': Schema.string(
          description:
              'Nombre del color en inglés: blue, red, green, purple, orange, pink, teal, indigo, brown, amber',
        ),
      },
    );
  }

  FunctionDeclaration _buildGetSummaryTool() {
    return FunctionDeclaration(
      'getDiarySummary',
      'Obtiene un resumen de las entradas del diario',
      parameters: {
        'timeRange': Schema.string(
          description: 'Rango temporal: today, week, month, all',
        ),
      },
    );
  }

  FunctionDeclaration _buildDeleteEntryTool() {
    return FunctionDeclaration(
      'deleteEntry',
      'Elimina una entrada del diario (requiere confirmación del usuario)',
      parameters: {
        'target': Schema.string(
          description: 'Qué entrada eliminar: last (última) o first (primera)',
        ),
      },
    );
  }

  MaterialColor _getColorFromName(String name) {
    final colorName = name.toLowerCase();
    log('Mapeando nombre de color: $colorName');

    MaterialColor color;
    switch (colorName) {
      case 'red':
      case 'rojo':
        color = Colors.red;
        break;
      case 'blue':
      case 'azul':
        color = Colors.blue;
        break;
      case 'green':
      case 'verde':
        color = Colors.green;
        break;
      case 'purple':
      case 'morado':
      case 'púrpura':
        color = Colors.purple;
        break;
      case 'orange':
      case 'naranja':
        color = Colors.orange;
        break;
      case 'pink':
      case 'rosa':
        color = Colors.pink;
        break;
      case 'teal':
      case 'turquesa':
        color = Colors.teal;
        break;
      case 'indigo':
      case 'índigo':
        color = Colors.indigo;
        break;
      case 'brown':
      case 'café':
      case 'marrón':
        color = Colors.brown;
        break;
      case 'amber':
      case 'ámbar':
        color = Colors.amber;
        break;
      default:
        log('Color no reconocido: $colorName, usando azul por defecto');
        color = Colors.blue;
    }

    log('Color seleccionado: ${color.toString()}');
    return color;
  }

  void _updateStatus(String message, Color color) {
    setState(() {
      _statusColor = color;
    });
  }
}
