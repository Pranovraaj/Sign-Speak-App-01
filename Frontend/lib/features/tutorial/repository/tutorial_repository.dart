// lib/features/tutorial/repository/tutorial_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/gesture_model.dart';

class TutorialRepository {
  final SharedPreferences _prefs;

  TutorialRepository(this._prefs);

  static const String keyBookmarks = 'user_bookmarks_list';
  static const String keyProgress = 'user_progress_list';

  final List<GestureModel> _gestures = const [
    // WORDS
    GestureModel(
      id: 'Yes',
      name: 'YES (Thumbs Up)',
      description: 'Make a closed fist with your thumb pointing straight up. Affirms agreement.',
      image: 'assets/images/gesture_yes.png',
      category: 'Words',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'Stop',
      name: 'STOP (Fist)',
      description: 'All fingers curled tightly into a fist. Used to halt, wait, or signify stop.',
      image: 'assets/images/gesture_stop.png',
      category: 'Words',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'No',
      name: 'NO',
      description: 'Index and middle fingers extended forward, tapping the open thumb.',
      image: 'assets/images/gesture_peace.png',
      category: 'Words',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'Hello',
      name: 'HELLO / BYE',
      description: 'A flat open hand with all five fingers extended and separated.',
      image: 'assets/images/gesture_hello.png',
      category: 'Words',
      isLiveRecognized: true,
    ),

    // EMERGENCY
    GestureModel(
      id: 'NeedWater',
      name: 'WATER (W Shape)',
      description: 'Extend index, middle, and ring fingers in a "W" shape, while thumb and pinky are closed.',
      image: 'assets/images/need_water_sign_1778405629986.png',
      category: 'Emergency',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'Help',
      name: 'HELP',
      description: 'Place your closed fist on top of your open flat non-dominant palm, lifting it.',
      image: 'assets/images/help_me_sign_1778405582670.png',
      category: 'Emergency',
      isLiveRecognized: false,
    ),

    // HOSPITAL
    GestureModel(
      id: 'HospitalWhere',
      name: 'HOSPITAL (H Shape)',
      description: 'Extend index and middle fingers together, while curling the other fingers.',
      image: 'assets/images/hospital_where_sign_1778405600007.png',
      category: 'Hospital',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'Doctor',
      name: 'DOCTOR',
      description: 'Tap the fingertips of your dominant hand onto the wrist of your non-dominant hand.',
      image: 'assets/images/doctor_need_sign_1778405644691.png',
      category: 'Hospital',
      isLiveRecognized: false,
    ),

    // DAILY CONVERSATION
    GestureModel(
      id: 'ME',
      name: 'ME / I',
      description: 'Point your thumb towards your chest with your hand horizontal.',
      image: 'assets/images/gesture_me_generated.png',
      category: 'Daily Conversation',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'YOU',
      name: 'YOU',
      description: 'Extend your index finger pointing straight up, with thumb open.',
      image: 'assets/images/gesture_you_generated.png',
      category: 'Daily Conversation',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'WANT',
      name: 'WANT',
      description: 'Form a clawed handshape and pull it towards your body.',
      image: 'assets/images/gesture_want_generated.png',
      category: 'Daily Conversation',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'PLEASE',
      name: 'PLEASE',
      description: 'A flat open hand moved horizontally over your chest.',
      image: 'assets/images/gesture_please_generated.png',
      category: 'Daily Conversation',
      isLiveRecognized: true,
    ),
    GestureModel(
      id: 'SORRY',
      name: 'SORRY',
      description: 'A closed fist rubbing in a circular motion horizontally over the chest.',
      image: 'assets/images/gesture_sorry_generated.png',
      category: 'Daily Conversation',
      isLiveRecognized: true,
    ),

    // SENTENCES
    GestureModel(
      id: 'PhraseEatWithMe',
      name: 'EAT WITH ME',
      description: 'Sequential signs: ME + WANT + FOOD. Form a request to dine.',
      image: 'assets/images/eat_with_me_sign_1778405465691.png',
      category: 'Sentences',
      isLiveRecognized: false,
    ),

    // TECHNOLOGY
    GestureModel(
      id: 'TechComputerBroken',
      name: 'COMPUTER BROKEN',
      description: 'Sequential signs: SORRY + NO. Tells someone your machine is down.',
      image: 'assets/images/computer_broken_sign_1778405549181.png',
      category: 'Technology',
      isLiveRecognized: false,
    ),
    GestureModel(
      id: 'TechSocialMedia',
      name: 'SOCIAL MEDIA CHECK',
      description: 'Sequential signs: SIGN + YOU. Tells someone to check the feed.',
      image: 'assets/images/social_media_sign_1778405533507.png',
      category: 'Technology',
      isLiveRecognized: false,
    ),

    // TRAVEL
    GestureModel(
      id: 'TravelTicketWhere',
      name: 'TICKET WHERE?',
      description: 'Sequential signs: WANT + GO. Enquire where to buy tickets.',
      image: 'assets/images/ticket_where_sign_1778405564733.png',
      category: 'Travel',
      isLiveRecognized: false,
    ),
    GestureModel(
      id: 'TravelTrainArrive',
      name: 'TRAIN ARRIVE WHEN?',
      description: 'Sequential signs: GO + WHERE. Enquire about transportation timings.',
      image: 'assets/images/train_arrive_sign_1778405499779.png',
      category: 'Travel',
      isLiveRecognized: false,
    ),

    // EMOTION
    GestureModel(
      id: 'EmotionHappy',
      name: 'FEEL HAPPY TODAY',
      description: 'Sequential signs: ME + HELLO. Signals happiness or well-being.',
      image: 'assets/images/happy_today_sign_1778405659477.png',
      category: 'Emotion',
      isLiveRecognized: false,
    ),
  ];

  List<GestureModel> getAllGestures() => _gestures;

  // Bookmarks Logic
  List<String> getBookmarks(String userId) {
    return _prefs.getStringList('${keyBookmarks}_$userId') ?? [];
  }

  Future<void> toggleBookmark(String userId, String gestureId) async {
    final list = getBookmarks(userId);
    if (list.contains(gestureId)) {
      list.remove(gestureId);
    } else {
      list.add(gestureId);
    }
    await _prefs.setStringList('${keyBookmarks}_$userId', list);
  }

  // Progress Completed Logic
  List<String> getProgress(String userId) {
    return _prefs.getStringList('${keyProgress}_$userId') ?? [];
  }

  Future<void> completeGesture(String userId, String gestureId) async {
    final list = getProgress(userId);
    if (!list.contains(gestureId)) {
      list.add(gestureId);
      await _prefs.setStringList('${keyProgress}_$userId', list);
    }
  }
}
