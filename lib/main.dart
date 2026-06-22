import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

void main() {
  runApp(const TacnetMasterApp());
}

class TacnetMasterApp extends StatelessWidget {
  const TacnetMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TACNET Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A141D),
      ),
      home: const TacnetHomeScreen(),
    );
  }
}

class TacnetHomeScreen extends StatefulWidget {
  const TacnetHomeScreen({Key? key}) : super(key: key);

  @override
  State<TacnetHomeScreen> createState() => _TacnetHomeScreenState();
}

class _TacnetHomeScreenState extends State<TacnetHomeScreen> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Core Appwrite Backend Links
  late Client _client;
  late Account _account;
  late Databases _databases;
  bool _isOnline = false;
  String _unitIdentifier = "";

  // Map Layer Configuration
  String _currentMapLayer = "SAT"; 
  final TextEditingController _searchController = TextEditingController(text: "Address or Track Phone...");

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    
    // Automatically generate a local temporary unit ID (e.g., K9-Unit-452)
    _unitIdentifier = "K9-Unit-${Random().nextInt(900) + 100}";

    // Flashing Beacon Controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 4.0, end: 24.0).animate(_pulseController);

    _initAppwriteSystem();
  }

  // WIRELESS CONNECTION SETUP
  void _initAppwriteSystem() {
    _client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6a37d453000ed7b5eff5'); // Your actual Appwrite Project ID
    
    _account = Account(_client);
    _databases = Databases(_client);
  }

  // FOOLPROOF ONE-TAP LOGIN AND LINK
  Future<void> _connectToTacticalNetwork() async {
    if (!_isOnline) {
      try {
        // Step 1: Log the phone in anonymously with zero passwords needed
        await _account.createAnonymousSession();
        
        setState(() {
          _isOnline = true;
        });
        _tts.speak("$_unitIdentifier is now active on the tactical network.");
        
        // Step 2: Push the initial deployment log straight up to your dashboard console
        await _databases.createDocument(
          databaseId: 'tacnet-search-app', // Using your database string
          collectionId: 'virginia_statutes', // Direct collection pathway
          documentId: ID.unique(),
          data: {
            'statute_title': 'UNIT_DEPLOYED',
            'statute_number': _unitIdentifier,
            'summary': 'Device actively connected to search perimeter.',
          },
        );
      } catch (e) {
        _tts.speak("Network connection error. Check server access.");
        print("Appwrite Error: $e");
      }
    } else {
      // Disconnect cleanly
      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}
      setState(() {
        _isOnline = false;
      });
      _tts.speak("Tactical network disconnected. Offline status.");
    }
  }

  void _setMapLayer(String layerType) {
    setState(() {
      _currentMapLayer = layerType;
    });
    _tts.speak("$layerType view active.");
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Full Screen Edge-to-Edge Visual Mapping Window
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0F2032),
              child: Center(
                child: Text(
                  "TACTICAL MAP WINDOW RUNNING: $_currentMapLayer LAYER (FULLSCREEN)",
                  style: const TextStyle(color: Colors.white24, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            ),

            // Continuous Flashing Lime Green GPS Beacon
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _pulseAnimation.value * 2,
                        height: _pulseAnimation.value * 2,
                        decoration: BoxDecoration(
                          color: const Color(0x3339FF14), 
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF39FF14), width: 1.5),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF39FF14), 
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0xFF39FF14), blurRadius: 10, spreadRadius: 2)
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Floating Top Header Deck
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xEE0D1B2A), 
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1C354E)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.green, size: 22),
                    const SizedBox(width: 8),
                    _buildMapToggleBtn("SAT"),
                    const SizedBox(width: 4),
                    _buildMapToggleBtn("TERR"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF1C354E)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text("GO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Left Side Control Buttons
            Positioned(
              top: 80,
              left: 10,
              child: Column(
                children: [
                  _buildSideMapControl("PERIMETER\n500m", height: 38, fontSize: 8),
                  const SizedBox(height: 6),
                  _buildSideMapControl("+", fontSize: 18),
                  const SizedBox(height: 4),
                  _buildSideMapControl("-", fontSize: 18),
                ],
              ),
            ),

            // Floating Right Side Strategic Control Buttons
            Positioned(
              top: 80,
              right: 10,
              child: Column(
                children: [
                  _buildSideMapControl("PEN", fontSize: 10),
                  const SizedBox(height: 6),
                  _buildSideMapControl("ERASE", fontSize: 10),
                  const SizedBox(height: 6),
                  _buildSideMapControl("FIND\nME", fontSize: 9),
                  const SizedBox(height: 6),
                  _buildSideMapControl("LOCK", fontSize: 10),
                  const SizedBox(height: 6),
                  // Linked directly to the clean Appwrite connection pipeline
                  GestureDetector(
                    onTap: _connectToTacticalNetwork,
                    child: _buildSideMapControl("NVG", fontSize: 10, isActive: _isOnline),
                  ),
                ],
              ),
            ),

            // Floating Compass Window
            Positioned(
              bottom: 155,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1C354E), width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "HDG: 000°", 
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Console Overlay Deck
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xDD0A141D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLegendDot("K9 Team", Colors.blue),
                          _buildLegendDot("LE Blue", Colors.blueAccent),
                          _buildLegendDot("VSP State", Colors.indigo),
                          _buildLegendDot("Feds Gold", Colors.amber),
                          _buildLegendDot("SAR Red", Colors.red),
                          _buildLegendDot("Civ Green", Colors.green),
                          _buildLegendDot("Suspect", Colors.purple),
                          _buildLegendDot("Victim", Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text("OFFICER EMERGENCY ALERT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                      ],
                    ),
                  ),

                  Container(
                    color: const Color(0xFF0D1B2A),
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: const Color(0xFF1C354E),
                            child: const Center(
                              child: Text("CLEAR NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.red.shade900,
                            child: const Center(
                              child: Text("TERMINATE SEARCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapToggleBtn(String label) {
    bool isCurrent = _currentMapLayer == label;
    return GestureDetector(
      onTap: () => _setMapLayer(label),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isCurrent ? Colors.blue : const Color(0xFF1C354E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: isCurrent ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSideMapControl(String text, {double? height, double fontSize = 11, bool isActive = false}) {
    return Container(
      width: 50,
      height: height ?? 32,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1C354E)),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: isActive ? Colors.black : Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLegendDot(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
