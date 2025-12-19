import 'package:firebase_ai/firebase_ai.dart';

final askConfirmationTool = FunctionDeclaration(
  'askConfirmation',
  'Desencadenar un cuadro de diálogo de alerta para preguntar al usuario por su confirmación antes de ejecutar un cambio. Solo usa esta herramienta para hacer una pregunta de sí o no al usuario. No muestres ningún otro texto.',
  parameters: {
    'question': Schema.string(
      description:
          'La pregunta que se le hará al usuario para obtener su confirmación antes de ejecutar un cambio. La respuesta a esta pregunta debe ser "sí" o "no".',
    ),
  },
);

final fontFamilyTool = FunctionDeclaration(
  'setFontFamily',
  'Establecer la familia tipográfica del tema de la aplicación.',
  parameters: {
    'fontFamily': Schema.string(
      description:
          '''El nombre de la familia tipográfica deseada. Las opciones de familia tipográfica son: 
             Inter: una tipografía sans-serif de código abierto cuidadosamente diseñada y optimizada para pantallas de computadora, priorizando la legibilidad con una altura x alta y formas geométricas limpias. 
             Raleway: una elegante familia tipográfica sans-serif de peso delgado, inicialmente diseñada como un peso delgado único, que se ha expandido a una gama completa de pesos y es conocida por su distintiva "W", lo que la hace adecuada para titulares y texto de exhibición.
             Georgia: es una tipografía serif altamente legible diseñada para uso en pantalla, caracterizada por su altura x relativamente grande y diseño robusto.
             Caveat: Caveat es una fuente manuscrita amigable y legible. Busca capturar la sensación natural del texto escrito a mano, haciéndola adecuada tanto para anotaciones cortas como para texto más largo. 
          ''',
    ),
  },
);

final consolidatedBalanceTool = FunctionDeclaration(
  'getConsolidatedBalance',
  'Consultar los saldos consolidados en la cuenta de ahorros del cliente.',
  parameters: {
    'type': Schema.string(
      description:
          'El tipo de saldo consolidado que se está consultando (por ejemplo, "ahorros", "corriente").',
    ),
  },
);

final moneyTransferTool = FunctionDeclaration(
  'transferMoney',
  'Realizar una transferencia de dinero desde la cuenta del cliente a otra cuenta.',
  parameters: {
    'accountType': Schema.string(
      description:
          'El tipo de cuenta desde la cual se realizará la transferencia (por ejemplo, "ahorros", "corriente").',
    ),
    'registeredAccountNickname': Schema.string(
      description:
          'El apodo de la cuenta inscrita a la cual se transferirá el dinero.',
    ),
    'amount': Schema.string(
      description: 'La cantidad de dinero que se transferirá.',
    ),
  },
);

final fontSizeFactorTool = FunctionDeclaration(
  'setFontSizeFactor',
  'Establecer el factor de tamaño de fuente del tema de la aplicación, determinando qué tan grande aparece el texto en la pantalla.',
  parameters: {
    'fontSizeFactor': Schema.number(
      format: "double",
      description: '''
             El factor de tamaño de fuente deseado, que determina qué tan grande aparece el texto en la pantalla. El valor predeterminado es 1.0.
             El valor mínimo es 1.0. El valor máximo es 2.0. El factor de tamaño de fuente debe incrementarse en pasos de 0.05 a menos que el usuario indique un valor específico.
          ''',
    ),
  },
);

final appThemeColorTool = FunctionDeclaration(
  'setAppColor',
  'Establecer el color del tema de la aplicación. Debes elegir el color, a menos que el usuario lo especifique. Al pedir confirmación al usuario, usa una descripción amigable del color en lugar de valores RGB.',
  parameters: {
    'red': Schema.integer(
      description:
          "El valor del canal RGB ROJO del color del tema de la aplicación deseado, que puede variar de 0 a 255.",
    ),
    'green': Schema.integer(
      description:
          "El valor del canal RGB VERDE del color del tema de la aplicación deseado, que puede variar de 0 a 255.",
    ),
    'blue': Schema.integer(
      description:
          "El valor del canal RGB AZUL del color del tema de la aplicación deseado, que puede variar de 0 a 255.",
    ),
  },
);

final deviceInfoTool = FunctionDeclaration(
  'getDeviceInfo',
  'Obtener una variedad de información del dispositivo, como el tipo de dispositivo, sistema operativo, etc.',
  parameters: {},
);

final batteryInfoTool = FunctionDeclaration(
  'getBatteryInfo',
  'Obtener información de la batería del dispositivo, incluyendo el nivel de batería y si el dispositivo está en modo de ahorro de energía.',
  parameters: {},
);

final fileFeedbackTool = FunctionDeclaration(
  'fileFeedback',
  'Registrar un informe de comentarios para el usuario.',
  parameters: {
    'summary': Schema.string(
      description: 'Un resumen conciso de los comentarios.',
    ),
    'batteryInfo': Schema.string(
      description:
          'Si el usuario se queja del rendimiento de la aplicación, incluye el nivel de batería y el estado de ahorro de energía.',
      nullable: true,
    ),
    'deviceInfo': Schema.string(
      description:
          'Un resumen de 2 oraciones sobre la información del dispositivo, incluyendo el nombre del modelo, el fabricante y el sistema operativo.',
    ),
    'actionHistory': Schema.string(
      description:
          'El historial de acciones recomendadas o realizadas en nombre del usuario.',
    ),
    'tags': Schema.array(
      items: Schema.string(
        description: 'Etiquetas que categorizan los comentarios.',
      ),
      description: 'Una lista de etiquetas que categorizan los comentarios.',
    ),
    'priority': Schema.integer(
      description:
          'Asigna a estos comentarios un nivel de prioridad que varía de 0 (MUY URGENTE) a 4 (Baja urgencia).',
    ),
  },
);
