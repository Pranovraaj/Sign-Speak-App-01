// lib/core/utils/gesture_engine.dart

import 'dart:math' as math;

class Landmark {
  final double x;
  final double y;
  final double z;

  const Landmark({required this.x, required this.y, required this.z});

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
      );
}

class CustomGesture {
  final String name;
  final List<Landmark> signature;

  const CustomGesture({required this.name, required this.signature});

  factory CustomGesture.fromJson(Map<String, dynamic> json) {
    var list = json['signature'] as List;
    List<Landmark> signatureList = list.map((i) => Landmark.fromJson(i as Map<String, dynamic>)).toList();
    return CustomGesture(
      name: json['name'] as String,
      signature: signatureList,
    );
  }
}

class PhraseRule {
  final List<String> sequence;
  final String id;
  final String translation;

  const PhraseRule({
    required this.sequence,
    required this.id,
    required this.translation,
  });
}

final List<PhraseRule> phraseRules = [
  const PhraseRule(sequence: ['ME', 'WANT', 'FOOD'], id: 'EatWithMe', translation: 'EAT WITH ME'),
  const PhraseRule(sequence: ['WHERE', 'YOU', 'GO'], id: 'WhereGo', translation: 'Where are you going?'),
  const PhraseRule(sequence: ['PLEASE', 'HELP', 'ME'], id: 'HelpMe', translation: 'HELP ME PLEASE'),
  const PhraseRule(sequence: ['SORRY', 'SIGN', 'AGAIN', 'SLOW'], id: 'SignSlow', translation: 'PLEASE SIGN SLOW'),
  const PhraseRule(sequence: ['ME', 'NO'], id: 'UnderstandNot', translation: 'ME UNDERSTAND-NOT'),
  const PhraseRule(sequence: ['SIGN'], id: 'NameWhat', translation: 'YOU NAME WHAT?'),
  const PhraseRule(sequence: ['ME', 'WANT', 'SIGN'], id: 'LearnASL', translation: 'ME WANT LEARN ASL'),
  const PhraseRule(sequence: ['ME', 'HELP'], id: 'DoctorNeed', translation: 'ME NEED DOCTOR'),
  const PhraseRule(sequence: ['ME', 'HELLO'], id: 'HappyToday', translation: 'ME FEEL HAPPY TODAY'),
  const PhraseRule(sequence: ['KNOW'], id: 'WhatHappen', translation: 'YOU KNOW WHAT HAPPEN TODAY?'),
  const PhraseRule(sequence: ['SIGN', 'GO'], id: 'BreakingNews', translation: 'BREAKING NEWS MAJOR EVENT HAPPEN'),
  const PhraseRule(sequence: ['SIGN', 'WANT'], id: 'HotNews', translation: 'HOT NEWS EVERYONE TALK-ABOUT NOW'),
  const PhraseRule(sequence: ['GO', 'WHERE'], id: 'TrainArrive', translation: 'TRAIN ARRIVE WHEN?'),
  const PhraseRule(sequence: ['SIGN', 'YOU'], id: 'SocialMedia', translation: 'INTERNET SOCIAL-MEDIA CHECK'),
  const PhraseRule(sequence: ['SORRY', 'NO'], id: 'ComputerBroken', translation: 'MY COMPUTER BROKEN'),
  const PhraseRule(sequence: ['WANT', 'GO'], id: 'TicketWhere', translation: 'TICKET BUY WHERE?'),
];

class PhraseEvaluationResult {
  final String? phraseId;
  final String? phraseText;
  final List<String> buffer;
  final bool isMatch;

  PhraseEvaluationResult({
    this.phraseId,
    this.phraseText,
    required this.buffer,
    required this.isMatch,
  });
}

class PhraseBuilder {
  List<String> _buffer = [];
  final int bufferTimeoutMs = 5000;
  int _lastAddTimestamp = 0;

  List<String> get buffer => _buffer;

