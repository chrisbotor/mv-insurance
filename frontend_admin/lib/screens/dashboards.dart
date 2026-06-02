import 'package:flutter/material.dart';

// --- SUPER ADMIN DASHBOARD ---
class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, 'Super Admin', Colors.redAccent),
          Expanded(
            child: _buildMainContent(
              roleTitle: 'System Administration & Management',
              themeColor: Colors.redAccent,
              allowedFeatures: [
                _FeatureCard(icon: Icons.people, title: 'Manage Users', desc: 'Add, edit, or revoke portal accounts.'),
                _FeatureCard(icon: Icons.analytics, title: 'System Audits', desc: 'Review cluster logs and global activity.'),
                _FeatureCard(icon: Icons.settings, title: 'Global Configurations', desc: 'Modify system variables and API parameters.'),
                _FeatureCard(icon: Icons.security, title: 'Access Control', desc: 'Update system role matrices.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TIER 1 ASSESSOR DASHBOARD ---
class Tier1Dashboard extends StatelessWidget {
  const Tier1Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, 'Tier 1 Assessor', Colors.blueAccent),
          Expanded(
            child: _buildMainContent(
              roleTitle: 'Claims Assessment Pipeline',
              themeColor: Colors.blueAccent,
              allowedFeatures: [
                _FeatureCard(icon: Icons.assignment, title: 'New Claims Intake', desc: 'Process fresh motor vehicle policy applications.'),
                _FeatureCard(icon: Icons.directions_car, title: 'Damage Inspection', desc: 'Review automated computer-vision damage models.'),
                _FeatureCard(icon: Icons.camera_alt, title: 'Photo Verification', desc: 'Assess accident photography uploads.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TIER 2 SUPPORT DASHBOARD ---
class Tier2Dashboard extends StatelessWidget {
  const Tier2Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, 'Tier 2 Support', Colors.orangeAccent),
          Expanded(
            child: _buildMainContent(
              roleTitle: 'Escalations & Support Portal',
              themeColor: Colors.orangeAccent,
              allowedFeatures: [
                _FeatureCard(icon: Icons.rule, title: 'Escalated Evaluations', desc: 'Investigate high-complexity claim structural issues.'),
                _FeatureCard(icon: Icons.contact_support, title: 'Assessor Assistance', desc: 'Provide secondary evaluations on complex damage accounts.'),
                _FeatureCard(icon: Icons.history, title: 'Historical Audits', desc: 'Cross-reference old documentation for precedent.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
//                      REUSABLE CORE WIDGET COMPONENTS
// =========================================================================

Widget _buildSidebar(BuildContext context, String roleName, Color themeColor) {
  return Container(
    width: 260,
    color: const Color(0xFF0F172A), // Dark Slate Sidebar
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield, color: themeColor, size: 28),
            const SizedBox(width: 12),
            const Text(
              'BrightPath Portal',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: themeColor.withOpacity(0.5)),
          ),
          child: Text(
            roleName,
            style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        const SizedBox(height: 40),
        _SidebarLink(icon: Icons.dashboard, title: 'Overview', isActive: true, themeColor: themeColor),
        _SidebarLink(icon: Icons.folder, title: 'Data Records', isActive: false, themeColor: themeColor),
        _SidebarLink(icon: Icons.help_outline, title: 'Documentation', isActive: false, themeColor: themeColor),
        const Spacer(),
        const Divider(color: Colors.white24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.grey),
          title: const Text('Sign Out', style: TextStyle(color: Colors.grey)),
          onTap: () {
            // Push replacement logs them out cleanly back to the initial login frame
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ],
    ),
  );
}

Widget _buildMainContent({required String roleTitle, required Color themeColor, required List<Widget> allowedFeatures}) {
  return Container(
    color: const Color(0xFFF8FAFC), // Light slate surface grey
    padding: const EdgeInsets.all(40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roleTitle,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Text(
          'Authorized operational views active.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5,
            children: allowedFeatures,
          ),
        ),
      ],
    ),
  );
}

class _SidebarLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final Color themeColor;

  const _SidebarLink({required this.icon, required this.title, required this.isActive, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? themeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: isActive ? themeColor : Colors.grey.shade400),
          title: Text(
            title,
            style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade400, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: const Color(0xFF334155)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}