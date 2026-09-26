# 🎙️ Asistente de Voz - Guía de Comandos

## Descripción

El asistente de voz permite interactuar con tu diario mediante comandos de voz. Utiliza IA (Gemini) para entender tus comandos y ejecutar acciones automáticamente.

## 🎯 Botones Flotantes

### 1. Botón Morado (🤖 Asistente)
- **Icono**: `assistant`
- **Color**: Morado/Púrpura
- **Función**: Comandos interactivos con la app

### 2. Botón Azul (🎤 Grabar Nota)
- **Icono**: `mic`
- **Color**: Azul (color primario)
- **Función**: Crear nueva entrada por voz

### 3. Botón Extendido (✏️ Nueva Entrada)
- **Icono**: `edit_outlined`
- **Texto**: "Nueva Entrada"
- **Función**: Crear entrada manual

## 📋 Comandos Disponibles

### 📝 Crear / Agregar Entrada al Diario
Crea y guarda una nueva entrada en el diario mediante comandos de voz. Al igual que el agente `diary_agent`, analiza automáticamente el sentimiento emocional, genera etiquetas inteligentes (tags), crea un resumen y genera una ilustración artística mediante IA (Imagen).

**Ejemplos:**
- "Agrega una entrada que diga hoy fue un gran día"
- "Crea una entrada en mi diario sobre mi viaje a la montaña"
- "Escribe en mi diario que me siento muy motivado con el proyecto"
- "Anota que hoy aprendí Flutter con Vertex AI"
- "Nueva entrada: salí a correr y el clima estuvo genial"

### 🎨 Cambiar Color de la App
Cambia el color primario de toda la aplicación dinámicamente.

**Ejemplos:**
- "Cambia el color"
- "Pon el color azul"
- "Color morado"
- "Tema verde"
- "Usa el color rosa"

**Colores disponibles:**
- Azul (blue)
- Rojo (red)
- Verde (green)
- Morado (purple)
- Naranja (orange)
- Rosa (pink)
- Turquesa (teal)
- Índigo (indigo)
- Café (brown)
- Ámbar (amber)

### ❓ Responder Preguntas
Pregunta sobre cualquier tema y el asistente responderá usando IA.

**Ejemplos:**
- "¿Qué tiempo hace?"
- "¿Cuál es la capital de Francia?"
- "Dame un consejo para dormir mejor"
- "¿Cuándo es la primavera?"
- "Recomiéndame una película"

### 📊 Generar Resumen
Crea un resumen inteligente de tus entradas del diario.

**Ejemplos:**
- "Resume mi día"
- "Resumen de la semana"
- "Qué he escrito hoy"
- "Resume este mes"

**Períodos detectados:**
- "hoy/día" → Últimas 24 horas
- "semana" → Últimos 7 días
- "mes" → Últimos 30 días
- Sin especificar → Todas las entradas (max 10)

### 🗑️ Eliminar Entrada
Elimina entradas de tu diario (con confirmación).

**Ejemplos:**
- "Elimina la última entrada"
- "Borra la nota de hoy"
- "Elimina mi entrada"
- "Borra la primera nota"

**Objetivos reconocidos:**
- "última/ultimo/last" → Elimina la más reciente
- "primera/primero/first" → Elimina la más antigua
- Sin especificar → Elimina la más reciente

## 🎯 Flujo de Uso

### Para Comandos Interactivos:
1. Presiona el botón **morado** (🤖)
2. Aparece efecto de pulso morado
3. Habla tu comando claramente
4. Presiona el botón para detener
5. El asistente procesa y ejecuta la acción
6. Verás un mensaje con el resultado

### Para Crear Nota de Voz:
1. Presiona el botón **azul** (🎤)
2. Aparece botón rojo "Detener"
3. Habla tu nota de diario
4. Presiona "Detener"
5. La IA transcribe, analiza y guarda automáticamente

## 🔊 Tips de Uso

### ✅ Buenas Prácticas:
- Habla **claramente** y a velocidad normal
- Menciona el comando **al inicio**: "Cambia el color a verde"
- Espera el mensaje "¿Qué necesitas?" antes de hablar
- Usa comandos **naturales**, no necesitas frases exactas
- Para preguntas, formula **oraciones completas**

### ❌ Evita:
- Hablar demasiado rápido o lento
- Comandos ambiguos: "Haz algo con la entrada"
- Hablar sin ver el botón morado pulsante
- Ruido de fondo excesivo

## 🎨 Experiencia Visual

### Estados del Asistente:
- **Reposo**: Botón morado estático
- **Grabando**: Efecto de pulso morado con sombra animada
- **Procesando**: Spinner blanco en botón morado semi-transparente

### Mensajes:
- **Info**: Fondo morado oscuro
- **Éxito**: Fondo verde
- **Error**: Fondo rojo
- **Duración**: 2-4 segundos según el tipo

## 🧠 Inteligencia Artificial

El asistente usa **Gemini (Google)** para:
1. **Clasificar** el tipo de comando
2. **Transcribir** audio a texto
3. **Procesar** lenguaje natural
4. **Generar** respuestas contextuales
5. **Analizar** entradas para resúmenes

## 🔐 Permisos

### iOS:
- `NSMicrophoneUsageDescription`: Para grabar comandos de voz

### Android:
- `RECORD_AUDIO`: Para grabar comandos de voz

## 📱 Compatibilidad

- ✅ iOS (físico y simulador)
- ✅ Android
- ✅ macOS
- ⚠️ Web (limitado, depende de navegador)

## 🐛 Troubleshooting

### "Se necesita permiso de micrófono"
**Solución**: Ve a Configuración > [Tu App] > Habilita Micrófono

### "No pude entender el comando"
**Soluciones**:
- Habla más claro
- Reformula el comando
- Verifica que no haya ruido de fondo
- Intenta con un comando más simple

### "No se grabó audio"
**Soluciones**:
- Verifica que el micrófono funcione
- Reinicia la app
- Verifica permisos en Configuración

### El color no cambia
**Solución**: La app debe reconstruirse, espera 1-2 segundos

## 🎓 Ejemplos de Uso Real

### Escenario 1: Personalización
```
Usuario: "Cambia el color a morado"
Asistente: ✓ Color cambiado a morado
[La app se actualiza con tema morado]
```

### Escenario 2: Consulta
```
Usuario: "¿Qué puedo hacer para relajarme?"
Asistente: Puedes probar con meditación, una caminata corta o escuchar música tranquila. El ejercicio de respiración profunda también ayuda.
```

### Escenario 3: Resumen
```
Usuario: "Resume mi semana"
Asistente: 📊 Resumen (5 entradas):

Has tenido una semana productiva con altibajos. Destacan tu reunión exitosa del lunes y el proyecto completado. Hubo un día difícil el miércoles, pero mostraste resiliencia. En general, sentimientos positivos y gratitud.
```

### Escenario 4: Eliminación
```
Usuario: "Elimina la última entrada"
Asistente: [Diálogo] ¿Estás seguro de eliminar "Reflexiones de la tarde"?
Usuario: [Presiona Eliminar]
Asistente: ✓ Entrada eliminada
```

## 🆘 Ayuda en la App

Presiona el botón **?** (help_outline) en la barra superior para ver esta guía dentro de la app.

---

**Desarrollado con ❤️ usando Flutter + Vertex AI (Gemini)**
