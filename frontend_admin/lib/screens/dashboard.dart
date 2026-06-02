import 'package:flutter/material.dart';

class SuperAdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Super Admin Dashboard')));
}

class Tier1Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Tier 1 Assessor Dashboard')));
}

class Tier2Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Tier 2 Support Dashboard')));
}