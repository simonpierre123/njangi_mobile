import 'package:flutter/material.dart';

void main() {
  runApp(const TontineApp());
}

class TontineApp extends StatelessWidget {
  const TontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E5E4E),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        fontFamily: 'sans-serif',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1E5E4E),
              child: Icon(Icons.hub_outlined, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Famille Bamiléké", 
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Cycle 8/12", 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHealthCard(),
            const SizedBox(height: 25),
            _buildSectionTitle("Actions requises"),
            const SizedBox(height: 10),
            _buildActionItem(
              icon: Icons.account_balance_wallet_outlined,
              title: "Cotisation due",
              subtitle: "50 000 FCFA • Aujourd'hui",
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5E4E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Payer", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            _buildActionItem(
              icon: Icons.calendar_today_outlined,
              title: "Réunion de groupe",
              subtitle: "Demain à 18h00",
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 25),
            _buildSectionTitle("Actions rapides"),
            const SizedBox(height: 10),
            _buildQuickActionsGrid(),
            const SizedBox(height: 25),
            _buildCycleCard(),
            const SizedBox(height: 25),
            _buildMembersSummary(),
            const SizedBox(height: 25),
            _buildSectionTitle("Activité récente"),
            const SizedBox(height: 10),
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS DE SECTIONS ---

  Widget _buildHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B846F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHealthStat("SANTÉ DU GROUPE", "94%", isBadge: true),
              _buildHealthStat("Caisse actuelle", "2 450 000 FCFA", isLarge: true),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat("Membres à jour", "12/15"),
              _buildSmallStat("En attente", "3"),
              _buildSmallStat("Prêts actifs", "2"),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Mis à jour il y a 5 min", 
            style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, {bool isBadge = false, bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(value, style: TextStyle(
              color: Colors.white, 
              fontSize: isLarge ? 20 : 28, 
              fontWeight: FontWeight.bold)),
            if (isBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Stable", style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionItem({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE6F7F2),
            child: Icon(icon, color: const Color(0xFF1E5E4E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _buildQuickActionBtn(Icons.receipt_long, "Mes Cotisations"),
        _buildQuickActionBtn(Icons.account_balance, "Demander un prêt"),
        _buildQuickActionBtn(Icons.people_outline, "Membres"),
        _buildQuickActionBtn(Icons.insert_chart_outlined, "Rapports"),
      ],
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1F5EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1E5E4E), size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF1E5E4E), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCycleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Cycle en cours", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text("60%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E5E4E))),
              const Spacer(),
              const Text("Complété", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.green.withOpacity(0.1),
            color: const Color(0xFF1E5E4E),
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.person_outline, size: 16, color: Colors.grey),
              SizedBox(width: 5),
              Text("Prochain bénéficiaire: ", style: TextStyle(fontSize: 12)),
              Text("Jean D.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const Text("4 cycles restants dans cette période", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMembersSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Membres", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("15", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          _buildMemberRow("À jour", "12", Colors.green.withOpacity(0.1), Colors.green),
          _buildMemberRow("En attente", "3", Colors.orange.withOpacity(0.1), Colors.orange),
          _buildMemberRow("En retard", "1", Colors.red.withOpacity(0.1), Colors.red),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1F5EA)),
                backgroundColor: const Color(0xFFE6F7F2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Voir tous les membres", style: TextStyle(color: Color(0xFF1E5E4E))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemberRow(String label, String count, Color bg, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: text, fontSize: 12)),
            Text(count, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _buildActivityItem(Icons.person_add_alt, "Marie a cotisé 50 000 FCFA", "Il y a 2h", const Color(0xFFE6F7F2)),
        _buildActivityItem(Icons.groups_outlined, "Réunion planifiée", "Il y a 5h", Colors.orange.withOpacity(0.1)),
        _buildActivityItem(Icons.check_circle_outline, "Prêt approuvé pour Alex", "Hier", Colors.purple.withOpacity(0.1)),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 18, child: Icon(icon, size: 18, color: Colors.black54)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A34)));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E5E4E),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD1F5EA), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.grid_view_rounded),
          ),
          label: 'Tableau de Bord',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trésorerie'),
        const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Membres'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    );
  }
}