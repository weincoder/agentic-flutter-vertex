# 📔 Diseño UX/UI Minimalista - Diary App con Vertex AI

## 🎨 Filosofía de Diseño

**Minimalismo Enfocado**: La interfaz debe desaparecer para dejar que el contenido brille. Inspirado en Day One, Bear, y Notion.

### Principios Clave
- ✨ **Claridad**: Cada elemento tiene un propósito claro
- 🧘 **Calma**: Espacios en blanco generosos, sin saturación visual
- 🎯 **Foco**: La escritura es lo primero
- 🌈 **Emocional**: Colores sutiles que reflejan sentimientos

---

## 📱 Home Screen - Diseño Minimalista

### Layout Principal

```
┌─────────────────────────────────┐
│  📔  My Diary        ⚙️  🔍     │  ← AppBar minimalista
├─────────────────────────────────┤
│                                 │
│  📊 Today's Summary             │  ← Card de resumen diario
│  You wrote 2 entries            │     (opcional, colapsable)
│  Mood: 😊 Positive              │
│  ────────────────               │
│                                 │
│  ┌───────────────────────┐     │
│  │ 🕐 2:30 PM  😊        │     │  ← Card de entrada
│  │ Afternoon thoughts     │     │     con indicador emocional
│  │                        │     │
│  │ Had a great meeting... │     │     Preview del texto
│  │ #work #productive 🎤📷 │     │     Tags + iconos multimedia
│  └───────────────────────┘     │
│                                 │
│  ┌───────────────────────┐     │
│  │ 🕘 9:00 AM  😌        │     │  ← Otra entrada
│  │ Morning reflection     │     │
│  │                        │     │
│  │ Grateful for...        │     │
│  │ #gratitude #morning    │     │
│  └───────────────────────┘     │
│                                 │
│  Dec 18, 2025 ─────────────    │  ← Separador de fecha
│                                 │
│  ┌───────────────────────┐     │
│  │ 🕘 8:45 PM  😔        │     │
│  │ Evening thoughts       │     │
│  └───────────────────────┘     │
│                                 │
└─────────────────────────────────┘
                 ✏️                  ← FAB para nueva entrada
```

### Elementos Detallados

#### 1. **AppBar (Minimalista)**
```dart
AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  title: Text('My Diary', 
    style: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.5,
    ),
  ),
  actions: [
    IconButton(icon: Icon(Icons.insights_outlined)), // Estadísticas
    IconButton(icon: Icon(Icons.search_outlined)),   // Búsqueda
    IconButton(icon: Icon(Icons.settings_outlined)), // Configuración
  ],
)
```

**Características**:
- Sin elevación (flat)
- Fondo transparente o color sutil del tema
- Iconos outlined (más ligeros)
- Título grande pero ligero (weight 300)

#### 2. **Today's Summary Card (Opcional, Colapsable)**
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade50, Colors.purple.shade50],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    children: [
      Text('Today\'s Summary', style: headline6),
      SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(icon: '📝', label: '2 entries'),
          _SummaryItem(icon: '😊', label: 'Positive'),
          _SummaryItem(icon: '🏷️', label: '5 tags'),
        ],
      ),
    ],
  ),
)
```

**Características**:
- Gradiente sutil de colores
- Resumen visual de la actividad del día
- Tap para ver análisis completo
- Se puede colapsar/expandir

#### 3. **Entry Card (Componente Principal)**
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Colors.grey.shade200, width: 1),
  ),
  child: InkWell(
    onTap: () => _openEntryDetail(),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Hora + Emoji de sentimiento
          Row(
            children: [
              Text('2:30 PM', style: caption),
              Spacer(),
              Text('😊', style: TextStyle(fontSize: 24)),
            ],
          ),
          SizedBox(height: 8),
          
          // Título (opcional)
          if (entry.title.isNotEmpty)
            Text(entry.title, 
              style: headline6.copyWith(fontWeight: FontWeight.w500),
            ),
          SizedBox(height: 4),
          
          // Preview del contenido (2-3 líneas)
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: bodyText2.copyWith(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          
          // Footer: Tags + Media icons
          Row(
            children: [
              // Tags
              Wrap(
                spacing: 6,
                children: entry.tags.take(3).map((tag) =>
                  Chip(
                    label: Text(tag, style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.grey.shade100,
                    padding: EdgeInsets.symmetric(horizontal: 6),
                  ),
                ).toList(),
              ),
              Spacer(),
              // Media icons
              if (entry.hasAudio) Icon(Icons.mic, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              if (entry.hasImages) Icon(Icons.image, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

**Características**:
- Sin elevación (borde sutil)
- Border radius suave (16px)
- Emoji grande para sentimiento
- Preview de 3 líneas de texto
- Tags como chips pequeños
- Iconos de multimedia discretos
- Animación suave al tap

#### 4. **Separador de Fecha**
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Row(
    children: [
      Text(
        'Dec 18, 2025',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Divider(color: Colors.grey.shade300, height: 1),
      ),
    ],
  ),
)
```

**Características**:
- Fecha a la izquierda
- Línea divisoria sutil
- Espacio generoso arriba/abajo

#### 5. **FAB - Floating Action Button**
```dart
FloatingActionButton.extended(
  onPressed: () => _createNewEntry(),
  icon: Icon(Icons.edit_outlined),
  label: Text('New Entry'),
  backgroundColor: theme.primaryColor,
  elevation: 2,
)
```

**Variante Minimalista**:
```dart
FloatingActionButton(
  onPressed: () => _createNewEntry(),
  child: Icon(Icons.edit_outlined, size: 28),
  backgroundColor: Colors.black87,
  elevation: 4,
)
```

