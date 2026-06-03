import 'package:flutter/material.dart';

class DamageAssessmentScreen extends StatefulWidget {
  const DamageAssessmentScreen({Key? key}) : super(key: key);

  @override
  _DamageAssessmentScreenState createState() => _DamageAssessmentScreenState();
}

class _DamageAssessmentScreenState extends State<DamageAssessmentScreen> {
  int _currentStep = 0; 
  // 0: Ready to capture, 1: Analyzing (Loading), 2: Results (YOLO Output)

  void _simulateAIAnalysis() async {
    setState(() => _currentStep = 1);

    // Simulate the network request to your FastAPI backend and YOLO inference time
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _currentStep = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('AI Damage Assessment'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vehicle Scan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Center the damaged area in the frame and capture.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Simulated Camera Viewfinder / AI Output Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Placeholder for the "Camera Feed"
                        Icon(
                          Icons.directions_car, 
                          size: 150, 
                          color: _currentStep == 2 ? Colors.white30 : Colors.white54
                        ),
                        
                        // Step 1: Scanning Overlay
                        if (_currentStep == 1) ...[
                          const CircularProgressIndicator(color: Colors.greenAccent),
                          const Positioned(
                            bottom: 40,
                            child: Text(
                              'Running YOLO Inference...',
                              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          )
                        ],

                        // Step 2: Mock Bounding Box Result
                        if (_currentStep == 2) ...[
                          Positioned(
                            top: 80,
                            left: 100,
                            child: Container(
                              width: 120,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.redAccent, width: 3),
                                color: Colors.redAccent.withOpacity(0.2),
                              ),
                              alignment: Alignment.topLeft,
                              child: Container(
                                color: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: const Text(
                                  'Front Dent 94%',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Dynamic Action Button based on state
                _buildBottomAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    if (_currentStep == 0) {
      return ElevatedButton.icon(
        onPressed: _simulateAIAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.camera),
        label: const Text('Capture & Analyze', style: TextStyle(fontSize: 18)),
      );
    } else if (_currentStep == 1) {
      return ElevatedButton(
        onPressed: null, // Disabled while loading
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Analyzing Image...', style: TextStyle(fontSize: 18)),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: const Column(
              children: [
                Text('AI Assessment Complete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Detected:'), Text('Severe Dent', style: TextStyle(color: Colors.redAccent))]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Estimated Repair Cost:'), Text('₱15,000 - ₱25,000', style: TextStyle(fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Return to dashboard and show success message
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Claim submitted successfully with AI report!'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Submit Claim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text('Retake Photo'),
          )
        ],
      );
    }
  }
}