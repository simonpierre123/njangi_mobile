import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5E4E);
    const cardGreenBg = Color(0xFF3B846F);
    const textDark = Color(0xFF1C2D27);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Famille Bamiléké", style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("ADMIN • Cycle 8/12", style: TextStyle(color: Colors.grey, fontSize: 11)),
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
            // Santé du Groupe
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardGreenBg, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SANTÉ DU GROUPE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text("94%", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Stable", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Priorités de gestion", style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Priorités de gestion
            Container(
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  _buildPriorityItem(Icons.payment, "3 cotisations à enregistrer", false),
                  const Divider(height: 1),
                  _buildPriorityItem(Icons.warning_amber_rounded, "1 membre en retard", true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPriorityItem(IconData icon, String text, bool isAlert) {
    final color = isAlert ? const Color(0xFFE55C5C) : const Color(0xFF1E5E4E);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}