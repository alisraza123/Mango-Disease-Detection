🍃 Mango Disease Detection
(Flutter + TensorFlow Lite + Gemini)

An on-device Flutter application that detects mango leaf diseases using a TensorFlow Lite model (trained via Google Teachable Machine) and leverages Gemini 2.5 Flash to provide practical disease care recommendations and a daily plant-care tip.

📸 Screenshots
![Home Screen](./screenshots/home.jpg)
![Upload Screen](./screenshots/upload.jpg)
![Analysis Screen](./screenshots/analysis.jpg)

✨ Features

✔ On-device inference (fast & private) using flutter_tflite
✔ Image input via Camera or Gallery using image_picker
✔ Modern UI with dotted upload area, gradient buttons, and bottom navigation (Scan / Analysis)
✔ AI Recommendations: Gemini 2.5 Flash provides 5 short, actionable tips for the detected disease
✔ Daily Tip: Auto-generated plant-care suggestion
✔ Responsive Layout – images fit properly using ClipRRect + BoxFit.contain

🧪 Dataset & Model

Classes (8 Mango Leaf Disease Categories):
1️⃣ Anthracnose
2️⃣ Powdery Mildew
3️⃣ Sooty Mold
4️⃣ Bacterial Canker
5️⃣ Dieback
6️⃣ Gall Midge
7️⃣ Cutting Weevil
8️⃣ Healthy Leaf

Images per class: ~1,200

Total images: ≈ 9,600

Training: Google Teachable Machine → Export as TFLite

Model Files:

assets/model_unquant.tflite
assets/labels.txt


✅ Ensure labels.txt order matches model output indices

📱 Tech Stack

Flutter (Dart)

Core Packages:

dependencies:
  flutter:
    sdk: flutter
  image_picker: ^0.8.9
  flutter_tflite: ^1.0.1
  dotted_border: ^3.1.0
  google_generative_ai: ^0.2.2

📂 Project Structure
assets/
  ├── model_unquant.tflite
  ├── labels.txt
  └── leaf.png
lib/
  ├── main.dart
  ├── ai_screen.dart
  └── widgets/ (shared UI components)


Add assets in pubspec.yaml:

flutter:
  uses-material-design: true
  assets:
    - assets/model_unquant.tflite
    - assets/labels.txt
    - assets/leaf.png

🔧 Setup & Installation
1. Clone the Repository
git clone https://github.com/alisraza123/Mango-Disease-Detection.git
cd Mango-Disease-Detection

2. Add Model Files

Place model_unquant.tflite, labels.txt, and leaf.png under assets/ and register them in pubspec.yaml.

3. Install Dependencies
flutter pub get

4. Update Android Permissions (AndroidManifest.xml)
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

5. Update iOS Permissions (Info.plist)
<key>NSCameraUsageDescription</key>
<string>Need camera to capture plant leaves.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need photo library to pick images of plant leaves.</string>

6. Set Gemini API Key
const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');


Run with:

flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY

🚀 Running the App
flutter run


Steps:
✔ Choose a device/emulator
✔ Tap Scan → Capture/Pick an image
✔ Tap Analyze → Get predictions & AI tips

✅ Testing

Test with real images (camera/gallery)

Validate predictions against known labels

Ensure labels.txt matches model output

Manual Checklist

 Camera capture works on Android & iOS

 Gallery picker returns valid file path

 TFLite loads without errors

 Analyze button shows spinner during processing

 Confidence & label appear only after analysis

 Gemini returns 5 bullet tips + daily tip

🤝 Contributing

PRs are welcome! Please open an issue before major changes to ensure design and model consistency.

👤 Author

Ali Raza
📧 alisraza123@gmail.com

“Passionate about AI-powered mobile solutions using Flutter & TensorFlow Lite.”
