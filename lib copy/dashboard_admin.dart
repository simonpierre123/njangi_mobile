import 'package:flutter/material.dart';

void main() {
  runApp(const TontineAdminApp());
}

class TontineAdminApp extends StatelessWidget {
  const TontineAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E5E4E),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
        fontFamily: 'sans-serif',
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs de la maquette
    const primaryGreen = Color(0xFF1E5E4E);
    const cardGreenBg = Color(0xFF3B846F);
    const textDark = Color(0xFF1C2D27);
    const lightGreenBg = Color(0xFFE8F3EF);

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Famille Bamiléké",
                  style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F5EE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(color: primaryGreen, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Cycle 8/12",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                )
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
            // 1. Carte Verte : Santé du Groupe
            _buildGroupHealthCard(cardGreenBg),
            const SizedBox(height: 24),

            // 2. Section : Priorités de gestion
            _buildSectionTitle("Priorités de gestion", textDark),
            const SizedBox(height: 12),
            _buildPrioritiesCard(),
            const SizedBox(height: 24),

            // 3. Section : Actions rapides
            _buildSectionTitle("Actions rapides", textDark),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(primaryGreen),
            const SizedBox(height: 24),

            // 4. Section : Cycle en cours
            _buildCycleProgressCard(primaryGreen, textDark),
            const SizedBox(height: 24),

            // 5. Section : Statut des Membres
            _buildSectionTitle("Statut des Membres", textDark),
            const SizedBox(height: 12),
            _buildMembersStatusCard(primaryGreen, textDark),
            const SizedBox(height: 24),

            // 6. Section : Gestion des Prêts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Gestion des Prêts", textDark),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Dossiers",
                    style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
            _buildLoansManagementCard(primaryGreen, textDark),
            const SizedBox(height: 24),

            // 7. Section : Activité récente
            _buildSectionTitle("Activité récente", textDark),
            const SizedBox(height: 12),
            _buildRecentActivityList(primaryGreen, textDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(primaryGreen, lightGreenBg),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  // Titre générique des sections
  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 1. Carte "Santé du Groupe"
  Widget _buildGroupHealthCard(Color bgColor) {
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
                children: [
                  const Text("SANTÉ DU GROUPE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        "94%",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Stable", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Caisse actuelle", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  SizedBox(height: 4),
                  Text(
                    "2 450 000 FCFA",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStatItem("Membres à jour", "12/15"),
              _buildSmallStatItem("En attente", "3"),
              _buildSmallStatItem("Prêts actifs", "2"),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Mis à jour il y a 5 min",
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 2. Carte "Priorités de gestion"
  Widget _buildPrioritiesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildPriorityItem(Icons.payment, "3 cotisations à enregistrer", false),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildPriorityItem(Icons.description_outlined, "2 demandes de prêt", false),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildPriorityItem(Icons.warning_amber_rounded, "1 membre en retard", true),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(IconData icon, String text, bool isAlert) {
    final accentColor = isAlert ? const Color(0xFFE55C5C) : const Color(0xFF1E5E4E);
    return ListTile(
      leading: Icon(icon, color: accentColor),
      title: Text(
        text,
        style: TextStyle(
          color: isAlert ? accentColor : const Color(0xFF1C2D27),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.7)),
      onTap: () {},
    );
  }

  // 3. Grille "Actions rapides"
  Widget _buildQuickActionsGrid(Color primaryColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildQuickActionItem(Icons.add_circle_outline, "Enregistrer Cotisations", primaryColor),
        _buildQuickActionItem(Icons.account_balance_outlined, "Gérer les Prêts", primaryColor),
        _buildQuickActionItem(Icons.people_outline, "Membres", primaryColor),
        _buildQuickActionItem(Icons.insert_chart_outlined, "Rapports", primaryColor),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1F5EA)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Carte "Cycle en cours"
  Widget _buildCycleProgressCard(Color primaryColor, Color textDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Cycle en cours",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C2D27)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Cycle 8 sur 12",
                  style: TextStyle(color: Color(0xFF1E5E4E), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Progression", style: TextStyle(color: Colors.grey, fontSize: 11)),
              Text("60%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Color(0xFFECEFF1),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E5E4E)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Prochain bénéficiaire", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      SizedBox(height: 4),
                      Text("Jean D.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Restants", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      SizedBox(height: 4),
                      Text("4 cycles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 5. Carte "Statut des Membres"
  Widget _buildMembersStatusCard(Color primaryColor, Color textDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatusBox("Total", "15", Colors.white, textDark, hasBorder: true),
              const SizedBox(width: 8),
              _buildStatusBox("À jour", "11", const Color(0xFFEBFDF5), const Color(0xFF1E5E4E)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusBox("En attente", "3", const Color(0xFFFFF9E6), const Color(0xFFB28900)),
              const SizedBox(width: 8),
              _buildStatusBox("En retard", "1", const Color(0xFFFEECEB), const Color(0xFFE55C5C)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1F5EA)),
                backgroundColor: const Color(0xFFEBFDF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gérer les membres",
                    style: TextStyle(color: Color(0xFF1E5E4E), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF1E5E4E)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBox(String title, String count, Color bgColor, Color textColor, {bool hasBorder = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder ? Border.all(color: Colors.grey.withOpacity(0.2)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 6. Carte "Gestion des Prêts"
  Widget _buildLoansManagementCard(Color primaryColor, Color textDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildLoanRow("Prêts actifs", "2", textDark),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          _buildLoanRow("Demandes en attente", "2", textDark),
          const Divider(height: 1, color: Color(0xFFECECEC)),
          _buildLoanRow("Retards", "0", textDark),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1F5EA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CAPACITÉ D'EMPRUNT",
                  style: TextStyle(color: Color(0xFF1E5E4E), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  "1 200 000 FCFA",
                  style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoanRow(String label, String value, Color textDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // 7. Section "Activité récente"
  Widget _buildRecentActivityList(Color primaryColor, Color textDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildActivityItem(
            icon: Icons.payments_outlined,
            iconBg: const Color(0xFFE6F5EE),
            iconColor: const Color(0xFF2CE497),
            title: "Cotisation enregistrée (Marie)",
            subtitle: "Il y a 2h • Transaction #TR90452",
            textDark: textDark,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.check_circle_outline,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: Colors.purple,
            title: "Prêt approuvé (Alex)",
            subtitle: "Il y a 5h • Montant: 250 000 FCFA",
            textDark: textDark,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.person_add_alt_1_outlined,
            iconBg: const Color(0xFFFFF9E6),
            iconColor: const Color(0xFFFFB300),
            title: "Nouveau membre (Thomas L.)",
            subtitle: "Hier • Profil en attente de vérification",
            textDark: textDark,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1F5EA)),
                backgroundColor: const Color(0xFFEBFDF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Voir tout l'historique",
                    style: TextStyle(color: Color(0xFF1E5E4E), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF1E5E4E)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Barre de navigation inférieure
  Widget _buildBottomNav(Color primaryColor, Color activeBg) {
    return BottomNavigationBar(
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
              color: _currentNavIndex == 0 ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.grid_view_rounded),
          ),
          label: 'Tableau de Bord',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
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