import 'package:example/config/ia/app_agents/app_agent.dart';
import 'package:example/config/ia/tools/tools.dart';
import 'package:example/config/state/app_state.dart';
import 'package:example/config/utils/utils.dart';
import 'package:example/ui/pages/mail_screen.dart';
import 'package:example/ui/pages/trax_success.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:async';
import 'dart:developer';
import 'package:record/record.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'dart:typed_data';

class AudioAgenticAppManagerDemo extends StatelessWidget {
  const AudioAgenticAppManagerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      theme: FeedbackThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      child: ChangeNotifierProvider(
        create: (context) => AppState(),
        child: AgentManagedApp(),
      ),
    );
  }
}

class AgentManagedApp extends StatelessWidget {
  const AgentManagedApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppState manager = context.watch<AppState>();

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: manager.appColor),
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: context.watch<AppState>().fontFamily,
          fontSizeFactor: context.watch<AppState>().fontSizeFactor,
        ),
      ),
      home: AudioAgentApp(title: 'myMail', appColor: manager.appColor),
    );
  }
}

class AudioAgentApp extends StatefulWidget {
  final Color appColor;
  // AudioAgentApp({super.key, required this.title, required this.appColor});

  final String title;

  late Widget body;

  AudioAgentApp({super.key, required this.title, required this.appColor}) {
    body = BancolombiaApp(appColor: appColor);
  }

  @override
  State<AudioAgentApp> createState() => _AudioAgentAppState();
}

class _AudioAgentAppState extends State<AudioAgentApp> {
  final LiveGenerativeModel _liveModel = FirebaseAI.vertexAI()
      .liveGenerativeModel(
        systemInstruction: Content.text('''
          Eres un asistente amigable y servicial, hablas español para la aplicación.
          Tu trabajo es ayudar al usuario a obtener la mejor experiencia.

          IMPORTANTE: El usuario ya ha sido autenticado de forma segura. Cuando la
          herramienta 'consolidatedBalanceTool' te devuelva un saldo, tienes
          permiso explícito para leer esa información en voz alta al usuario.
          Comunica el saldo de forma clara y directa.

          Si tienes acceso a otra herramienta, SIEMPRE pide al usuario que confirme
          el cambio antes de realizarlo.
      '''),
        model: 'gemini-2.0-flash-live-preview-04-09',
        liveGenerationConfig: LiveGenerationConfig(
          speechConfig: SpeechConfig(voiceName: 'Achernar'),
          responseModalities: [ResponseModalities.audio],
        ),
        tools: [
          Tool.functionDeclarations([
            fontFamilyTool,
            fontSizeFactorTool,
            appThemeColorTool,
            consolidatedBalanceTool,
            moneyTransferTool,
          ]),
        ],
      );

