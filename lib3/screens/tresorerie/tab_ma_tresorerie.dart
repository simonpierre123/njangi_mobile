import 'package:flutter/material.dart';

class TabMaTresorerie extends StatelessWidget {
  const TabMaTresorerie({super.key});

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
          // Carte Position Financière
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cardGreenBg, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("MA POSITION FINANCIÈRE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Text("100% Particip.", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.fiber_manual_record, color: Color(0xFF2CE497), size: 10),
                    SizedBox(width: 6),
                    Text("À jour", style: TextStyle(color: Color(0xFF2CE497), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total cotisé", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        SizedBox(height: 4),
                        Text("400 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Prêt en cours", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        SizedBox(height: 4),
                        Text("Aucun", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Prochaine échéance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EBE8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Prochaine échéance", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("12 Oct.", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Boîte d'action rapide : Cotisation d'Octobre (Maquette 1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryGreen.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Color(0xFFEBFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Color(0xFF2CE497), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Cotisation d'Octobre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                      SizedBox(height: 2),
                      Text("Échéance: 12 Oct.", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("50 000 FCFA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 12, color: primaryGreen),
                          SizedBox(width: 4),
                          Text("Voir le reçu", style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // En-tête Historique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Historique de mes cotisations", style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text("Tout voir", style: TextStyle(color: cardGreenBg, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),

          // Liste historique
          _buildContributionHistoryItem("Cycle 7/12", "12 Septembre 2023", "50 000 FCFA"),
          _buildContributionHistoryItem("Cycle 6/12", "12 Août 2023", "50 000 FCFA"),
          _buildContributionHistoryItem("Cycle 5/12", "12 Juillet 2023", "50 000 FCFA"),
        ],
      ),
    );
  }

  Widget _buildContributionHistoryItem(String title, String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Color(0xFF1E5E4E), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27))),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEBFDF5), borderRadius: BorderRadius.circular(8)),
                    child: const Text("Payé", style: TextStyle(color: Color(0xFF2CE497), fontSize: 8, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          )
        ],
      ),
    );
  }
}