import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mango AI 2050',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent.shade700,
          brightness: Brightness.light,
        ),
        fontFamily: 'RobotoMono',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  File? _filePath;
  double _confidence = 0.0;
  String _label = "";
  bool _isLoading = false;
  String? _aiRecommendation;
  String? _dailyTip;

  @override
  void initState() {
    super.initState();
    _tfliteInit();
    _fetchDailyTip();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _tfliteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _fetchAiRecommendations() async {
    const apiKey =
        'AIzaSyD2b7cTOvjylks-atfKGl_MBsFTAn29edE'; // Replace with your actual API key
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    final prompt =
        'Give 5 short one line each bullet-point format (1,2,3,4,5), dont add asteriks, recommendations for a plant with the disease: $_label. The recommendations should be practical and easy to follow for home gardeners.';
    final content = [Content.text(prompt)];
    try {
      final response = await model.generateContent(content);
      setState(() {
        _aiRecommendation = response.text ?? 'No recommendations found.';
      });
    } catch (e) {
      setState(() {
        _aiRecommendation = 'Error fetching recommendations.';
      });
    }
  }

  Future<void> _fetchDailyTip() async {
    const apiKey =
        'AIzaSyD2b7cTOvjylks-atfKGl_MBsFTAn29edE'; // Replace with your actual API key
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    final prompt =
        'Generate a short and practical daily tip for general plant care. The tip should be one to two sentences long.';
    final content = [Content.text(prompt)];
    try {
      final response = await model.generateContent(content);
      setState(() {
        _dailyTip = response.text ?? 'No daily tip available.';
      });
    } catch (e) {
      setState(() {
        _dailyTip = 'Error fetching daily tip.';
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (_filePath == null || _isLoading) {
      // Exit if no image is selected or if analysis is already running
      return;
    }

    setState(() {
      _isLoading = true;
      _confidence = 0.0;
      _label = "";
      _aiRecommendation = null;
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: _filePath!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          _confidence = recognitions[0]['confidence'] * 100;
          _label = recognitions[0]['label'].toString();
        });
        await _fetchAiRecommendations();
      }
    } catch (e) {
      print('TFLite Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _selectedIndex = 1;
      });
    }
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _filePath = File(image.path);
    });
  }

  void _pickImageCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _filePath = File(image.path);
    });
  }

  Widget _buildScanScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
           decoration: const BoxDecoration(
  gradient: LinearGradient(
    colors: [  Color.fromARGB(255, 40, 98, 56),
                  Color.fromARGB(255, 132, 203, 129),],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
),


            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage("assets/leaf.png"), width: 70),
                const SizedBox(height: 10),
                const Text(
                  "Detect Mango Disease",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Upload or capture a photo of your mango plant to identify disease and get instant care recommendations.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.camera, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Text(
                        "Select Plant Image",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DottedBorder(
                    options: RectDottedBorderOptions(
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashPattern: const [6, 3],
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(184, 238, 238, 238),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _filePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Tap Camera or Gallery",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Supports JPG, PNG formats",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _filePath!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _pickImageCamera,
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: const Text(
                          "Camera",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _pickImageGallery,
                        icon: const Icon(Icons.image, size: 25,color: Colors.black),
                        label: const Text(
                          "Gallery",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: _runAnalysis,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 40, 98, 56),
                  Color.fromARGB(255, 132, 203, 129),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.electric_bolt, size: 25,color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Analyze Plant Disease",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisScreen() {
    if (_label.isEmpty) {
      return const Center(
        child: Text(
          "No analysis results. Please scan a plant image first.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Add a loading state for the analysis screen
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '💡 Analysis Results',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  'Accuracy',
                  '${_confidence.toStringAsFixed(0)}%',
                  const Color(0xFF55B771),
                  const Color(0xFF90DC8C),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultCard(
                  'Disease',
                  _label,
                  const Color(0xFFFFAE5F),
                  const Color(0xFFFFCC7A),
                  Icons.eco_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAiRecommendationSection(),
          const SizedBox(height: 24),
          _buildDailyTipSection(),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    Color startColor,
    Color endColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🤖 AI Recommendations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _aiRecommendation == null
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    _aiRecommendation!,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTipSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF53C071),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📢 Daily Plant Care Tip',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _dailyTip == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Text(
                  _dailyTip!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF53C071),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'More Tips',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      _buildScanScreen(),
      _buildAnalysisScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        actionsPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        title: Text(
          "Mango Disease Detection",
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 2,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [Icon(Icons.person, color: Colors.black)],
      ),
      body: Center(
        child: IndexedStack(index: _selectedIndex, children: widgetOptions),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Scan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Ali Raza'),
              accountEmail: Text('alisraza123@gmail.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 30, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF55B771), const Color(0xFF90DC8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
