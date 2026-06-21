import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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

class _TacnetHomeScreenState extends State<TacnetHomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  
  // Network Configurations
  late Client _client;
  late Realtime _realtime;
  RealtimeSubscription? _subscription;
  bool _isOnline = false;

  // Map Layer States - Matches 6yhy.jpg strictly
  String _currentMapLayer = "SAT"; 
  final TextEditingController _searchController = TextEditingController(text: "Address or Track Phone...");

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _initAppwriteNetwork();
  }

  void _initAppwriteNetwork() {
    _client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6a37d453000ed7b5eff5');
    _realtime = Realtime(_client);
  }

  void _toggleOnlineStatus() {
    if (!_isOnline) {
      try {
        _subscription = _realtime.subscribe(['databases.tacnet-search-app.collections.virginia_statutes.documents']);
        _subscription!.stream.listen((response) {
          _tts.speak("Team signal coordinates updated.");
        });
        setState(() {
          _isOnline = true;
        });
        _tts.speak("Tactical map synchronization active.");
      } catch (e) {
        _tts.speak("Connection timeout.");
      }
    } else {
      _subscription?.close();
      setState(() {
        _isOnline = false;
      });
      _tts.speak("Tactical network disconnected.");
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
    _subscription?.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Deck - Re-locked to 6yhy.jpg layout exactly
            Container(
              color: const Color(0xFF0D1B2A),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.green, size: 22),
                  const SizedBox(width: 8),

                  // SAT Map Layer Button
                  _buildMapToggleBtn("SAT"),
                  const SizedBox(width: 4),

                  // TERR Terrain Layer Button
                  _buildMapToggleBtn("TERR"),
                  const SizedBox(width: 10),

                  // Core Address / Track Phone Input Deck
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

                  // GO Action Target Execution Button
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
                  const SizedBox(width: 4),

                  // CLEAR MAP System Button
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C354E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text("CLEAR MAP", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Main Map Presentation Viewport Array
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF0F2032),
                    child: Center(
                      child: Text(
                        "TACTICAL MAP WINDOW RUNNING: $_currentMapLayer LAYER",
                        style: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),

                  // Left Side Mapping Zoom Matrix Buttons
                  Positioned(
                    top: 20,
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

                  // Right Side Operational Command Deck Controls
                  Positioned(
                    top: 20,
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
                        GestureDetector(
                          onTap: _toggleOnlineStatus,
                          child: _buildSideMapControl("NVG", fontSize: 10, isActive: _isOnline),
                        ),
                      ],
                    ),
                  ),

                  // Heading Tracker Box
                  Positioned(
                    bottom: 80,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF1C354E)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.navigation, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text("HDG: 000°", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Target Tracker Team Color Legend Strip
                  Positioned(
                    bottom: 15,
                    left: 10,
                    right: 10,
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
                ],
              ),
            ),

            // Bottom Emergency Deployment Command Bar
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

            // Master Bottom Navigation Panel Deck
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
