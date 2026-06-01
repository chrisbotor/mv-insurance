import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  
  // The RBAC State Variable
  String _currentUserRole = 'Tier 1 Assessor'; 

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Dynamically filter available views based on the role
    final List<Widget> availableViews = [];
    final List<NavigationRailDestination> desktopNavItems = [];
    final List<BottomNavigationBarItem> mobileNavItems = [];

    // 1. BASE LEVEL: Everyone gets the Dashboard and Policies
    availableViews.addAll([const DashboardView(), const PoliciesView()]);
    
    desktopNavItems.addAll([
      const NavigationRailDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: Text('Dashboard')),
      const NavigationRailDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield_rounded), label: Text('Policies CRM')),
    ]);
    
    mobileNavItems.addAll([
      const BottomNavigationBarItem(icon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Policies'),
    ]);

    // 2. TIER 1 + SUPER ADMIN: Add the Claims Kanban Pipeline
    if (_currentUserRole == 'Tier 1 Assessor' || _currentUserRole == 'Super Admin') {
      availableViews.add(const ClaimsView()); 
      desktopNavItems.add(const NavigationRailDestination(icon: Icon(Icons.car_crash_outlined), selectedIcon: Icon(Icons.car_crash_rounded), label: Text('Claims Review')));
      mobileNavItems.add(const BottomNavigationBarItem(icon: Icon(Icons.car_crash_rounded), label: 'Claims'));
    }

    // 3. SUPER ADMIN ONLY: Add System Settings and Staff Management
    if (_currentUserRole == 'Super Admin') {
      availableViews.add(const SystemSettingsView()); 
      desktopNavItems.add(const NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: Text('System Settings')));
      mobileNavItems.add(const BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'));
    }

    // Safety catch: if switching roles makes the index out of bounds, reset to 0
    if (_selectedIndex >= availableViews.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('BrightPath Admin', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentUserRole,
                icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                items: <String>['Super Admin', 'Tier 1 Assessor', 'Tier 2 Support Agent'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) => setState(() => _currentUserRole = newValue!),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: mobileNavItems,
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.white,
                  extended: true,
                  minExtendedWidth: 200,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
                  selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
                  selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  destinations: desktopNavItems,
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)),
                Expanded(child: availableViews[_selectedIndex]),
              ],
            )
          : SafeArea(child: availableViews[_selectedIndex]), 
    );
  }
}

