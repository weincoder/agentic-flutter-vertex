import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

/// Visor de imagen en pantalla completa con opción de descarga
class ImageViewer extends StatelessWidget {
  final String imagePath;
  final String? title;

  const ImageViewer({super.key, required this.imagePath, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title ?? 'Imagen',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () => _downloadImage(context),
            tooltip: 'Descargar',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudo cargar la imagen',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Text(
            'Pellizca para hacer zoom • Arrastra para mover',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Solicitar el permiso apropiado según la plataforma
      PermissionStatus status;

      if (Platform.isIOS) {
        // iOS necesita permiso específico para agregar fotos
        status = await Permission.photosAddOnly.status;

        if (status.isDenied) {
          // Primera vez, solicitar permiso
          status = await Permission.photosAddOnly.request();
        }

        // Si aún no está granted, intentar con photos
        if (!status.isGranted) {
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
        }

        // Si fue denegado permanentemente, guiar a configuración
        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            _showPermissionDialog(context);
          }
          return;
        }
      } else {
        // Android: intentar con photos primero (Android 13+), luego storage
        status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          status = await Permission.storage.request();
        }

        if (status.isPermanentlyDenied) {
          if (context.mounted) {
            _showPermissionDialog(context);
          }
          return;
        }
      }

      if (!status.isGranted) {
        if (context.mounted) {
          _showMessage(
            context,
            'Se necesita permiso para guardar en la galería',
            isError: true,
          );
        }
        return;
      }

      // Leer bytes de la imagen
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // Guardar en galería de fotos (no en archivos)
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'diary_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true, // Para iOS devolver el path
      );

      if (context.mounted) {
        // En iOS, result puede ser un String (path) o Map
        final isSuccess =
            result is String && result.isNotEmpty ||
            (result is Map && result['isSuccess'] == true);

        if (isSuccess) {
          _showMessage(context, 'Imagen guardada en Fotos ✓');
        } else {
          _showMessage(context, 'Error al guardar la imagen', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'Error: $e', isError: true);
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Requerido'),
        content: const Text(
          'Para guardar imágenes en tu galería, necesitas habilitar el permiso de fotos en Configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
