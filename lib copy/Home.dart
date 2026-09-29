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
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0; // Onglet "Accueil" actif

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs de la maquette
    const primaryColor = Color(0xFF1E5E4E); // Vert foncé principal
    const cardGreenBg = Color(0xFF3B846F); // Vert moyen pour la synthèse
    const lightGreenBg = Color(0xFFE8F3EF); // Vert très clair
    const alertRedText = Color(0xFFE55C5C);
    const textDark = Color(0xFF1C2D27);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // --- En-tête : Profil & Message de bienvenue ---
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'), // Image de profil temporaire
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Bonjour, Alex',
                                  style: TextStyle(
                                    color: textDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('👋', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                            const Text(
                              'Heureux de vous revoir',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Carte Verte : Synthèse d'Activité ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardGreenBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SYNTHÈSE D\'ACTIVITÉ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text(
                              'Vérifications requises',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5B5B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Badges d'activité
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActivityBadge("3", "Communautés"),
                            _buildActivityBadge("2", "Actions à traiter"),
                            _buildActivityBadge("", "Réunion demain", icon: Icons.calendar_today_outlined),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Cotisations en attente
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cotisations en attente',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '75 000 FCFA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Barre de Recherche ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une communauté...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Section Mes Communautés ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mes Communautés',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Text(
                              'Voir les 3',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14, color: primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Suivi de vos groupes et cycles',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // --- Liste des Cartes de Communauté ---
                  // 1. Famille Bamiléké
                  _buildCommunityCard(
                    title: "Famille Bamiléké",
                    subtitle: "ADMIN  •  Cycle 8/12",
                    iconData: Icons.group,
                    iconColor: primaryColor,
                    tagText: "Réunion demain",
                    tagColor: const Color(0xFFE6F5EE),
                    tagTextColor: primaryColor,
                    membersCount: "15",
                    contribution: "50k FCFA/mois",
                    progress: 0.6,
                    progressLabel: "60%",
                    date: "12 Oct. 2023",
                    statusText: "À jour",
                    isOverdue: false,
                  ),
                  const SizedBox(height: 12),

                  // 2. Promo 2015
                  _buildCommunityCard(
                    title: "Promo 2015",
                    subtitle: "Cycle 3/10",
                    iconData: Icons.school,
                    iconColor: primaryColor,
                    tagText: "En retard",
                    tagColor: const Color(0xFFFEECEB),
                    tagTextColor: alertRedText,
                    membersCount: "25",
                    contribution: "25k FCFA/mois",
                    progress: 0.3,
                    progressLabel: "30%",
                    date: "25 Oct. 2023",
                    statusText: "Payer maintenant",
                    isOverdue: true,
                  ),
                  const SizedBox(height: 80), // Marge en bas pour laisser de la place au bouton flottant
                ],
              ),
            ),

            // --- Bouton Flottant (Ajouter) positionné en bas à droite ---
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: primaryColor,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),

      // --- Barre de Navigation Inférieure ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _currentNavIndex == 0 ? lightGreenBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_filled),
            ),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: Colors.red,
              smallSize: 6,
              child: Icon(Icons.notifications_none_outlined),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // --- Widget pour construire les badges d'activité (Carte de Synthèse) ---
  Widget _buildActivityBadge(String count, String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
          ],
          if (count.isNotEmpty) ...[
            Text(
              count,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // --- Widget Réutilisable pour les Cartes de Communauté ---
  Widget _buildCommunityCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required String tagText,
    required Color tagColor,
    required Color tagTextColor,
    required String membersCount,
    required String contribution,
    required double progress,
    required String progressLabel,
    required String date,
    required String statusText,
    required bool isOverdue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Haut de la carte : Icone, Titre, Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFDF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1C2D27),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tagText,
                  style: TextStyle(
                    color: tagTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Infos : Membres & Cotisation
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MEMBRES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Avatars empilés simulés
                        Stack(
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey[100]),
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey[200]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF2CE497).withOpacity(0.4),
                                child: Text(
                                  membersCount,
                                  style: const TextStyle(color: Color(0xFF1E5E4E), fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(membersCount, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COTISATION', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      contribution,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C2D27)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Barre de progression
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROGRESSION', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(
                progressLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1C2D27)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E5E4E)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          
          const Divider(height: 1, color: Color(0xFFECECEC)),
          const SizedBox(height: 12),

          // Bas de carte : Date & Statut d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              if (isOverdue)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Color(0xFF1E5E4E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.grey,
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