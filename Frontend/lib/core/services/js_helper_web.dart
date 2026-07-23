// lib/core/services/js_helper_web.dart

import 'dart:js' as js;

class JsLandmarksConnector {
  static void registerCallback(void Function(String jsonCoords) callback) {
    js.context['onHandLandmarksDetected'] = (String jsonCoords) {
      callback(jsonCoords);
    };
  }
}
