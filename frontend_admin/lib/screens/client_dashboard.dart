import 'package:flutter/material.dart';
import 'package:frontend_admin/screens/login_screen.dart'; // Add this! (Adjust path if needed)

class ClientDashboard extends StatefulWidget {
  final String username;

  const ClientDashboard({Key? key, required this.username}) : super(key: key);

  @override
  _ClientDashboardState createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  // Placeholder data - we will fetch this from FastAPI later!
  final List<Map<String, dynamic>> _myPolicies = [
    {
      'vehicle': '2022 Toyota Raize',
      'plate': 'ABC-1234',
      'policy_num': 'POL-998822',
      'status': 'Active',
      'expiry': '2027-05-12',
    },
    {
      'vehicle': '2019 Honda Civic',
      'plate': 'XYZ-9876',
      'policy_num': 'POL-443311',
      'status': 'Expiring Soon',
      'expiry': '2026-07-01',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to Profile Settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Clear the entire navigation stack and push the Login Screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false, // This forces it to wipe all previous screens
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            const Text(
              'My Vehicles & Policies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            _buildPoliciesList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open the "File a Claim / Damage Detection" flow
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.camera_alt),
        label: const Text('File a Claim', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(title: 'Active Policies', value: '2'),
          _SummaryStat(title: 'Pending Claims', value: '0'),
          _SummaryStat(title: 'Messages', value: '1'),
        ],
      ),
    );
  }

  Widget _buildPoliciesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Let the SingleChildScrollView handle scrolling
      itemCount: _myPolicies.length,
      itemBuilder: (context, index) {
        final policy = _myPolicies[index];
        final isActive = policy['status'] == 'Active';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              child: Icon(
                Icons.directions_car, 
                color: isActive ? Colors.green : Colors.orange
              ),
            ),
            title: Text(policy['vehicle'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Plate: ${policy['plate']} | Policy: ${policy['policy_num']}'),
                const SizedBox(height: 4),
                Text('Expires: ${policy['expiry']}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            trailing: Chip(
              label: Text(policy['status'], style: const TextStyle(fontSize: 12)),
              backgroundColor: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              labelStyle: TextStyle(color: isActive ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              side: BorderSide.none,
            ),
            onTap: () {
              // TODO: Navigate to Policy Details Screen
            },
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }
}