  PhraseEvaluationResult addGesture(String gestureId) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _lastAddTimestamp > bufferTimeoutMs) {
      _buffer = [];
    }

    if (_buffer.isNotEmpty && _buffer.last == gestureId) {
      return PhraseEvaluationResult(
        phraseId: null,
        phraseText: null,
        buffer: _buffer,
        isMatch: false,
      );
    }

    _buffer.add(gestureId);
    _lastAddTimestamp = now;

    return _evaluateBuffer();
  }

  PhraseEvaluationResult _evaluateBuffer() {
    // Sort rules by sequence length descending to match longest sequences first
    final sortedRules = List<PhraseRule>.from(phraseRules)
      ..sort((a, b) => b.sequence.length.compareTo(a.sequence.length));

    for (final rule in sortedRules) {
      if (_buffer.length >= rule.sequence.length) {
        final startIdx = _buffer.length - rule.sequence.length;
        final slice = _buffer.sublist(startIdx);
        
        bool isMatch = true;
        for (int i = 0; i < rule.sequence.length; i++) {
          if (slice[i] != rule.sequence[i]) {
            isMatch = false;
            break;
          }
        }

        if (isMatch) {
          _buffer = []; // Clear buffer upon match
          return PhraseEvaluationResult(
            phraseId: rule.id,
            phraseText: rule.translation,
            buffer: _buffer,
            isMatch: true,
          );
        }
      }
    }

    return PhraseEvaluationResult(
      phraseId: null,
      phraseText: null,
      buffer: _buffer,
      isMatch: false,
    );
  }

  void clear() {
    _buffer = [];
  }
}

// Landmark utility functions
List<Landmark>? normalizeLandmarks(List<Landmark>? landmarks) {
  if (landmarks == null || landmarks.length < 21) return null;
  final wrist = landmarks[0];
  final scale = math.sqrt(
    math.pow(landmarks[9].x - wrist.x, 2) +
    math.pow(landmarks[9].y - wrist.y, 2) +
    math.pow(landmarks[9].z - wrist.z, 2)
  );

  final divisor = scale == 0 ? 1.0 : scale;

  return landmarks.map((pt) {
    return Landmark(
      x: (pt.x - wrist.x) / divisor,
      y: (pt.y - wrist.y) / divisor,
      z: (pt.z - wrist.z) / divisor,
    );
  }).toList();
}

double compareSignatures(List<Landmark>? sigA, List<Landmark>? sigB) {
  if (sigA == null || sigB == null || sigA.length != sigB.length) return double.infinity;
  double sumDistance = 0;
  for (int i = 0; i < sigA.length; i++) {
    final dx = sigA[i].x - sigB[i].x;
    final dy = sigA[i].y - sigB[i].y;
    final dz = sigA[i].z - sigB[i].z;
    sumDistance += math.sqrt(dx * dx + dy * dy + dz * dz);
  }
  return sumDistance / sigA.length;
}

class RecognitionFrameResult {
  final String? gesture;
  final double confidence;
  final String state;
  final List<List<Landmark>>? landmarks;

  RecognitionFrameResult({
    this.gesture,
    required this.confidence,
    required this.state,
    this.landmarks,
  });
}

class GestureEngine {
  final List<String?> _frameBuffer = [];
  final int bufferSize = 8;
  String? _lastDetectedGesture;
  int _cooldownFrames = 0;
  final int cooldownMax = 4;
  List<CustomGesture> _customGestures = [];

  void setCustomGestures(List<CustomGesture> gestures) {
    _customGestures = gestures;
  }

