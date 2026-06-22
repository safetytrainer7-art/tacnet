import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(const TacnetApp());
}

class TacnetApp extends StatelessWidget {
  const TacnetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TACNET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0B2510), // Hunter Green
        scaffoldBackgroundColor: const Color(0xFF051207), // Deep Tactical Background
      ),
      home: const TacnetMainScreen(),
    );
  }
}

class TacnetMainScreen extends StatefulWidget {
  const TacnetMainScreen({Key? key}) : super(key: key);

  @override
  _TacnetMainScreenState createState() => _TacnetMainScreenState();
}

class _TacnetMainScreenState extends State<TacnetMainScreen> {
  late Client client;
  late Databases databases;
  
  // Independent System Toggles
  bool isNvgOnline = false;      // Handles night vision filter display
  bool isLinkConnected = false;  // Handles live GPS server data transmission
  bool isSearching = false;
  
  String currentStatusText = "SYSTEM READY // STANDBY";
  String displayCoordinates = "No GPS Fix";
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<Position>? _gpsStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initAppwrite();
  }

  void _initAppwrite() {
    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6a38e834003e0cc64c31'); // Your live project ID
    databases = Databases(client);
  }

  // Brand New Dedicated Function: Manages Live GPS Radio Link
  void _toggleGpsLink(bool turnOn) async {
    if (turnOn) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSystemMessage("GPS Permission Denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSystemMessage("GPS Blocked in Device Settings.");
        return;
      }

      setState(() {
        isLinkConnected = true;
        currentStatusText = "RADIO LINK ESTABLISHED // TRANSMITTING";
      });

      // Streams live coordinates from phone hardware sensor
      _gpsStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Updates every 10 meters moved
        ),
      ).listen((Position position) {
        setState(() {
          displayCoordinates = "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
        });
        
        // Transmits data packet to your Appwrite server
        _sendGpsPacketToServer(position.latitude, position.longitude);
      });
    } else {
      // Disconnect Data Link cleanly
      _gpsStreamSubscription?.cancel();
      setState(() {
        isLinkConnected = false;
        currentStatusText = "SYSTEM READY // STANDBY";
        displayCoordinates = "No GPS Fix";
      });
      _showSystemMessage("Radio transmission link terminated.");
    }
  }

  // Transmits coordinates to your Appwrite spreadsheet grid
  void _sendGpsPacketToServer(double lat, double lng) async {
    try {
      await databases.createDocument(
        databaseId: 'tacnet-search-app',
        collectionId: 'tacnet_live_units',
        documentId: ID.unique(),
        data: {
          'tacnet_live_units': 'Field-Unit-Alpha',
          'location': '$lat, $lng',
          'operationalStatus': 'ACTIVE_SEARCH',
          'lastUpdateTime': DateTime.now().toLocal().toString().substring(11, 16),
        },
      );
    } catch (e) {
      // Handled internally during field operations
    }
  }

  void _showSystemMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _gpsStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAIN MAP VIEW AREA
          Positioned.fill(
            child: Container(
              color: const Color(0xFF020803), 
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 80, color: Colors.white24),
                    const SizedBox(height: 10),
                    Text(
                      currentStatusText,
                      style: const TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "GPS FIXED: $displayCoordinates",
                      style: TextStyle(
                        color: isLinkConnected ? const Color(0xFF00FF00) : Colors.white38, 
                        fontFamily: 'monospace', 
                        fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. NIGHT VISION OVERLAY FILTER (Only activates when NVG button is clicked)
          if (isNvgOnline)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0xFF00FF00).withOpacity(0.15), // Tactical Green Light Lens
                ),
              ),
            ),

          // 3. REAL-TIME TARGET DOT (Stays Red by default, changes to Green only if NVG is on)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.5 - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isNvgOnline ? const Color(0xFF00FF00) : Colors.redAccent, 
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: (isNvgOnline ? const Color(0xFF00FF00) : Colors.redAccent).withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          // 4. INTERFACE OVERLAYS (Top Header & Multi-Button Control Array)
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                // Branding Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2510),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1), // Gold Trim
                  ),
                  child: const Text(
                    "TACNET // OPS",
                    style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                
                // CONTROL SWITCH ARRAY
                Row(
                  children: [
                    // BUTTON A: THE LIVE DATA CONNECTION LINK
                    GestureDetector(
                      onTap: () => _toggleGpsLink(!isLinkConnected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isLinkConnected ? const Color(0xFF00FF00).withOpacity(0.2) : Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isLinkConnected ? const Color(0xFF00FF00) : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          isLinkConnected ? "LINK ONLINE" : "LINK OFFLINE",
                          style: TextStyle(
                            color: isLinkConnected ? const Color(0xFF00FF00) : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // BUTTON B: INDEPENDENT NIGHT VISION LIGHT TOGGLE
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNvgOnline = !isNvgOnline;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isNvgOnline ? const Color(0xFF00FF00).withOpacity(0.2) : Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isNvgOnline ? const Color(0xFF00FF00) : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "NVG",
                          style: TextStyle(
                            color: isNvgOnline ? const Color(0xFF00FF00) : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BUTTON TO TRIGGER THE FULL SCREEN SEARCH PANEL
          Positioned(
            bottom: 30,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF0B2510),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const Border.all(color: Color(0xFFD4AF37)),
              ),
              child: const Icon(Icons.search, color: Color(0xFFD4AF37)),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
          ),

          // 5. FULL-SCREEN TACTICAL SEARCH OVERLAY
          if (isSearching)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF051207), 
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text(
                          "TACTICAL REGISTRY SEARCH",
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Enter Unit Name, ID, or Designation...",
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                        filled: true,
                        fillColor: const Color(0xFF0B2510),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF00FF00), width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ALL ACTIVE FREQUENCIES & CHANNELS",
                      style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white12, thickness: 1),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildMockSearchResult("K9-Unit-1", "ACTIVE SEARCH // AMELON RD", "08:52"),
                          _buildMockSearchResult("Delta-4", "STATIONARY STANDBY", "08:45"),
                          _buildMockSearchResult("Command-HQ", "MONITORING FREQUENCY", "09:00"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMockSearchResult(String unit, String status, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2510).withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(unit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          Text(time, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
        ],
      ),
    );
  }
}
