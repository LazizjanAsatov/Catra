import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/product.dart';
import '../../../data/services/food_recognition_service.dart';

class ScanController extends AsyncNotifier<Product?> {
  @override
  Future<Product?> build() async => null;

  Future<void> analyzeImage(XFile file) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(foodRecognitionServiceProvider);
      return service.analyze(file);
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final scanControllerProvider = AsyncNotifierProvider<ScanController, Product?>(
  ScanController.new,
);
