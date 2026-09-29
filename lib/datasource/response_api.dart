class ResponseApi {
  static String translate(String message, String locale) {
    final translations = {
      'fr': {
        'User enregistré avec succès': 'Utilisateur enregistré avec succès',
        'Connexion réussie': 'Connexion réussie',
        'Invalid credentials': 'Identifiants incorrects',
        'Une erreur est survenue.': 'Une erreur est survenue.',
        'Erreur inconnue': 'Erreur inconnue',
      },
      'en': {
        'User enregistré avec succès': 'User registered successfully',
        'Connexion réussie': 'Login successful',
        'Invalid credentials': 'Invalid credentials',
        'Une erreur est survenue.': 'An error occurred.',
        'Erreur inconnue': 'Unknown error',
      },
    };

    return translations[locale]?[message] ?? message;
  }
}
