import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class CosmoGramDashboard extends StatefulWidget {
  const CosmoGramDashboard({super.key});

  @override
  State<CosmoGramDashboard> createState() => _CosmoGramDashboardState();
}

class _CosmoGramDashboardState extends State<CosmoGramDashboard> {
  int _currentNavigationIndex = 0;
  late Future<Map<String, dynamic>> _nasaApodData;
  final TextEditingController _birthdayController = TextEditingController();
  Map<String, dynamic>? _birthdayResult;
  bool _isLoadingBirthday = false;

  final String _nasaApiKey = "YOUR_API_KEY_GOES_HERE";

  @override
  void initState() {
    super.initState();
    _nasaApodData = fetchNasaApod();
  }

  // API Call 1
  Future<Map<String, dynamic>> fetchNasaApod() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.nasa.gov/planetary/apod?api_key=$_nasaApiKey"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to communicate with NASA Core";
      }
    } catch (e) {
      throw "Telemetry Error: Check connection profiles.";
    }
  }

  void _refreshDashboardData() {
    setState(() {
      _nasaApodData = fetchNasaApod();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronizing cosmic streams...'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Color(0xFF1D1F2A),
      ),
    );
  }

  // API Call 2
  Future<void> fetchCosmicBirthday(String dateString) async {
    setState(() {
      _isLoadingBirthday = true;
      _birthdayResult = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.nasa.gov/planetary/apod?api_key=$_nasaApiKey&date=$dateString",
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _birthdayResult = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "NASA has no telemetry archives for this specific date coordinate.",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection timeout during deep-space lookup."),
        ),
      );
    } finally {
      setState(() {
        _isLoadingBirthday = false;
      });
    }
  }

  Future<void> _downloadCosmicImage(String url, String title) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (url.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error: No target telemetry URL found.')),
      );
      return;
    }

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Downloading cosmic telemetry asset...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final http.Response response = await http.get(Uri.parse(url));
      final Directory temporaryDir = await getTemporaryDirectory();

      String safeTitle = title
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .trim()
          .replaceAll(' ', '_');
      if (safeTitle.isEmpty) safeTitle = "cosmic_snapshot";

      if (!safeTitle.toLowerCase().endsWith('.jpg') &&
          !safeTitle.toLowerCase().endsWith('.jpeg')) {
        safeTitle = "$safeTitle.jpg";
      }

      File fileCacheInstance = File('${temporaryDir.path}/$safeTitle');
      await fileCacheInstance.writeAsBytes(response.bodyBytes);

      final SaveFileDialogParams storageParams = SaveFileDialogParams(
        sourceFilePath: fileCacheInstance.path,
      );
      final String? finalPath = await FlutterFileDialog.saveFile(
        params: storageParams,
      );

      if (finalPath != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Telemetry asset saved successfully to device storage!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // print("CRITICAL DOWNLOAD EXCEPTION: $e");
      // print(stackTrace);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Download abort: ${e.toString().substring(0, math.min(60, e.toString().length))}...',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color spaceBackground = const Color(0xFF0C0E18);
    final Color glassSurface = const Color(0xFF1D1F2A).withOpacity(0.4);
    final Color neonPrimary = const Color(0xFFBBC7DA);
    final Color neonSecondary = const Color(0xFFDDB7FF);
    final Color supernovaOrange = const Color(0xFFFF4E16);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: spaceBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF11131D).withOpacity(0.4),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'CosmoGram',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFFBBC7DA),
            ),
          ),
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(Icons.rocket_launch, color: neonPrimary),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: neonPrimary),
              tooltip: 'Sync Telemetry',
              onPressed: _refreshDashboardData,
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentNavigationIndex,
          children: [
            _buildDiscoveryTab(glassSurface, neonSecondary, supernovaOrange),
            _buildBirthdayTab(glassSurface, neonSecondary, supernovaOrange),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentNavigationIndex,
            backgroundColor: const Color(0xFF1D1F2A).withOpacity(0.8),
            selectedItemColor: neonSecondary,
            unselectedItemColor: Colors.white38,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _currentNavigationIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discovery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cake),
                label: 'Birthday',
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Discover
  Widget _buildDiscoveryTab(Color glass, Color secondary, Color orange) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _nasaApodData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFDDB7FF)),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final apod = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Discovery',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE FROM NASA',
                        style: TextStyle(
                          color: orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: glass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            apod['url'] ??
                                'https://images.unsplash.com/photo-1464802686167-b939a6910659',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 250,
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: FloatingActionButton.small(
                            backgroundColor: orange,
                            onPressed: () => _downloadCosmicImage(
                              apod['url'] ?? '',
                              apod['title'] ?? 'cosmic_image',
                            ),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apod['date'] ?? 'CURRENT UTC COORDINATE',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            apod['title'] ?? 'The Pillars of Creation',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            apod['explanation'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Telemetry Vector Dashboard',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridWithTelemetry(glass: glass),
            ],
          ),
        );
      },
    );
  }

  // Birthday Lookup wala
  Widget _buildBirthdayTab(Color glass, Color secondary, Color orange) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'What did NASA see on your birthday?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Synchronize coordinates to query the cosmic database tier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _birthdayController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'ENTER DATE (YYYY-MM-DD)',
                    labelStyle: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                    hintText: '2004-10-24',
                    prefixIcon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white70,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _isLoadingBirthday
                        ? null
                        : () {
                            if (_birthdayController.text.isNotEmpty) {
                              fetchCosmicBirthday(
                                _birthdayController.text.trim(),
                              );
                            }
                          },
                    icon: _isLoadingBirthday
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text(
                      'ENGAGE LOOKUP VECTOR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_birthdayResult != null) ...[
            Container(
              decoration: BoxDecoration(
                color: glass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _birthdayResult!['url'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.white10,
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          backgroundColor: orange,
                          onPressed: () => _downloadCosmicImage(
                            _birthdayResult!['url'] ?? '',
                            _birthdayResult!['title'] ?? 'birthday_snapshot',
                          ),
                          child: const Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _birthdayResult!['title'] ?? 'Celestial Snapshot',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _birthdayResult!['explanation'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GridWithTelemetry extends StatelessWidget {
  final Color glass;
  const GridWithTelemetry({super.key, required this.glass});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _telemetryItem('DISTANCE', '6,500 LIGHT YEARS'),
        _telemetryItem('CONSTELLATION', 'SERPENS'),
        _telemetryItem('TELESCOPE', 'JWST NIRCAM'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'RADIATION MAP',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.64,
                        backgroundColor: Colors.white10,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '64%',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _telemetryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFBBC7DA),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}
