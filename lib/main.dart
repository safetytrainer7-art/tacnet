import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

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
  bool isNvgOnline = false;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAppwrite();
  }

  void _initAppwrite() {
    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6a38e834003e0cc64c31'); // Your exact live project ID
    databases = Databases(client);
  }

  // Simulates firing a packet when NVG is toggled
  void _toggleNvg(bool value) async {
    setState(() {
      isNvgOnline = value;
    });

    if (isNvgOnline) {
      try {
        await databases.createDocument(
          databaseId: 'tacnet-search-app',
          collectionId: 'tacnet_live_units',
          documentId: ID.unique(),
          data: {
            'tacnet_live_units': 'Field-Unit-Alpha',
            'location': '37.525, -79.124',
            'operationalStatus': 'TACTICAL_STANDBY',
            'lastUpdateTime': '09:00',
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tactical link established with server.')),
        );
      } catch (e) {
        // Handled internally
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. MAIN MAP VIEW AREA
          Positioned.fill(
            child: Container(
              color: const Color(0xFF020803), // Mock Tactical Map Grid
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 80, color: Colors.white24),
                    const SizedBox(height: 10),
                    Text(
                      isNvgOnline ? "LIVE SECTOR GRID ACTIVE" : "STANDBY MODE",
                      style: const TextStyle(color: Colors.white54, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. HIGH-VISIBILITY LIME GREEN GPS REAL-TIME DOT
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.5 - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00), // Pure Lime Green
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          // 3. INTERFACE OVERLAYS (Top Header & Controls)
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                // NVG TOGGLE BUTTON
                GestureDetector(
                  onTap: () => _toggleNvg(!isNvgOnline),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isNvgOnline ? const Color(0xFF00FF00).withOpacity(0.2) : Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isNvgOnline ? const Color(0xFF00FF00) : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isNvgOnline ? "NVG ONLINE" : "NVG OFFLINE",
                      style: TextStyle(
                        color: isNvgOnline ? const Color(0xFF00FF00) : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

          // 4. FULL-SCREEN SEARCH INTERFACE (Utilizes 100% of the screen advantage)
          if (isSearching)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF051207), // Full-Screen Tactical Background Override
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Header Block
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text(
                          "TACTICAL REGISTRY SEARCH",
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
                    // Input Bar stretched across the display width
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
                    // Expanded Workspace Results area utilizing the remaining display height
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