// --- 1. DASHBOARD VIEW ---
class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview', 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5,
            )
          ),
          const SizedBox(height: 24),
          
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildProStatCard('Active Policies', '142', Icons.verified_user_rounded, Colors.green)),
                const SizedBox(width: 20),
                Expanded(child: _buildProStatCard('Pending Claims', '8', Icons.warning_rounded, Colors.orange)),
                const SizedBox(width: 20),
                Expanded(child: _buildProStatCard('Revenue (MTD)', '₱ 45,000', Icons.payments_rounded, Colors.blue)),
              ],
            )
          else
            Column(
              children: [
                _buildProStatCard('Active Policies', '142', Icons.verified_user_rounded, Colors.green),
                const SizedBox(height: 16),
                _buildProStatCard('Pending Claims', '8', Icons.warning_rounded, Colors.orange),
                const SizedBox(height: 16),
                _buildProStatCard('Revenue (MTD)', '₱ 45,000', Icons.payments_rounded, Colors.blue),
              ],
            ),
            
          const SizedBox(height: 24),

          _buildCardContainer(
            title: '6-Month Revenue Trend',
            child: SizedBox(height: 250, child: _buildRevenueChart()),
          ),

          const SizedBox(height: 24),

          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildCardContainer(title: 'Live Activity Feed', child: _buildActivityFeed())),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildCardContainer(title: 'Claim Hotspots', child: _buildHotspots())),
              ],
            )
          else
            Column(
              children: [
                _buildCardContainer(title: 'Live Activity Feed', child: _buildActivityFeed()),
                const SizedBox(height: 24),
                _buildCardContainer(title: 'Claim Hotspots', child: _buildHotspots()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildProStatCard(String title, String value, IconData icon, MaterialColor baseColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: baseColor.shade50, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 28, color: baseColor.shade600),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10000),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(months[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 5, minY: 0, maxY: 50000,
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 20000), FlSpot(1, 25000), FlSpot(2, 22000), FlSpot(3, 38000), FlSpot(4, 35000), FlSpot(5, 45000)],
            isCurved: true, color: Colors.blueAccent, barWidth: 4, isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    final events = [
      {'title': 'New FNOL submitted', 'subtitle': '2022 Toyota Raize (Non-Turbo)', 'time': '2 mins ago', 'icon': Icons.directions_car, 'color': Colors.blue},
      {'title': 'YOLO Damage Model flag', 'subtitle': 'Claim #4092 routed to manual review', 'time': '14 mins ago', 'icon': Icons.smart_toy, 'color': Colors.purple},
      {'title': 'Policy payment received', 'subtitle': 'Ref: TXN-88291 (₱ 12,500)', 'time': '1 hr ago', 'icon': Icons.payments, 'color': Colors.green},
      {'title': 'Claim Approved', 'subtitle': 'Claim #4088 (Rear Bumper replacement)', 'time': '3 hrs ago', 'icon': Icons.check_circle, 'color': Colors.teal},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => const Divider(height: 30),
      itemBuilder: (context, index) {
        final event = events[index];
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: (event['color'] as MaterialColor).shade50,
              child: Icon(event['icon'] as IconData, color: (event['color'] as MaterialColor).shade600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(event['subtitle'] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Text(event['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        );
      },
    );
  }

  Widget _buildHotspots() {
    final regions = [
      {'name': 'Pasig', 'count': 42, 'percent': 0.8},
      {'name': 'Marikina', 'count': 38, 'percent': 0.7},
      {'name': 'Cainta', 'count': 15, 'percent': 0.3},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: regions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final region = regions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(region['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${region['count']} active', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: region['percent'] as double,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blueAccent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }
}

// --- 2. POLICIES CRM VIEW ---
class PoliciesView extends StatelessWidget {
  const PoliciesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final policies = [
      {'id': 'POL-0091', 'name': 'Christian Botor', 'vehicle': '2022 Toyota Raize (Non-Turbo)', 'status': 'Active', 'premium': '₱ 18,500/yr'},
      {'id': 'POL-0092', 'name': 'Racquel Botor', 'vehicle': '2021 Honda City', 'status': 'Active', 'premium': '₱ 15,200/yr'},
      {'id': 'POL-0084', 'name': 'Mark Santos', 'vehicle': '2019 Ford Ranger', 'status': 'Pending Renewal', 'premium': '₱ 22,000/yr'},
      {'id': 'POL-0071', 'name': 'Sarah Lim', 'vehicle': '2023 Mitsubishi Xpander', 'status': 'Active', 'premium': '₱ 19,800/yr'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Policy Management', 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5,
            )
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search by Policy ID, Name, or Vehicle...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: policies.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final policy = policies[index];
                final isActive = policy['status'] == 'Active';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Icon(Icons.directions_car, color: isActive ? Colors.green : Colors.orange),
                  ),
                  title: Text(policy['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${policy['id']} • ${policy['vehicle']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(policy['premium']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(policy['status']!, style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. AI CLAIMS KANBAN VIEW ---
class ClaimsView extends StatelessWidget {
  const ClaimsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Claims Pipeline (AI Assisted)', 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5,
            )
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: isDesktop ? Axis.horizontal : Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildKanbanColumns(isDesktop: true),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildKanbanColumns(isDesktop: false),
                ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildKanbanColumns({required bool isDesktop}) {
    return [
      _buildKanbanColumn('New FNOL', [
        _buildClaimCard('CLM-882', '2021 Honda City', 'Front Bumper Damage', 'Awaiting Images'),
      ], isDesktop),
      _buildKanbanColumn('AI Processing (YOLO)', [
        _buildClaimCard('CLM-881', '2023 Mitsubishi Xpander', 'Analyzing structural damage...', 'Processing', isProcessing: true),
      ], isDesktop),
      _buildKanbanColumn('Manual Review', [
        _buildClaimCard('CLM-879', '2019 Ford Ranger', 'AI Confidence: 62% (Low)', 'Requires Assessor', isWarning: true),
      ], isDesktop),
      _buildKanbanColumn('Approved', [
        _buildClaimCard('CLM-875', '2022 Toyota Raize', 'Rear Panel Scrape (Conf: 94%)', 'Ready for Payout', isSuccess: true),
      ], isDesktop),
    ];
  }

  Widget _buildKanbanColumn(String title, List<Widget> cards, bool isDesktop) {
    return Container(
      width: isDesktop ? 320 : double.infinity,
      margin: EdgeInsets.only(
        left: isDesktop ? 8 : 0, 
        right: isDesktop ? 8 : 0, 
        bottom: isDesktop ? 0 : 24
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          ),
          ...cards,
        ],
      ),
    );
  }

  Widget _buildClaimCard(String id, String vehicle, String description, String status, {bool isProcessing = false, bool isWarning = false, bool isSuccess = false}) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending_actions;
    
    if (isProcessing) { statusColor = Colors.blue; statusIcon = Icons.memory; }
    if (isWarning) { statusColor = Colors.orange; statusIcon = Icons.warning_amber; }
    if (isSuccess) { statusColor = Colors.green; statusIcon = Icons.check_circle_outline; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Icon(statusIcon, size: 18, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(vehicle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- 4. SUPER ADMIN SYSTEM SETTINGS VIEW ---
class SystemSettingsView extends StatelessWidget {
  const SystemSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health & Staff Management', 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), letterSpacing: -0.5,
            )
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Staff Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStaffRow('Sarah Jen', 'Tier 1 Assessor', 'Active'),
                const Divider(),
                _buildStaffRow('Mike Row', 'Tier 2 Support Agent', 'Active'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStaffRow(String name, String role, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0),
            child: const Text('Revoke Access'),
          )
        ],
      ),
    );
  }
}