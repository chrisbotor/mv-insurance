import 'package:flutter/material.dart';

// --- SUPER ADMIN DASHBOARD ---
class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PortalLayout(
      roleName: 'Super Admin',
      roleTitle: 'System Administration',
      themeColor: Colors.redAccent,
      allowedFeatures: const [
        _FeatureCard(icon: Icons.people, title: 'Manage Users', desc: 'Add, edit, or revoke portal accounts.'),
        _FeatureCard(icon: Icons.analytics, title: 'System Audits', desc: 'Review cluster logs and global activity.'),
        _FeatureCard(icon: Icons.settings, title: 'Global Configurations', desc: 'Modify system variables and API parameters.'),
        _FeatureCard(icon: Icons.security, title: 'Access Control', desc: 'Update system role matrices.'),
      ],
    );
  }
}

// --- TIER 1 ASSESSOR DASHBOARD ---
class Tier1Dashboard extends StatelessWidget {
  const Tier1Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PortalLayout(
      roleName: 'Tier 1 Assessor',
      roleTitle: 'Claims Assessment Pipeline',
      themeColor: Colors.blueAccent,
      allowedFeatures: const [
        _FeatureCard(icon: Icons.assignment, title: 'New Claims Intake', desc: 'Process fresh motor vehicle policy applications.'),
        _FeatureCard(icon: Icons.directions_car, title: 'Damage Inspection', desc: 'Review automated computer-vision damage models.'),
        _FeatureCard(icon: Icons.camera_alt, title: 'Photo Verification', desc: 'Assess accident photography uploads.'),
      ],
    );
  }
}

// --- TIER 2 SUPPORT DASHBOARD ---
class Tier2Dashboard extends StatelessWidget {
  const Tier2Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PortalLayout(
      roleName: 'Tier 2 Support',
      roleTitle: 'Escalations & Support',
      themeColor: Colors.orangeAccent,
      allowedFeatures: const [
        _FeatureCard(icon: Icons.rule, title: 'Escalated Evaluations', desc: 'Investigate high-complexity claim structural issues.'),
        _FeatureCard(icon: Icons.contact_support, title: 'Assessor Assistance', desc: 'Provide secondary evaluations on complex damage accounts.'),
        _FeatureCard(icon: Icons.history, title: 'Historical Audits', desc: 'Cross-reference old documentation for precedent.'),
      ],
    );
  }
}

// =========================================================================
//                   RESPONSIVE MASTER LAYOUT WRAPPER
// =========================================================================

class PortalLayout extends StatelessWidget {
  final String roleName;
  final String roleTitle;
  final Color themeColor;
  final List<Widget> allowedFeatures;

  const PortalLayout({
    Key? key,
    required this.roleName,
    required this.roleTitle,
    required this.themeColor,
    required this.allowedFeatures,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine screen size threshold (850px is a standard tablet/desktop breakpoint)
    final bool isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      // On mobile/tablet, show a top bar with a hamburger icon to open the drawer
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0F172A),
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(roleName, style: const TextStyle(color: Colors.white, fontSize: 16)),
              elevation: 0,
            ),
      // On mobile/tablet, the sidebar becomes a slide-out drawer
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
      body: Row(
        children: [
          // On desktop, the sidebar is permanently visible on the left
          if (isDesktop) _buildSidebar(context),
          
          // The main content takes up the rest of the space
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  // --- INTERNAL BUILDERS ---

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF0F172A),
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
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive Grid Logic: 3 cols for desktop, 2 for tablet, 1 for phone
    int crossAxisCount = 3;
    if (screenWidth < 650) {
      crossAxisCount = 1;
    } else if (screenWidth < 1100) {
      crossAxisCount = 2;
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(roleTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Authorized operational views active.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              // Adjust aspect ratio so cards don't look overly stretched on phones
              childAspectRatio: screenWidth < 650 ? 2.5 : 1.5,
              children: allowedFeatures,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
//                             MICRO WIDGETS
// =========================================================================

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF334155)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Expanded(child: Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}