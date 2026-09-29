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
      home: const LoansNoActiveScreen(),
    );
  }
}

class LoansNoActiveScreen extends StatefulWidget {
  const LoansNoActiveScreen({super.key});

  @override
  State<LoansNoActiveScreen> createState() => _LoansNoActiveScreenState();
}

class _LoansNoActiveScreenState extends State<LoansNoActiveScreen> {
  int _currentBottomNavIndex = 1; // Onglet "Trésorerie" actif par défaut

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs de la maquette
    const primaryGreen = Color(0xFF1E5E4E);
    const lightGreenBg = Color(0xFFE8F3EF);
    const textDark = Color(0xFF1C2D27);
    const lightGreyBorder = Color(0xFFE2EBE8);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Famille Bamiléké",
                  style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Cycle 8/12",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 1. Navigation Onglets supérieurs (Ma Trésorerie, Contributions, Prêts)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2EE),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildSubTab("Ma Trésorerie", false),
                  _buildSubTab("Contributions", false),
                  _buildSubTab("Prêts", true), // Actif
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Carte : Aucun prêt en cours
            _buildNoLoanCard(primaryGreen, textDark, lightGreyBorder),
            const SizedBox(height: 16),

            // 3. Carte : Votre éligibilité
            _buildEligibilityCard(textDark),
            const SizedBox(height: 16),

            // 4. Bouton d'action : Demander un prêt
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text(
                  "Demander un prêt",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5. Carte informative : Comment fonctionne un prêt ?
            _buildHowItWorksCard(primaryGreen, textDark),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(primaryGreen, lightGreenBg),
    );
  }

  // --- WIDGETS INTERNES ---

  // Onglet supérieur
  Widget _buildSubTab(String text, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E5E4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF1E5E4E),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Carte "Aucun prêt en cours"
  Widget _buildNoLoanCard(Color primaryGreen, Color textDark, Color borderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEBFDF5),
            child: Icon(Icons.account_balance_wallet_outlined, color: primaryGreen, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucun prêt en cours",
            style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Vous n'avez actuellement aucun prêt en cours auprès de votre communauté.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEBFDF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Éligible à une demande",
              style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Vous pouvez effectuer une nouvelle demande de prêt selon les règles de votre communauté.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }

  // Carte "Votre éligibilité"
  Widget _buildEligibilityCard(Color textDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECE9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Votre éligibilité",
            style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Plafond disponible", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      "500 000 FCFA",
                      style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ancienneté", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      "8 mois",
                      style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white70),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF2CE497), size: 18),
              SizedBox(width: 8),
              Text(
                "Historique de remboursement exemplaire",
style: TextStyle(
  color: Color(0xCC000000), // Noir avec environ 80 % d'opacité
  fontSize: 11,
  fontWeight: FontWeight.w500,
),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Carte "Comment fonctionne un prêt ?"
  Widget _buildHowItWorksCard(Color primaryGreen, Color textDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2EBE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comment fonctionne un prêt ?",
            style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStepRow(1, "Envoyer une demande", "Remplissez le formulaire avec le montant et la durée souhaités.", primaryGreen, textDark),
          const SizedBox(height: 16),
          _buildStepRow(2, "Validation", "Votre demande est examinée par les administrateurs de cycle.", primaryGreen, textDark),
          const SizedBox(height: 16),
          _buildStepRow(3, "Versement", "Une fois approuvée, les fonds sont versés sur votre compte.", primaryGreen, textDark),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String title, String description, Color primaryGreen, Color textDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: primaryGreen,
          child: Text(
            number.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 11, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Barre de navigation inférieure
  Widget _buildBottomNav(Color primaryColor, Color activeBg) {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        setState(() {
          _currentBottomNavIndex = index;
        });
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Tableau de Bord',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _currentBottomNavIndex == 1 ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history),
          ),
          label: 'Trésorerie',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Membres',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}