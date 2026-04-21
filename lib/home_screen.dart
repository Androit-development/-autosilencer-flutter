import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDetecting = false;
  String drivingStatus = 'Not Driving';
  Color statusColor = Colors.green;
  IconData statusIcon = Icons.directions_walk;
  double accelerometerValue = 0.0;
  StreamSubscription? accelerometerSubscription;

  // This number decides when we think the user is driving
  // If the phone moves more than this value, we say "driving!"
  final double drivingThreshold = 3.0;

  void startDetection() async {
    // First ask for permission to use sensors
    await Permission.sensors.request();

    setState(() {
      isDetecting = true;
      drivingStatus = 'Monitoring...';
      statusColor = Colors.orange;
      statusIcon = Icons.sensors;
    });

    // Start listening to the accelerometer
    accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      // Calculate total movement from all directions
      double totalMovement =
          (event.x.abs() + event.y.abs() + event.z.abs()) / 3;

      setState(() {
        accelerometerValue = totalMovement;

        if (totalMovement > drivingThreshold) {
          drivingStatus = 'Driving Detected! 🚗';
          statusColor = Colors.red;
          statusIcon = Icons.directions_car;
        } else {
          drivingStatus = 'Not Driving';
          statusColor = Colors.green;
          statusIcon = Icons.directions_walk;
        }
      });
    });
  }

  void stopDetection() {
    accelerometerSubscription?.cancel();
    setState(() {
      isDetecting = false;
      drivingStatus = 'Not Driving';
      statusColor = Colors.green;
      statusIcon = Icons.directions_walk;
      accelerometerValue = 0.0;
    });
  }

  void toggleDetection() {
    if (isDetecting) {
      stopDetection();
    } else {
      startDetection();
    }
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        title: const Text(
          'Auto Silencer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D1E33), Color(0xFF0A0E21)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, size: 60, color: statusColor),
                    const SizedBox(height: 16),
                    Text(
                      drivingStatus,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Movement: ${accelerometerValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: toggleDetection,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDetecting
                          ? [Colors.red.shade700, Colors.red.shade400]
                          : [Colors.blue.shade700, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDetecting
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDetecting ? Icons.stop : Icons.play_arrow,
                        size: 60,
                        color: Colors.white,
                      ),
                      Text(
                        isDetecting ? 'STOP' : 'START',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.volume_off, color: Colors.blue, size: 30),
                          SizedBox(height: 8),
                          Text(
                            'Silent Mode',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            'Auto',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.speed, color: Colors.blue, size: 30),
                          const SizedBox(height: 8),
                          const Text(
                            'Movement',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            accelerometerValue.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.shield, color: Colors.blue, size: 30),
                          SizedBox(height: 8),
                          Text(
                            'Protection',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
