import 'package:flutter/material.dart';

class TabContributions extends StatefulWidget {
  const TabContributions({super.key});

  @override
  State<TabContributions> createState() => _TabContributionsState();
}

class _TabContributionsState extends State<TabContributions> {
  String _activeFilter = "Tout";

  @override
  Widget build(BuildContext context) {
    const cardGreenBg = Color(0xFF3B846F);
    const textDark = Color(0xFF1C2D27);
    const primaryGreen = Color(0xFF1E5E4E);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte État de la collecte
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardGreenBg, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("État de la collecte", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        SizedBox(height: 6),
                        Text("650 000 XAF", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("/ 750 000 XAF", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    Text("60%", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                // Barre de progression multi-couleur fidèle à la maquette 2
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Expanded(flex: 60, child: Container(height: 8, color: const Color(0xFF2CE497))), // Payé
                      Expanded(flex: 25, child: Container(height: 8, color: const Color(0xFFFFB300))), // En attente
                      Expanded(flex: 15, child: Container(height: 8, color: Colors.white24)),         // Non commencé
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Membres à jour", style: TextStyle(color: Colors.white70, fontSize: 9)),
                        SizedBox(height: 2),
                        Text("9/15", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("En attente", style: TextStyle(color: Colors.white70, fontSize: 9)),
                        SizedBox(height: 2),
                        Text("6", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Prochaine échéance", style: TextStyle(color: Colors.white70, fontSize: 9)),
                        SizedBox(height: 2),
                        Text("12 Oct.", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Puces de filtres
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ["Tout", "À jour", "En attente", "En retard"].map((filter) {
                final isSel = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Text(filter, style: TextStyle(color: isSel ? Colors.white : primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    selected: isSel,
                    selectedColor: primaryGreen,
                    backgroundColor: const Color(0xFFEBFDF5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.transparent)),
                    onSelected: (_) => setState(() => _activeFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Membres et activités", style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text("Tout voir", style: TextStyle(color: cardGreenBg, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),

          // Liste des membres selon Maquette 2
          _buildMemberRow("Marie L.", "12 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
          _buildMemberRow("Jean D.", "11 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
          _buildMemberRow("Jean D.", "11 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
          _buildMemberRow("Alice M.", "En attente", "50 000 FCFA", "En attente", const Color(0xFFFFF9E6), const Color(0xFFB28900)),
        ],
      ),
    );
  }

  Widget _buildMemberRow(String name, String date, String amount, String status, Color bg, Color textCol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE2EBE8),
            child: Icon(Icons.person_outline, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27))),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }
}