  String? evaluateHeuristics(List<List<Landmark>>? multiHandLandmarks) {
    if (multiHandLandmarks == null || multiHandLandmarks.isEmpty) return null;

    // Two-handed sign detection (SIGN)
    if (multiHandLandmarks.length >= 2) {
      final h1 = multiHandLandmarks[0];
      final h2 = multiHandLandmarks[1];
      if (h1.length >= 21 && h2.length >= 21) {
        final isIndexOpen1 = h1[8].y < h1[6].y;
        final isIndexOpen2 = h2[8].y < h2[6].y;
        if (isIndexOpen1 && isIndexOpen2) {
          final dist = math.sqrt(
            math.pow(h1[8].x - h2[8].x, 2) + 
            math.pow(h1[8].y - h2[8].y, 2)
          );
          if (dist < 0.35) {
            return "SIGN";
          }
        }
      }
    }

    final landmarks = multiHandLandmarks[0];
    if (landmarks.length < 21) return null;

    // Fingers open check (small Y means extended upwards/open)
    final isIndexOpen = landmarks[8].y < landmarks[6].y;
    final isMiddleOpen = landmarks[12].y < landmarks[10].y;
    final isRingOpen = landmarks[16].y < landmarks[14].y;
    final isPinkyOpen = landmarks[20].y < landmarks[18].y;

    // Thumb check distance from index base MCP (9)
    final dist4_9 = math.sqrt(math.pow(landmarks[4].x - landmarks[9].x, 2) + math.pow(landmarks[4].y - landmarks[9].y, 2));
    final dist3_9 = math.sqrt(math.pow(landmarks[3].x - landmarks[9].x, 2) + math.pow(landmarks[3].y - landmarks[9].y, 2));
    final isThumbOpen = dist4_9 > dist3_9;
    
    // Additional heuristics needed by multiple signs
    final isHighUp = landmarks[8].y < 0.3;
    final isDiagonallyCrossed = (landmarks[8].x - landmarks[5].x).abs() > 0.04;

    // W Shape (NeedWater): Index, Middle, Ring open. Pinky & Thumb closed.
    if (isIndexOpen && isMiddleOpen && isRingOpen && !isPinkyOpen && !isThumbOpen) {
      return "NeedWater";
    }

    // H Shape (HospitalWhere): Index & Middle open, Ring & Pinky closed. Thumb tucked.
    if (isIndexOpen && isMiddleOpen && !isRingOpen && !isPinkyOpen && !isThumbOpen) {
      final fingerDistance = math.sqrt(
        math.pow(landmarks[8].x - landmarks[12].x, 2) + 
        math.pow(landmarks[8].y - landmarks[12].y, 2)
      );
      if (fingerDistance < 0.08) {
        return "HospitalWhere";
      }
    }

    // Hello: All open
    if (isThumbOpen && isIndexOpen && isMiddleOpen && isRingOpen && isPinkyOpen) {
      return "Hello";
    }

    // No: Index and Middle open, Ring & Pinky closed, Thumb open
    if (isIndexOpen && isMiddleOpen && !isRingOpen && !isPinkyOpen && isThumbOpen) {
      return "No";
    }

    // WhereGo: Only Index open (pointed upwards)
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && !isThumbOpen && isHighUp) {
      return "WhereGo";
    }

    // EatWithMe (O shape)
    final distIndexThumb = math.sqrt(
      math.pow(landmarks[8].x - landmarks[4].x, 2) + 
      math.pow(landmarks[8].y - landmarks[4].y, 2)
    );
    if (!isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && distIndexThumb < 0.12 && !isThumbOpen) {
      if (landmarks[8].y < landmarks[5].y) {
        return "EatWithMe";
      }
    }

    // ILY: Thumb, Index, Pinky open
    if (isThumbOpen && isIndexOpen && !isMiddleOpen && !isRingOpen && isPinkyOpen) {
      return "ILY";
    }

    // WANT: Claw shape (fingers bent but high)
    final isIndexBent = !isIndexOpen && landmarks[8].y < landmarks[5].y;
    final isMiddleBent = !isMiddleOpen && landmarks[12].y < landmarks[9].y;
    if (isIndexBent && isMiddleBent && !isRingOpen && !isPinkyOpen && isThumbOpen) {
      return "WANT";
    }

    // ME: Thumb open, others closed, horizontal hand
    final isHorizontal = (landmarks[5].x - landmarks[17].x).abs() > 0.12;
    if (isThumbOpen && !isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && isHorizontal) {
      return "ME";
    }

