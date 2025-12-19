import 'dart:typed_data';
import 'package:example/config/ia/models/ia_models.dart';
import 'package:firebase_ai/firebase_ai.dart';

class AIImageGenerator {
  ImagenModel model = FirebaseAI.vertexAI().imagenModel(
    model: IAModels.imageModelGemini,
    generationConfig: ImagenGenerationConfig(numberOfImages: 1),
  );

  Future<Uint8List> generateImage(String prompt) async {
    final res = await model.generateImages(prompt);

    final images = res.images
        .map((ImagenInlineImage image) => image.bytesBase64Encoded)
        .toList();

    return images.first;
  }
}
