# 📚 Documentación de VoiceFlow Diary (Flutter Agéntico + Vertex AI)

Sitio de documentación bilingüe (Español / English) creado con [Docusaurus 3](https://docusaurus.io/).

Explica de forma simple y práctica cómo construir aplicaciones agénticas en Flutter usando Firebase Vertex AI (Gemini 2.5 Flash, Imagen 3 y Gemini Live API).

---

## 🚀 Inicio Rápido (Desarrollo Local)

### 1. Instalar dependencias
```bash
cd documentation
npm install
```

### 2. Iniciar servidor en Español (por defecto)
```bash
npm start
```
Abre automáticamente [http://localhost:3000/](http://localhost:3000/).

### 3. Iniciar servidor en Inglés
```bash
npm run start:en
```
Abre el sitio traducido en [http://localhost:3000/en/](http://localhost:3000/en/).

---

## 🏗️ Compilación de Producción (Build Bilingüe)

Para compilar ambas versiones (Español en `/` e Inglés en `/en/`) en la carpeta `build/`:

```bash
npm run build
```

Para previsualizar localmente el build estático generado:
```bash
npm run serve
```

---

## 📂 Estructura de Documentación

- `docs/`: Documentación en Español (idioma base).
- `i18n/en/docusaurus-plugin-content-docs/current/`: Documentación traducida al Inglés.
- `i18n/en/`: Cadenas de traducción de la interfaz (Navbar, Footer, etc.).
- `docusaurus.config.ts`: Configuración principal de Docusaurus con soporte de internacionalización (i18n) y diagramas Mermaid.
