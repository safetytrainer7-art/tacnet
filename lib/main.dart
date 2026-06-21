import 'package:flutter/material.dart';
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
        scaffoldBackgroundColor: const Color(0xFF0A141D), // Royal/Tactical Dark Blue backing
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
  
  // Local Database Vault: Stores mission data right on the device chips
  final List<Map<String, String>> _localTrapTraceLogs = [
    {"timestamp": "14:22", "target": "Target-Alpha", "sector": "Sector 4 - Active Ping"},
    {"timestamp": "14:45", "target": "Target-Alpha", "sector": "Sector 2 - Signal Trace Locked"},
  ];

  String _operationStatusTitle = "TRAP & TRACE: ACTIVE";
  String _operationStatusBody = "System running completely offline. Monitoring local tracking arrays.";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
  }

  void _toggleVoiceActivation() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            if (val.finalResult) {
              _isListening = false;
              _processVoiceCommand(val.recognizedWords);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoiceCommand(String command) async {
    String cleanCommand = command.toLowerCase();
    
    if (cleanCommand.contains("trace") || cleanCommand.contains("trap")) {
      setState(() {
        _operationStatusTitle = "Trap & Trace Triggered";
        _operationStatusBody = "Voice command recognized. Executing target vector scanning.";
      });
      await _tts.speak("Trap and Trace active. Initiating target tracking routine.");
    } else {
      setState(() {
        _operationStatusTitle = "Command Received";
        _operationStatusBody = "Processing operation: '$command'";
      });
    }
  }

  void _executeFeatureAction(String featureName) {
    setState(() {
      _operationStatusTitle = "$featureName DECK";
      _operationStatusBody = "Opening secure local module for $featureName. Zero network lag.";
    });
    _tts.speak("Opening $featureName module.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gold Star Insignia
                const Icon(Icons.star, color: Color(0xFFD4AF37), size: 80),
                const SizedBox(height: 10),

                // TACNET Heading
                const Text(
                  "TACNET",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                ),
                const Text(
                  "Tactical Search & Signal Operations Management",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),

                // Dynamic Live Status Display Screen
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101F30), // Dark Navy Box
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.radar, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(_operationStatusTitle, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_operationStatusBody, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Hands-Free Microphone Activation Hub
                Center(
                  child: GestureDetector(
                    onTap: _toggleVoiceActivation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF162A3F),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("TAP TO SPEAK", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Icon(_isListening ? Icons.mic : Icons.mic_none, color: const Color(0xFFD4AF37), size: 36),
                          const SizedBox(height: 8),
                          const Text("VOICE ACTIVATE", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // MODULE CARDS - Number One Feature Positioned Top Left
                _buildModuleCard("TRAP & TRACE", "Cellular tracking, line routing, and signal trace sweeps.", Icons.gps_fixed, isPremium: true),
                _buildModuleCard("SEARCH OPERATIONS", "K9 deployment logs, grid tracking, and wilderness paths.", Icons.search),
                _buildModuleCard("TACTICAL MAPPING", "Offline coordinates, waypoint marking, and grid maps.", Icons.map_outlined),
                _buildModuleCard("CIVIL ENCOUNTERS", "Secure local database storage for field logs.", Icons.assignment_outlined),
                const SizedBox(height: 25),

                // Secure Local Lock Light Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    const Text("LOCAL DATA INTEGRITY SECURED", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),

                const Divider(color: Color(0xFF162A3F), thickness: 1),
                const SizedBox(height: 5),
                const Text(
                  "ALL RIGHTS RESERVED.\nAPP CREATED BY DEPUTY SHERIFF EARL A. WOOD\nRETIRED VIRGINIA!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(String title, String subtitle, IconData icon, {bool isPremium = false}) {
    return GestureDetector(
      onTap: () => _executeFeatureAction(title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFF101F30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium ? const Color(0xFFD4AF37) : const Color(0xFF1C354E), 
            width: isPremium ? 2.0 : 1.5
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)),
                          child: const Text("P-1", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            Icon(icon, color: const Color(0xFFD4AF37), size: 28),
          ],
        ),
      ),
    );
  }
}
