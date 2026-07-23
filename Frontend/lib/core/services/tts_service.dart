// lib/core/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  late final FlutterTts _flutterTts;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _language = 'en-US';
  String? _preferredVoice;

  TextToSpeechService() {
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.stop();
    
    if (_preferredVoice != null) {
      // In a real application, you can query getVoices and filter, then set voice
      // e.g. await _flutterTts.setVoice({"name": _preferredVoice, "locale": _language});
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _flutterTts.setLanguage(lang);
  }

  void setPreferredVoice(String? voiceName) {
    _preferredVoice = voiceName;
  }

  Future<List<String>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        return List<String>.from(voices.map((v) => v['name']?.toString() ?? ''));
      }
    } catch (e) {
      print('Error getting voices: $e');
    }
    return ['Default System Voice'];
  }
}
