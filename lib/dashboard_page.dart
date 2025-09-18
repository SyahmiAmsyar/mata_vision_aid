import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart'; // ⚡ For real battery info
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 👓 Spectacles icon
import 'profile_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  final Battery _battery = Battery();
  int _batteryLevel = 100; // default

  // Dummy history data
  final List<Map<String, String>> _history = [
    {"time": "11:30 AM", "event": "Location updated"},
    {"time": "09:15 AM", "event": "Device connected"},
    {"time": "08:45 AM", "event": "Battery charged to 85%"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));

    _updateBatteryLevel(); // Fetch battery on start

    // Listen to battery state changes and update level
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _updateBatteryLevel();
    });
  }

  Future<void> _updateBatteryLevel() async {
    final level = await _battery.batteryLevel;
    if (mounted) {
      setState(() => _batteryLevel = level);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0073B1),
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "👋 Welcome back, Syahmi!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Status & Battery Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusCard(
                  title: "Connection",
                  value: "CONNECTED",
                  color: Colors.green,
                  icon: FontAwesomeIcons.glasses, // 👓 Spectacles icon
                ),
                _buildStatusCard(
                  title: "Battery",
                  value: "$_batteryLevel%", // real-time
                  color: Colors.blue,
                  icon: Icons.battery_full,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live Location
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "LIVE LOCATION",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text("Map Placeholder"),
                          ),
                        ),
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: const Icon(
                            Icons.location_on,
                            size: 60,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("📍 Kuala Lumpur, Malaysia"),
                        Chip(
                          label: Text("LIVE"),
                          backgroundColor: Colors.redAccent,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // History Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "History",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Earlier Today",
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(
                            _history[index]["time"]!,
                            _history[index]["event"]!,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0073B1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("View Full History"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              FaIcon(icon, color: color, size: 28), // FontAwesome icon
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String time, String event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.history, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$time – $event"),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> fullHistory = [
      {"time": "11:30 AM", "event": "Location updated"},
      {"time": "09:15 AM", "event": "Device connected"},
      {"time": "08:45 AM", "event": "Battery charged to 85%"},
      {"time": "Yesterday", "event": "Device restarted"},
      {"time": "2 days ago", "event": "Low battery alert"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0073B1),
        title: const Text("Full History"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fullHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(fullHistory[index]["event"]!),
            subtitle: Text(fullHistory[index]["time"]!),
          );
        },
      ),
    );
  }
}
