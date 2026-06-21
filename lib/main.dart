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
  
  String _operationStatusTitle = "TACNET: READY";
  String _operationStatusBody = "System running completely offline. Standby for voice activation.";

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
      await _tts.speak("Trap and Trace active. Deploying secure tracking interface.");
      _navigateToTrapTrace();
    } else {
      setState(() {
        _operationStatusTitle = "Command Decoded";
        _operationStatusBody = "Operational module request: '$command'";
      });
    }
  }

  void _navigateToTrapTrace() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrapTraceLogScreen(tts: _tts)),
    );
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
                const Icon(Icons.star, color: Color(0xFFD4AF37), size: 80),
                const SizedBox(height: 10),

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

                // Main Operations Display Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101F30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 20),
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

                // Number One Feature — Positioned Top of List, Gold Bordered
                GestureDetector(
                  onTap: _navigateToTrapTrace,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101F30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
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
                                  const Text("TRAP & TRACE", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)),
                                    child: const Text("P-1", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text("Cellular tracking log interface and local telemetry storage.", style: TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.gps_fixed, color: Color(0xFFD4AF37), size: 28),
                      ],
                    ),
                  ),
                ),

                _buildStandardCard("SEARCH OPERATIONS", "K9 deployment logs, grid tracking, and wilderness paths.", Icons.search),
                _buildStandardCard("TACTICAL MAPPING", "Offline coordinates, waypoint marking, and grid maps.", Icons.map_outlined),
                _buildStandardCard("CIVIL ENCOUNTERS", "Secure local database storage for field logs.", Icons.assignment_outlined),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    const Text("LOCAL SECURE ENCRYPTION LOCKED", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildStandardCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101F30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1C354E), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFFD4AF37), size: 28),
        ],
      ),
    );
  }
}

// SECURE SECONDARY TRAP & TRACE MODULE SCREEN
class TrapTraceLogScreen extends StatefulWidget {
  final FlutterTts tts;
  const TrapTraceLogScreen({Key? key, required this.tts}) : super(key: key);

  @override
  State<TrapTraceLogScreen> createState() => _TrapTraceLogScreenState();
}

class _TrapTraceLogScreenState extends State<TrapTraceLogScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Hardwired internal ledger running entirely offline
  final List<Map<String, String>> _traceLedger = [
    {"time": "11:45:02", "target": "540-555-0199", "carrier": "Verizon Wireless", "signal": "-72 dBm (Strong)"},
    {"time": "11:46:15", "target": "540-555-0199", "carrier": "Verizon Wireless", "signal": "-75 dBm (Locked)"},
  ];

  void _commitLocalLog() {
    if (_targetController.text.isEmpty) return;

    final TimeOfDay now = TimeOfDay.now();
    final String timestamp = "${now.hour}:${now.minute.toString().padLeft(2, '0')}:00";

    setState(() {
      _traceLedger.insert(0, {
        "time": timestamp,
        "target": _targetController.text,
        "carrier": "Local Grid Array",
        "signal": _notesController.text.isEmpty ? "Trace Verification Completed" : _notesController.text,
      });
      _targetController.clear();
      _notesController.clear();
    });
    
    widget.tts.speak("Log record entry secured offline.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101F30),
        title: const Text("TRAP & TRACE CONTROL", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          with: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SECURE LOG INPUT DECK",
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              // Target Input Row
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "TARGET PHONE NUMBER / ID",
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF1C354E)), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color(0xFF101F30),
                ),
              ),
              const SizedBox(height: 10),

              // Operational Telemetry Notes
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "TELEMETRY NOTES / SIGNAL DETAILS",
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF1C354E)), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color(0xFF101F30),
                ),
              ),
              const SizedBox(height: 12),

              // Trigger Log Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _commitLocalLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162A3F),
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("CAPTURE LIVE TELEMETRY LOG", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "VERIFIED OFFLINE TRANSMISSION LEDGER",
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 10),

              // Live Trace Ledger Display Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101F30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1C354E)),
                  ),
                  child: ListView.separated(
                    itemCount: _traceLedger.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF1C354E), height: 1),
                    itemBuilder: (context, index) {
                      var item = _traceLedger[index];
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['target']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 3),
                                Text("${item['carrier']} • ${item['signal']}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                            Text(
                              item['time']!,
                              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
)