    // KNOW: Index finger pointing to forehead (Y < 0.3)
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && isHighUp) {
      return "KNOW";
    }

    // SIGN fallback
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && isThumbOpen && isDiagonallyCrossed && !isHighUp) {
      return "SIGN";
    }

    // YOU: Index pointing forward, others closed, straight up
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && !isHighUp && !isDiagonallyCrossed) {
      return "YOU";
    }

    // PLEASE: Flat hand horizontal
    if (isIndexOpen && isMiddleOpen && isRingOpen && isPinkyOpen && isHorizontal) {
      return "PLEASE";
    }

    // SORRY: Fist horizontal
    if (!isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && !isThumbOpen && isHorizontal) {
      return "SORRY";
    }

    // AGAIN: Bent hand no thumb
    if (isIndexBent && isMiddleBent && !isRingOpen && !isPinkyOpen && !isThumbOpen) {
      return "AGAIN";
    }

    // SLOW: Flat hand sliding
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && isPinkyOpen && !isThumbOpen) {
      return "SLOW";
    }

    // GO: Index fingers pointing forward (horizontal index)
    if (isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen && !isThumbOpen && isHorizontal) {
      return "GO";
    }

    // Stop (Fist) or Thumbs Up (Yes) fallback
    if (!isIndexOpen && !isMiddleOpen && !isRingOpen && !isPinkyOpen) {
      if (landmarks[4].y < landmarks[5].y - 0.05) {
        return "Yes"; // Thumb up
      }
      return "Stop"; // Fist
    }

    // Custom Gesture Matching fallback
    if (_customGestures.isNotEmpty) {
      final currentNorm = normalizeLandmarks(landmarks);
      if (currentNorm != null) {
        String? bestMatch;
        double minDistance = 0.15; // Threshold
        for (final cg in _customGestures) {
          final dist = compareSignatures(cg.signature, currentNorm);
          if (dist < minDistance) {
            minDistance = dist;
            bestMatch = cg.name;
          }
        }
        if (bestMatch != null) {
          return bestMatch;
        }
      }
    }

    return null;
  }

  RecognitionFrameResult processFrame(List<List<Landmark>>? multiHandLandmarks) {
    final rawGesture = evaluateHeuristics(multiHandLandmarks);

    // Manage frame buffer queue
    _frameBuffer.add(rawGesture);
    if (_frameBuffer.length > bufferSize) {
      _frameBuffer.removeAt(0);
    }

    // Cooldown lock
    if (_cooldownFrames > 0 && _lastDetectedGesture != null) {
      _cooldownFrames--;
      return RecognitionFrameResult(
        gesture: _lastDetectedGesture,
        confidence: 1.0,
        state: 'Locked',
        landmarks: multiHandLandmarks,
      );
    }

    // Calculate frequencies of non-null gestures
    final Map<String, int> counts = {};
    int validFrames = 0;
    for (final g in _frameBuffer) {
      if (g != null) {
        counts[g] = (counts[g] ?? 0) + 1;
        validFrames++;
      }
    }

    if (validFrames == 0) {
      _lastDetectedGesture = null;
      return RecognitionFrameResult(
        gesture: null,
        confidence: 0,
        state: 'Searching',
        landmarks: multiHandLandmarks,
      );
    }

    // Find dominant gesture in buffer
    String? dominantGesture;
    int maxCount = 0;
    counts.forEach((g, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantGesture = g;
      }
    });

    final confidence = maxCount / bufferSize;

    if (confidence > 0.6) {
      if (_lastDetectedGesture != dominantGesture) {
        _cooldownFrames = cooldownMax;
      }
      _lastDetectedGesture = dominantGesture;
      return RecognitionFrameResult(
        gesture: dominantGesture,
        confidence: confidence,
        state: 'High Confidence',
        landmarks: multiHandLandmarks,
      );
    } else if (confidence > 0.35) {
      return RecognitionFrameResult(
        gesture: dominantGesture,
        confidence: confidence,
        state: 'Stabilizing...',
        landmarks: multiHandLandmarks,
      );
    }

    _lastDetectedGesture = null;
    return RecognitionFrameResult(
      gesture: null,
      confidence: 0,
      state: 'Searching',
      landmarks: multiHandLandmarks,
    );
  }
}