**Características**:
- Extended con texto o solo ícono
- Elevación moderada (2-4)
- Ícono outlined para consistencia
- Color oscuro o del tema

---

## 🎨 Paleta de Colores

### Modo Claro
```dart
ColorScheme lightScheme = ColorScheme.light(
  primary: Color(0xFF6366F1),      // Indigo suave
  secondary: Color(0xFF8B5CF6),    // Púrpura
  surface: Color(0xFFFAFAFA),      // Gris muy claro
  background: Color(0xFFFFFFFF),   // Blanco puro
  
  // Colores emocionales
  error: Color(0xFFEF4444),        // Rojo (negativo)
  onPrimary: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1F2937),    // Gris oscuro para texto
);
```

### Modo Oscuro
```dart
ColorScheme darkScheme = ColorScheme.dark(
  primary: Color(0xFF818CF8),      // Indigo más claro
  secondary: Color(0xFFA78BFA),    // Púrpura claro
  surface: Color(0xFF1F2937),      // Gris oscuro
  background: Color(0xFF111827),   // Casi negro
  
  onPrimary: Color(0xFF111827),
  onSurface: Color(0xFFF9FAFB),    // Gris muy claro para texto
);
```

### Colores de Sentimiento
```dart
Map<Sentiment, Color> sentimentColors = {
  Sentiment.positive: Color(0xFF10B981),  // Verde
  Sentiment.neutral: Color(0xFF6B7280),   // Gris
  Sentiment.negative: Color(0xFFEF4444),  // Rojo
  Sentiment.excited: Color(0xFFF59E0B),   // Naranja
  Sentiment.calm: Color(0xFF3B82F6),      // Azul
  Sentiment.sad: Color(0xFF8B5CF6),       // Púrpura
};
```

### Emojis de Sentimiento
```dart
Map<Sentiment, String> sentimentEmojis = {
  Sentiment.positive: '😊',
  Sentiment.veryPositive: '😄',
  Sentiment.neutral: '😐',
  Sentiment.negative: '😔',
  Sentiment.veryNegative: '😢',
  Sentiment.excited: '🤩',
  Sentiment.grateful: '🙏',
  Sentiment.calm: '😌',
  Sentiment.anxious: '😰',
};
```

---

## 📐 Espaciado y Tipografía

### Espaciado Consistente
```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### Tipografía
```dart
TextTheme textTheme = TextTheme(
  // Títulos
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
  ),
  
  // Headlines
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  
  // Body
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  ),
  
  // Caption
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: Colors.grey.shade600,
  ),
);
```

**Fuentes Recomendadas**:
- **Inter**: Sans-serif moderna, muy legible
- **SF Pro**: Si quieres look nativo iOS
- **Roboto**: Default de Material, excelente
- **Lora** o **Merriweather**: Serif para contenido (opcional)

---

## 🎭 Estados Vacíos

### Primera Vez (Empty State)
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
      SizedBox(height: 24),
      Text(
        'Start Your Journey',
        style: headline5.copyWith(fontWeight: FontWeight.w300),
      ),
      SizedBox(height: 8),
      Text(
        'Capture your thoughts, moments,\nand emotions with AI-powered insights',
        textAlign: TextAlign.center,
        style: bodyText2.copyWith(color: Colors.grey.shade600),
      ),
      SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: () => _createFirstEntry(),
        icon: Icon(Icons.edit_outlined),
        label: Text('Write First Entry'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  ),
)
```

---

## 🎬 Animaciones y Transiciones

### Animaciones Sutiles
```dart
// Animación de entrada de cards
AnimatedList(
  initialItemCount: entries.length,
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: EntryCard(entry: entries[index]),
      ),
    );
  },
)

// Transición suave entre páginas
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NewEntryPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  },
)
```

---

## 📱 Interacciones Gestuales

### Swipe Actions en Entry Cards
```dart
Dismissible(
  key: Key(entry.id),
  background: Container(
    color: Colors.green,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(left: 20),
    child: Icon(Icons.edit, color: Colors.white),
  ),
  secondaryBackground: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      _editEntry(entry);
    } else {
      _deleteEntry(entry);
    }
  },
  child: EntryCard(entry: entry),
)
```

### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _refreshEntries,
  color: theme.primaryColor,
  child: ListView.builder(
    itemCount: entries.length,
    itemBuilder: (context, index) => EntryCard(entry: entries[index]),
  ),
)
```

---

## 🌟 Resumen de Características UX

### ✨ Minimalismo
- Espacios en blanco generosos
- Tipografía ligera y legible
- Sin elementos innecesarios
- Foco en el contenido

### 🎨 Visual
- Emojis grandes para sentimientos
- Colores sutiles y emocionales
- Gradientes suaves en cards especiales
- Modo oscuro completo

### 🎯 Funcionalidad
- Acceso rápido a nueva entrada (FAB)
- Preview de entradas en cards
- Búsqueda y filtrado fácil
- Navegación intuitiva

### 🎭 Feedback
- Animaciones suaves
- Estados de carga claros
- Mensajes de error amigables
- Confirmaciones visuales

### 📱 Responsive
- Adaptable a diferentes tamaños
- Grid en tablets
- Lista en móviles
- Gestos nativos

---

## 🚀 Próximos Pasos

1. **Implementar HomePage minimalista** con lista de entradas
2. **Crear EntryCard component** reutilizable
3. **Implementar FAB** para nueva entrada
4. **Añadir animaciones** de entrada/salida
5. **Configurar tema** con paleta de colores

¡Listo para crear una experiencia de diario hermosa y funcional! 📔✨
