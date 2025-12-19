import 'dart:typed_data';

import 'package:example/config/ia/tools/tools.dart';
import 'package:example/config/state/app_state.dart';
import 'package:example/ui/pages/trax_success.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../../utils/utils.dart';

class AppAgent {
  final gemini = FirebaseAI.vertexAI().generativeModel(
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
    model: 'gemini-2.5-flash',
    toolConfig: ToolConfig(
      functionCallingConfig: FunctionCallingConfig.any({
        'askConfirmation',
        'setFontFamily',
        'setFontSizeFactor',
        'setAppColor',
        'getDeviceInfo',
        'getBatteryInfo',
        'getConsolidatedBalance',
        'transferMoney',
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
        consolidatedBalanceTool,
        moneyTransferTool,
      ]),
    ],
  );
  late ChatSession chat;
  late Uint8List screenshot;
  late String feedbackText;

  initialize() {
    chat = gemini.startChat();
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
        case 'setFontFamily':
          setFontFamilyCall(context, functionCall);
        case 'setFontSizeFactor':
          setFontSizeFactorCall(context, functionCall);
        case 'setAppColor':
          setAppColorCall(context, functionCall);
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
          var feedbackReport = await fileFeedbackReport(context, functionCall);
          await chat.sendMessage(
            Content.text(
              'Informe de comentarios enviado exitosamente: $feedbackReport.',
            ),
          );
          return;
        case 'getConsolidatedBalance':
          var consolidatedBalance = await getConsolidatedBalance();
          await chat.sendMessage(
            Content.text(
              ' Información del cliente en pesos colombianos: $consolidatedBalance',
            ),
          );
          await chat.sendMessage(
            Content.text(
              'Por favor, confirma si deseas que lea el saldo consolidado en voz alta. y dile al cliente en español que el saldo consolidado es de $consolidatedBalance. recuedad que en español por ejemplo 5000000 se dice cinco millones de pesos colombianos.',
            ),
          );
          consolidatedBalanceToolCall(context, functionCall);
        case 'transferMoney':
          var accounts = await getConsolidatedBalance();
          var registeredAccounts = await registerAccounts();
          await chat.sendMessage(
            Content.text(
              'Información de cuentas consolidadas: $accounts por favor recuerda que en español por ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
            ),
          );
          await chat.sendMessage(
            Content.text(
              'Información de cuentas registradas: $registeredAccounts ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
            ),
          );
          var amount = functionCall.args['amount'].toString();
          var nickname = functionCall.args['registeredAccountNickname']
              .toString();
          var accountType = functionCall.args['accountType'].toString();
          await chat
              .sendMessage(
                Content.text(
                  'Por favor, confirma si deseas realizar una transferencia de dinero confirmale el monto y número de cuenta. ejemplo 5000000 se dice cinco millones de pesos colombianos. o 10000 se dice diez mil pesos colombianos.',
                ),
              )
              .then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferSuccessScreen(
                      amount: amount,
                      nickname: nickname,
                      accountType: accountType,
                      appColor: context.read<AppState>().appColor,
                    ),
                  ),
                );
              });
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

  Future<String> fileFeedbackReport(
    BuildContext context,
    FunctionCall functionCall,
  ) async {
    String summary = functionCall.args['summary'] as String;
    String deviceInfo = functionCall.args['deviceInfo'] as String;
    String batteryInfo = functionCall.args['batteryInfo'] as String? ?? '';
    String actionHistory = functionCall.args['actionHistory'] as String;
    List<dynamic> tagsList = functionCall.args['tags'] as List<dynamic>;
    List<String> tags = tagsList.map((tag) => tag as String).toList();
    int priority = functionCall.args['priority'] as int;

    String feedbackReport =
        '''
    Resumen: $summary\n
    Información del dispositivo: $deviceInfo\n
    Información de la batería: $batteryInfo\n
    Historial de acciones: $actionHistory\n
    Etiquetas: $tags\n
    Prioridad: $priority\n
    Comentarios: $feedbackText\n
    ''';

    AppState manager = context.read<AppState>();

    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: manager.appTheme,
          child: AlertDialog(
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
            title: Text('Informe de Comentarios'),
            content: Column(
              children: [
                Text('Resumen:$summary'),
                Text('Información del dispositivo: $deviceInfo'),
                Text('Información de la batería: $batteryInfo'),
                Text('Historial de acciones: $actionHistory'),
                Text('Etiquetas: ${tags.join(' ')}'),
                Text('Prioridad: $priority'),
                Text('Comentarios: $feedbackText'),
                Image.memory(screenshot),
              ],
            ),
            scrollable: true,
          ),
        );
      },
    );

    return feedbackReport;
  }

  void submitFeedback(
    BuildContext context,
    Uint8List userScreenshot,
    String userFeedbackText,
  ) async {
    screenshot = userScreenshot;
    feedbackText = userFeedbackText;

    final prompt = Content.multi([
      TextPart(
        '''Por favor, recomienda formas para que el usuario pueda abordar sus propios comentarios.
           SIEMPRE responde utilizando la herramienta de Confirmación para mostrar un cuadro de diálogo y pedir la confirmación del usuario antes de realizar un cambio.
           Si el usuario rechaza un cambio que has recomendado, procede a enviar un informe de comentarios para ellos.
        ''',
      ),
      TextPart('Estos son los comentarios del usuario: $feedbackText'),
      InlineDataPart('image/jpeg', screenshot),
    ]);

    final response = await chat.sendMessage(prompt);

    final functionCalls = response.functionCalls.toList();

    if (context.mounted && functionCalls.isNotEmpty) {
      checkFunctionCalls(context, functionCalls);
    }
  }

  Future getConsolidatedBalance() async {
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

  Future registerAccounts() async {
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
}
