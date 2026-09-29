import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif', // Utilisez une police propre comme Inter ou Poppins si disponible
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      ),
      home: const LoanScreen(),
    );
  }
}

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  int _currentIndex = 1; // Onglet "Trésorerie" actif

  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte graphique de l'image
    const primaryColor = Color(0xFF1E5E4E); // Vert foncé
    const cardColor = Color(0xFF3B846F); // Vert moyen pour la carte de prêt
    const lightGreenBg = Color(0xFFE8F3EF); // Vert très clair pour les boutons/échéance
    const alertBg = Color(0xFFE6F2E8); // Vert pâle pour l'alerte d'information
    const textColor = Color(0xFF1C2D27);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {},
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Famille Bamiléké',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Cycle 8/12',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor,
              radius: 18,
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // --- Onglets de navigation supérieurs (Segmented Control) ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTopTab("Ma Trésorerie", false),
                  _buildTopTab("Contributions", false),
                  _buildTopTab("Prêts", true), // Actif
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Carte Principale "Mon prêt" ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
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
                          const Text(
                            'Mon prêt',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'En cours',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Montant emprunté',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '250 000 FCFA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Bar de Remboursement
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remboursement',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        '60%',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CE497)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Total Remboursé vs Solde Restant
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total remboursé',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '150 000 FCFA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Solde restant',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '100 000 FCFA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Encadré Prochaine Échéance ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: primaryColor, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prochaine échéance',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '12 Nov. 2023',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '50 000 FCFA',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- Encadré Info / Alerte ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: alertBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: primaryColor.withOpacity(0.8), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Vous devez rembourser votre prêt actuel avant d\'en demander un nouveau.',
                      style: TextStyle(
                        color: Color(0xFF4A6B5D),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- En-tête Historique ---
            Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique des\nremboursements',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Tout voir',
                    style: TextStyle(
                      color: Color(0xFF2E8A6E),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Liste des Remboursements ---
            _buildHistoryItem('Marie L.', '12 Oct. 2023', '50 000 FCFA', true),
            _buildHistoryItem('Marie L.', '12 Oct. 2023', '50 000 FCFA', true),
            _buildHistoryItem('Marie L.', '12 Oct. 2023', '50 000 FCFA', true),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history, color: primaryColor),
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
      ),
    );
  }

  // Widget d'onglet supérieur dynamique
  Widget _buildTopTab(String title, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E5E4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
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

  // Widget élément d'historique
  Widget _buildHistoryItem(String name, String date, String amount, bool isUpToDate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE2EBE8),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1C2D27),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E5E4E),
                ),
              ),
              const SizedBox(height: 4),
              if (isUpToDate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'À jour',
                    style: TextStyle(
                      color: Color(0xFF2E8A6E),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}