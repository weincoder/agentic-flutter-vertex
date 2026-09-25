# Getting Started 🚀

En este documento explicamos cómo preparar tu ambiente local para ejecutar y desarrollar en **VoiceFlow Diary** (Flutter + Firebase Vertex AI).

---

## 🛠️ Herramientas que necesitas instalar

Asegúrate de contar con las siguientes herramientas en tu entorno:

* **Flutter SDK**: `>=3.10.1` ([Guía de instalación de Flutter](https://docs.flutter.dev/get-started/install))
* **Dart SDK**: Incluido con Flutter.
* **FlutterFire CLI**: Para vincular tu proyecto con Firebase:
  ```bash
  dart pub global activate flutterfire_cli
  ```
* **Herramientas por plataforma**:
  * **Android**: Android Studio, Android SDK, emulador o dispositivo físico.
  * **iOS / macOS**: macOS con Xcode 14+, CocoaPods (`sudo gem install cocoapods`).
  * **Web**: Google Chrome u otro navegador moderno.
  * **Windows / Linux**: Herramientas nativas de compilación C++/CMake correspondientes.

---

## 📋 Guía de instalación paso a paso

### 1. Clonar el repositorio y acceder a la aplicación

```bash
git clone https://github.com/weincoder/agentic-flutter-vertex.git
cd agentic-flutter-vertex/example
```

### 2. Instalar dependencias

Descarga todas las librerías necesarias del proyecto de Flutter:

```bash
flutter pub get
```

En caso de compilar para iOS o macOS, instala los pods:

```bash
cd ios && pod install && cd ..
```

---

## ⚙️ Configuración de Firebase y Vertex AI

Antes de ejecutar la app, debes enlazarla con tu propio proyecto de Firebase con Vertex AI habilitado:

### 1. Habilitar Vertex AI en Firebase
1. Ve a la consola de [Firebase Console](https://console.firebase.google.com/) y crea o selecciona tu proyecto.
2. En el menú lateral, dirígete a **Build > Vertex AI in Firebase** y actívalo.
3. Asegúrate de tener habilitada la facturación (Blaze Plan) en Google Cloud para el consumo de Vertex AI / Gemini.

### 2. Configurar Firebase en la App
Ejecuta el asistente de FlutterFire desde la carpeta `example/`:

```bash
flutterfire configure
```
Sigue los pasos interactivos para seleccionar las plataformas que desees (Android, iOS, Web, macOS). Esto generará la configuración de tu proyecto en `lib/firebase_options.dart`.

> [!NOTE]
> La aplicación utiliza el archivo `lib/config/firebase/firebase_options.dart`. Si ejecutas `flutterfire configure`, asegúrate de que las opciones correspondan a tu proyecto o copia las credenciales generadas a dicho archivo.

> [!IMPORTANT]
> Recuerda **nunca subir tus API keys o archivos de credenciales** (`google-services.json`, `GoogleService-Info.plist`, etc.) al repositorio.

---

## 📱 Permisos del Sistema

La aplicación requiere permisos de hardware para las funciones de voz e imágenes:

* **Micrófono (`RECORD_AUDIO` / `NSMicrophoneUsageDescription`)**: Necesario para grabar notas de voz, interactuar con el asistente y usar Gemini Live.
* **Cámara y Galería (`CAMERA`, `READ_MEDIA_IMAGES` / `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`)**: Para capturar o seleccionar fotos y adjuntarlas a las entradas del diario.

Estos permisos ya se encuentran declarados en `example/android/app/src/main/AndroidManifest.xml` y `example/ios/Runner/Info.plist`.

---

## ▶️ Inicia tu app 🚀

Ubícate en la carpeta `example/` y ejecuta según tu dispositivo objetivo:

```bash
# Iniciar en el dispositivo por defecto o selector interactivo
flutter run

# En emulador/dispositivo Android
flutter run -d android

# En simulador/dispositivo iOS
flutter run -d ios

# En el navegador Web
flutter run -d chrome

# En macOS
flutter run -d macos
```

---

## 📝 Configurar el estándar de commits

Todo desarrollo en este repositorio debe seguir el formato estructurado de commits:

```bash
# Este es el estandar de commit recuerda descomentar las categorías en las que aplique

# feat 🆕:
# fix 🔨:
# chore 🧨:
# docs 📓:
# test 🧪:
# style 🎨:
# refactor 🏗:
# perf 🛠:
# build 🧱:
# ci ⚙️:
# revert ⚠️:
# Componentes que se afectaron:
```

Para habilitar este template automáticamente en tu entorno Git local, ejecuta:

```bash
git config commit.template .gitmessage.conf
```

> [!TIP]
> Una vez configurado, realiza tus commits usando simplemente `git commit` (sin `-m`). Tu editor predeterminado (por ejemplo Vim o Nano) se abrirá con la plantilla. En Vim:
> 1. Presiona `i` para entrar en modo inserción.
> 2. Descomenta la categoría correspondiente (eliminando `#`) y escribe la descripción.
> 3. Presiona `Esc`, escribe `:wq` y pulsa `Enter` para guardar y confirmar.

---

## 👥 Autores del Documento
- Daniel Herrera (weincoder)