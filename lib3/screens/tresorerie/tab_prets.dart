import 'package:flutter/material.dart';

class TabPrets extends StatefulWidget {
  const TabPrets({super.key});

  @override
  State<TabPrets> createState() => _TabPretsState();
}

class _TabPretsState extends State<TabPrets> {
  bool _hasActiveLoan = false; 

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5E4E);
    const cardGreenBg = Color(0xFF3B846F);
    const textDark = Color(0xFF1C2D27);

    return Column(
      children: [
        // Commutateur de test pour votre mode démo
        Container(
          color: Colors.orange.withOpacity(0.1),
          child: SwitchListTile(
            title: const Text("Mode démo: Prêt actif", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            value: _hasActiveLoan,
            activeColor: primaryGreen,
            onChanged: (val) {
              setState(() {
                _hasActiveLoan = val;
              });
            },
          ),
        ),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _hasActiveLoan 
              ? _buildActiveLoanLayout(cardGreenBg, textDark, primaryGreen) 
              : _buildNoLoanLayout(primaryGreen, textDark),               
          ),
        ),
      ],
    );
  }

  // --- RENDU 1 : PRÊT EN COURS (Maquette 3) ---
  Widget _buildActiveLoanLayout(Color cardBg, Color textDark, Color primaryGreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte principale du prêt
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mon prêt", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E5E4E).withOpacity(0.4), 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("En cours", style: TextStyle(color: Color(0xFF2CE497), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text("Montant emprunté", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      SizedBox(height: 2),
                      Text("250 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Remboursement", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text("60%", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: 0.6, 
                  minHeight: 6,
                  backgroundColor: Colors.white24, 
                  valueColor: AlwaysStoppedAnimation(Color(0xFF2CE497)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total remboursé", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      SizedBox(height: 4),
                      Text("150 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Solde restant", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      SizedBox(height: 4),
                      Text("100 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Prochaine Échéance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE5ECE8), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD2DFD9)),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_month, color: Color(0xFF1E5E4E)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Prochaine échéance", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    SizedBox(height: 2),
                    Text("12 Nov. 2023", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C2D27))),
                  ],
                ),
              ),
              Text("50 000 FCFA", style: TextStyle(color: Color(0xFF1E5E4E), fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Bannière d'info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFEBFDF5), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryGreen, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Vous devez rembourser votre prêt actuel avant d'en demander un nouveau.", 
                  style: TextStyle(fontSize: 11, color: Color(0xFF1E5E4E)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section historique des remboursements (Maquette 3)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              "Historique des\nremboursements", 
              style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold, height: 1.2),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Tout voir", style: TextStyle(color: Color(0xFF3B846F), fontWeight: FontWeight.bold, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 12),
        _buildRefundItem("Marie L.", "12 Oct. 2023", "50 000 FCFA"),
        _buildRefundItem("Marie L.", "12 Oct. 2023", "50 000 FCFA"),
        _buildRefundItem("Marie L.", "12 Oct. 2023", "50 000 FCFA"),
      ],
    );
  }

  // --- RENDU 2 : AUCUN PRÊT EN COURS (Maquette 4) ---
  Widget _buildNoLoanLayout(Color primaryGreen, Color textDark) {
    return Column(
      children: [
        // Bloc Aucun Prêt
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2EBE8)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEBFDF5),
                child: Icon(Icons.account_balance_wallet_outlined, color: primaryGreen, size: 26),
              ),
              const SizedBox(height: 16),
              const Text("Aucun prêt en cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1C2D27))),
              const SizedBox(height: 8),
              const Text(
                "Vous n'avez actuellement aucun prêt en cours auprès de votre communauté.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF2CE497).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text("Éligible à une demande", style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Vous pouvez effectuer une nouvelle demande de prêt selon les règles de votre communauté.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Bloc Éligibilité
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE5ECE8).withOpacity(0.5), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD2DFD9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Votre éligibilité", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Plafond disponible", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("500 000 FCFA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1C2D27))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ancienneté", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("8 mois", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1C2D27))),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFD2DFD9)),
              Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF3B846F), size: 16),
                  SizedBox(width: 8),
                  Text("Historique de remboursement exemplaire", style: TextStyle(fontSize: 11, color: Color(0xFF3B846F))),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Bouton de Demande
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
            label: const Text("Demander un prêt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),

        // --- BLOC COMMENT ÇA FONCTIONNE ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF1EB).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Comment fonctionne un prêt ?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27)),
              ),
              const SizedBox(height: 16),
              _buildStepRow("1", "Envoyer une demande", "Remplissez le formulaire avec le montant et la durée souhaités."),
              const SizedBox(height: 16),
              _buildStepRow("2", "Validation", "Votre demande est examinée par les administrateurs de cycle."),
              const SizedBox(height: 16),
              _buildStepRow("3", "Versement", "Une fois approuvée, les fonds sont versés sur votre compte."),
            ],
          ),
        )
      ],
    );
  }

  // Helper pour l'historique des remboursements
  Widget _buildRefundItem(String name, String date, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEBF1EB),
            child: Icon(Icons.person_outline, color: Colors.grey, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E5E4E))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("À jour", style: TextStyle(color: Color(0xFF2E8A6E), fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  // Helper pour les étapes "Comment ça fonctionne"
  Widget _buildStepRow(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: const Color(0xFF1E5E4E),
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1C2D27))),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.3)),
            ],
          ),
        )
      ],
    );
  }
}