  late LiveSession _session; // Gemini Live Session
  bool _settingUpSession = false; // Session is getting set up
  bool _sessionOpened = false; // Session is open and ready to go.
  bool _conversationActive =
      false; // Session is set up and audio streams are active
  StreamController<bool> _stopController =
      StreamController<bool>(); // Stream controller to control audio output
  bool _audioReady = false;
  final _recorder = AudioRecorder();
  late Stream<Uint8List> inputStream;
  late AudioSource? audioSrc;
  late SoundHandle handle;
  AppAgent manager = AppAgent();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
    manager.initialize();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _stopController.close();
    super.dispose();
  }

  /// AUDIO INPUT & OUTPUT
  Future<void> _initializeAudio() async {
    try {
      checkMicPermission();
      await SoLoud.instance.init(sampleRate: 24000, channels: Channels.mono);
      setState(() {
        _audioReady = true;
      });
    } catch (e) {
      log("Error during audio initialization: $e");
    }
  }

  void toggleConversation() async {
    _conversationActive ? await stopConversation() : await startConversation();
  }

  void submitFeedback() {
    BetterFeedback.of(context).show((UserFeedback feedback) {
      manager.submitFeedback(context, feedback.screenshot, feedback.text);
    });
  }

  Future<void> startConversation() async {
    setState(() {
      _settingUpSession = true;
    });

    // Start the live session
    await _toggleLiveGeminiSession();

    // Start recording audio input stream
    inputStream = await startRecordingStream();
    log('Input stream should be recording!');

    // Wrap input stream audio bytes in InlineDataPart and send to Gemini
    Stream<InlineDataPart> inlineDataStream = inputStream.map((data) {
      return InlineDataPart('audio/pcm', data);
    });
    _session.sendMediaStream(inlineDataStream);

    // Start playing an output audio stream
    var audioSource = SoLoud.instance.setBufferStream(
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: 0,
      onBuffering: (isBuffering, handle, time) {
        log('Buffering: $isBuffering, Time: $time');
      },
    );
    var soundHandle = await SoLoud.instance.play(audioSource);

    setState(() {
      audioSrc = audioSource;
      handle = soundHandle;
    });

    log('Output stream should be playing!');

    setState(() {
      _conversationActive = true;
      _settingUpSession = false;
    });
  }

  Future<void> stopConversation() async {
    // Stop recording input audio
    stopRecording();

    // Stop playing output audio
    SoLoud.instance.setDataIsEnded(audioSrc!);
    await SoLoud.instance.stop(handle);

    // End the live session
    await _toggleLiveGeminiSession();

    setState(() {
      _conversationActive = false;
    });
  }

  Future<void> checkMicPermission() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception(
        'This app does not have microphone permissions. Please enable it.',
      );
    }
  }

  Future<Stream<Uint8List>> startRecordingStream() async {
    var recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 24000,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      androidConfig: AndroidRecordConfig(
        audioSource: AndroidAudioSource.voiceCommunication,
      ),
      iosConfig: IosRecordConfig(
        categoryOptions: [IosAudioCategoryOption.defaultToSpeaker],
      ),
    );
    var stream = await _recorder.startStream(recordConfig);
    return stream;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
  }

  /// Firebase AI Logic
  Future<void> _toggleLiveGeminiSession() async {
    setState(() {
      _settingUpSession = true;
    });

    if (!_sessionOpened) {
      _session = await _liveModel.connect();
      _sessionOpened = true;
      unawaited(processMessagesContinuously(stopSignal: _stopController));
    } else {
      await _session.close();
      _stopController.add(true);
      await _stopController.close();
      // Reset new StreamController
      _stopController = StreamController<bool>();
      _sessionOpened = false;
    }

    setState(() {
      _settingUpSession = false;
    });
  }

  Future<void> processMessagesContinuously({
    required StreamController<bool> stopSignal,
  }) async {
    bool shouldContinue = true;

    stopSignal.stream.listen((stop) {
      if (stop) {
        shouldContinue = false;
      }
    });

    while (shouldContinue) {
      try {
        await for (final response in _session.receive()) {
          // Process the received message
          LiveServerMessage message = response.message;
          await _handleLiveServerMessage(message);
        }
      } catch (e) {
        log(e.toString());
        break;
      }
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerMessage response) async {
    if (response is LiveServerContent) {
      if (response.modelTurn != null) {
        await _handleLiveServerContent(response);
      }
      if (response.turnComplete != null && response.turnComplete!) {
        await _handleTurnComplete();
      }
      if (response.interrupted != null && response.interrupted!) {
        log('Interrupted: $response');
      }
    }

    if (response is LiveServerToolCall && response.functionCalls != null) {
      await _handleLiveServerToolCall(response);
    }
  }

  Future<void> _handleLiveServerContent(LiveServerContent response) async {
    log('received response!');
    final partList = response.modelTurn?.parts;
    if (partList != null) {
      for (final part in partList) {
        if (part is TextPart) {
          await _handleTextPart(part);
        } else if (part is InlineDataPart) {
          await _handleInlineDataPart(part);
        } else {
          log('receive part with type ${part.runtimeType}');
        }
      }
    }
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    final functionCalls = response.functionCalls;
    if (functionCalls != null && functionCalls.isNotEmpty) {
      debugPrint(functionCalls.map((fc) => fc.name).toString());
      for (var functionCall in functionCalls) {
        switch (functionCall.name) {
          case 'setFontFamily':
            setFontFamilyCall(context, functionCall);
          case 'setFontSizeFactor':
            setFontSizeFactorCall(context, functionCall);
          case 'setAppColor':
            setAppColorCall(context, functionCall);
          case 'getConsolidatedBalance':
            var consolidatedBalance = await getConsolidatedBalance();
            await _session.send(
              input: Content.text(
                ' Información del cliente en pesos colombianos: $consolidatedBalance',
              ),
            );
            await _session.send(
              input: Content.text(
                'Por favor, confirma si deseas que lea el saldo consolidado en voz alta. y dile al cliente en español que el saldo consolidado es de $consolidatedBalance. recuedad que en español por ejemplo 5000000 se dice cinco millones de pesos colombianos.',
              ),
            );
            consolidatedBalanceToolCall(context, functionCall);
          case 'transferMoney':
            var accounts = await getConsolidatedBalance();
            var registeredAccounts = await registerAccounts();
            await _session.send(
              input: Content.text(
                'Información de cuentas consolidadas: $accounts por favor recuerda que en español por ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
              ),
            );
            await _session.send(
              input: Content.text(
                'Información de cuentas registradas: $registeredAccounts ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
              ),
            );
            var amount = functionCall.args['amount'].toString();
            var nickname = functionCall.args['registeredAccountNickname']
                .toString();
            var accountType = functionCall.args['accountType'].toString();
            await _session
                .send(
                  input: Content.text(
                    'Por favor, confirma si deseas realizar una transferencia de dinero confirmale el monto y número de cuenta. ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
                  ),
                )
                .then((value) {
                  setState(() {
                    widget.body = TransferSuccessScreen(
                      appColor: context.watch<AppState>().appColor,
                      amount: amount,
                      nickname: nickname,
                      accountType: accountType,
                    );

                    print('Amount: $amount');
                  });
                });
          default:
            throw UnimplementedError(
              'Function not declared to the model: ${functionCall.name}',
            );
        }
      }
    }
  }

  Future<String> registerAccounts() async {
    // Simulate a money transfer operation
    return {
      {
        'registeredAccounts': [
          {'accountId': '1122334455', 'nickname': 'Nano', 'currency': 'COP'},
          {'accountId': '5566778899', 'nickname': 'amor', 'currency': 'COP'},
          {'accountId': '1234567890', 'nickname': 'Mamá', 'currency': 'COP'},
        ],
      },
    }.toString();
  }

  Future<String> getConsolidatedBalance() async {
    return {
      {
        'balance': 10000000.0,
        'currency': 'COP',
        'type': 'ahorros',
        'description': 'Saldo consolidado en la cuenta de ahorros del cliente',
      },
      {
        'balance': 53121320.0,
        'currency': 'COP',
        'type': 'corriente',
        'description': 'Saldo consolidado en la cuenta corriente del cliente',
      },
    }.toString();
  }

  Future<void> _handleInlineDataPart(InlineDataPart part) async {
    // If DataPart is audio, add data to the output audio stream
    if (part.mimeType.startsWith('audio')) {
      var audioOutputSrc = audioSrc;
      if (audioOutputSrc != null) {
        SoLoud.instance.addAudioDataStream(audioOutputSrc, part.bytes);
      }
    }
  }

  Future<void> _handleTextPart(TextPart part) async {
    log('Text message from Gemini: ${part.text}');
  }

  Future<void> _handleTurnComplete() async {
    log('Model is done generating. Turn complete!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        // title: Text(widget.title),
        actions: [
          _settingUpSession
              ? CircularProgressIndicator(padding: EdgeInsets.all(8))
              : IconButton(
                  onPressed: _audioReady ? toggleConversation : null,
                  icon: _conversationActive
                      ? Icon(Icons.auto_awesome, color: Colors.white70)
                      : Icon(Icons.auto_awesome, color: Colors.white),
                ),
        ],
      ),
      body: widget.body,
      floatingActionButton: FloatingActionButton(
        onPressed: submitFeedback,
        // () => Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MyHomePage(title: 'Correo Electrónico'),
        //   ),
        // ),
        tooltip: 'Enviar comentarios',
        child: Icon(Icons.feedback),
      ),
    );
  }
}
