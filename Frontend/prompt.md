# Sign Language Mobile Application Prompt

Copy and paste this structured prompt into any agentic coding assistant (such as Cursor, Lovable, Bolt.new, or v0) to build or extend this application:

```text
Create a high-fidelity mobile application for real-time Sign Language Translation to Speech ("SignSpeak Mobile"). 

### 1. Technology Stack
- Core: React (using Vite)
- Database: IndexedDB via Dexie.js for client-side storage
- Styling: Custom Vanilla CSS (Dark-slate futuristic style, neon glows, glassmorphism, responsive mobile frame)
- Hand Tracking & ML Inference: MediaPipe Hands API loaded via CDN (camera_utils, drawing_utils, hands)
- Speech Engine: Web Speech Synthesis API

### 2. Architecture & Database Schema (Dexie)
Configure a database called 'SignSpeakMobileDB' with the following tables:
- users: '++id, &username, &email, passwordHash, preferredVoice'
- history: '++id, userId, text, timestamp'
- bookmarks: '++id, userId, gestureId, [userId+gestureId]'
- progress: '++id, userId, gestureId, completed, [userId+gestureId]'

Secure password registration/login by computing SHA-256 hashes client-side via the SubtleCrypto Web API.

### 3. Layout & Screens
The application must render inside a centered smartphone device mock frame on desktop view and take up full screen on mobile view. It must support 6 screen states:
1. Splash Screen: Glowing animated logo loader. Takes 2.5 seconds to simulate loading, then redirects.
2. Authentication Screen: Login and Signup tabs. Registers users in 'db.users' and initiates a session storage session.
3. Live Translation Screen: Starts the webcam in a 4:3 mirror container. Overlays MediaPipe landmarks. Throttles frame detection by skipping frames to save mobile performance. Decodes gestures using rule-based algorithms. Integrates a phrase builder that triggers TTS vocalization and automatically saves completed phrases and Base64 visual snapshots to 'db.history' when sentences match.
4. Learning Section (Tutorials): Shows a list of categorized gestures (Beginner, Conversational, Emergency). Users can bookmark cards (Star icon, saves to 'db.bookmarks') and click 'Practice Live' which opens a camera overlay, detects if the hand matches the card's gesture, and saves progress to 'db.progress' upon 5 consecutive frames.
5. History Archive: Retrieves user logs from 'db.history'. Displays dates, textual outputs, base64 hand snapshots, and offers delete-single and purge-all actions.
6. Settings Screen: Shows account info (username, email) and user statistics. Allows picking a custom voice from the browser's speechSynthesis voice array (saves to user preferences) and performing a factory reset (wiping database).

### 4. Custom Gestures Evaluator
Use coordinate distance algorithms mapping landmark arrays to evaluate:
- YES: closed fist with thumb up
- STOP: fist
- NO: index/middle extended tapping thumb
- HELLO: flat palm
- WATER: W-shape
- HOSPITAL: H-shape
- EAT: flattened O-shape near mouth
- ILY: thumb, index, pinky open
- ME: thumb open horizontally
- YOU: index pointing up
- PLEASE: flat hand horizontal
- SORRY: fist horizontal
- AGAIN: bent hand no thumb
- SLOW: flat hand sliding
- GO: index fingers pointing forward
```
