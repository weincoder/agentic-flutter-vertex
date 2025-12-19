import 'dart:typed_data';

import 'package:example/config/ia/app_agents/instructions.dart';
import 'package:example/config/ia/models/ia_models.dart';
import 'package:example/config/ia/tools/tools.dart';
import 'package:example/config/state/app_state.dart';
import 'package:example/config/utils/utils.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageAgent {
  final gemini = FirebaseAI.vertexAI().generativeModel(
    systemInstruction: Content.text(Instructions.modelInstructions),
    model: IAModels.chatModelGemini,
    toolConfig: ToolConfig(
      functionCallingConfig: FunctionCallingConfig.any({
        'askConfirmation',
        'setAppColor',
        'setFontFamily',
        'setFontSizeFactor',
        'getDeviceInfo',
        'getBatteryInfo',
        'fileFeedback',
      }),
    ),
    tools: [
      Tool.functionDeclarations([
        askConfirmationTool,
        fontFamilyTool,
        fontSizeFactorTool,
        appThemeColorTool,
        deviceInfoTool,
        batteryInfoTool,
        fileFeedbackTool,
        // consolidatedBalanceTool,
        // moneyTransferTool,
      ]),
    ],
  );
  late ChatSession chat;
  initialize() {
    chat = gemini.startChat();
  }

  void checkFunctionCalls(
    BuildContext context,
    Iterable<FunctionCall> functionCalls,
  ) async {
    for (var functionCall in functionCalls) {
      debugPrint(functionCalls.map((fc) => fc.name).toString());
      GenerateContentResponse? response;
      switch (functionCall.name) {
        case 'askConfirmation':
          response = await askConfirmationCall(context, functionCall);
        case 'setAppColor':
          setAppColorCall(context, functionCall);
          // No necesitamos responder al modelo, solo ejecutar la acción
          return;
        case 'setFontFamily':
          setFontFamilyCall(context, functionCall);
          return;
        case 'setFontSizeFactor':
          setFontSizeFactorCall(context, functionCall);
          return;
        case 'getDeviceInfo':
          var deviceInfo = await getDeviceInfoCall();
          response = await chat.sendMessage(
            Content.text('Información del dispositivo: $deviceInfo'),
          );
        case 'getBatteryInfo':
          var batteryInfo = await getBatteryInfoCall();
          response = await chat.sendMessage(
            Content.text('Información de la batería: $batteryInfo'),
          );
        case 'fileFeedback':
          await chat.sendMessage(
            Content.text('Informe de comentarios enviado exitosamente'),
          );
          return;
        default:
          throw UnimplementedError(
            'Función no declarada en el modelo: ${functionCall.name}',
          );
      }
      if (response != null &&
          response.functionCalls.isNotEmpty &&
          context.mounted) {
        checkFunctionCalls(context, response.functionCalls);
      }
    }
    return;
  }

  Future<GenerateContentResponse?> askConfirmationCall(
    BuildContext context,
    FunctionCall functionCall,
  ) async {
    var question = functionCall.args['question']! as String;

    if (context.mounted) {
      final functionResult = await askConfirmation(context, question);

      final response = await chat.sendMessage(
        functionResult
            ? Content.text('Sí, por favor hazlo.')
            : Content.text('No, gracias.'),
      );

      return response;
    }
    return null;
  }

  Future<bool> askConfirmation(BuildContext context, String question) async {
    var response = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: context.read<AppState>().appTheme,
          child: AlertDialog(
            title: Text('Administrador de Aplicaciones'),
            content: Text(question),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Sí, por favor'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No.'),
              ),
            ],
          ),
        );
      },
    );

    return response ?? false;
  }

  void submitFeedback(
    BuildContext context,
    Uint8List userScreenshot,
    String userFeedbackText,
  ) async {
    final prompt = Content.multi([
      TextPart('''Comentarios del usuario: "$userFeedbackText"
           
           Por favor, analiza los comentarios del usuario y la captura de pantalla, y recomienda formas específicas para abordarlos.
           SIEMPRE usa la herramienta de Confirmación (askConfirmation) para mostrar un cuadro de diálogo y pedir la confirmación del usuario antes de realizar cualquier cambio.
           Si el usuario confirma, procede a realizar el cambio usando las herramientas apropiadas.
           Si el usuario rechaza un cambio que has recomendado, procede a enviar un informe de comentarios.
        '''),
      InlineDataPart('image/png', userScreenshot),
    ]);

    final response = await chat.sendMessage(prompt);

    final functionCalls = response.functionCalls.toList();

    if (context.mounted && functionCalls.isNotEmpty) {
      checkFunctionCalls(context, functionCalls);
    }
  }
}
