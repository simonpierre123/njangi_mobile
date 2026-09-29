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
      home: const ContributionsScreen(),
    );
  }
}

class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  int _currentBottomNavIndex = 1; // Onglet "Trésorerie" actif
  String _activeFilter = "Tout"; // Filtre par défaut sélectionné

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs de la maquette
    const primaryGreen = Color(0xFF1E5E4E);
    const cardGreenBg = Color(0xFF3B846F);
    const lightGreenBg = Color(0xFFE8F3EF);
    const textDark = Color(0xFF1C2D27);

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

            // 1. Navigation Onglets (Ma Trésorerie, Contributions, Prêts)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2EE),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildSubTab("Ma Trésorerie", false),
                  _buildSubTab("Contributions", true), // Actif
                  _buildSubTab("Prêts", false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Carte Verte : État de la collecte
            _buildCollectStatusCard(cardGreenBg),
            const SizedBox(height: 20),

            // 3. Boutons Filtres horizontaux (Tout, À jour, En attente, En retard)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip("Tout"),
                  _buildFilterChip("À jour"),
                  _buildFilterChip("En attente"),
                  _buildFilterChip("En retard"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Section : Membres et activités
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Membres et activités",
                  style: TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Tout voir",
                    style: TextStyle(
                      color: Color(0xFF2E8A6E),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),

            // 5. Liste des Membres et Activités
            _buildActivityItem("Marie L.", "12 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
            _buildActivityItem("Jean D.", "11 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
            _buildActivityItem("Jean D.", "11 Oct. 2023", "50 000 FCFA", "À jour", const Color(0xFFE6F5EE), const Color(0xFF2E8A6E)),
            _buildActivityItem("Alice M.", "En attente", "50 000 FCFA", "En attente", const Color(0xFFFFF9E6), const Color(0xFFB28900)),
            const SizedBox(height: 20),
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

  // Carte d'état de la collecte (Verte)
  Widget _buildCollectStatusCard(Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
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
                children: const [
                  Text(
                    "État de la collecte",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "650 000 XAF",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "/ 750 000 XAF",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Text(
                "60%",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Barre de progression bicolore (Vert d'un côté, orange de l'autre pour illustrer l'attente)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Container(height: 8, color: const Color(0xFF2CE497)),
                ),
                Expanded(
                  flex: 25,
                  child: Container(height: 8, color: const Color(0xFFFFB300)),
                ),
                Expanded(
                  flex: 15,
                  child: Container(height: 8, color: Colors.white24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStatItem("Membres à jour", "9/15"),
              _buildCardStatItem("En attente", "6"),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Prochaine échéance",
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                "12 Oct.",
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Puce de filtrage
  Widget _buildFilterChip(String label) {
    final bool isSelected = _activeFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1E5E4E),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF1E5E4E),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFF1E5E4E).withOpacity(0.15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (selected) {
          setState(() {
            _activeFilter = label;
          });
        },
      ),
    );
  }

  // Élément de la liste d'activités
  Widget _buildActivityItem(
    String name,
    String date,
    String amount,
    String status,
    Color statusBg,
    Color statusTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            spreadRadius: 1,
            blurRadius: 8,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
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