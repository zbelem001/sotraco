import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

class SupabaseAuthService {
  final _supabase = Supabase.instance.client;
  
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  // Écouter les changements d'authentification
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      if (data.session != null) {
        return _getUserProfile(data.session!.user.id);
      }
      return null;
    }).asyncExpand((future) async* {
      if (future != null) {
        yield await future;
      } else {
        yield null;
      }
    });
  }
  
  // Inscription avec numéro de téléphone et mot de passe
  Future<bool> register(String name, String phoneNumber, String password) async {
    try {
      // Créer un email fictif à partir du numéro de téléphone
      // Supabase nécessite un email pour l'authentification
      final email = '${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@sotra.bf';
      
      // S'inscrire avec Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'phone_number': phoneNumber,
          'name': name,
        },
      );
      
      if (response.user == null) {
        return false;
      }
      
      // Créer le profil utilisateur dans la base de données
      await _supabase.from('users').insert({
        'user_id': response.user!.id,
        'name': name,
        'phone_number': phoneNumber,
        'avatar_id': 'avatar_${DateTime.now().millisecondsSinceEpoch}',
        'is_location_enabled': true,
        'reliability_score': 5.0,
        'friends_list': [],
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Charger le profil
      _currentUser = await _getUserProfile(response.user!.id);
      
      return true;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return false;
    }
  }
  
  // Connexion avec numéro de téléphone
  Future<bool> login(String phoneNumber, String password) async {
    try {
      // Convertir le numéro en email
      final email = '${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}@sotra.bf';
      
      // Se connecter
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        return false;
      }
      
      // Charger le profil
      _currentUser = await _getUserProfile(response.user!.id);
      
      return true;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }
  
  // Connexion démo (pour tests)
  Future<bool> loginWithDemo() async {
    try {
      // Créer un utilisateur démo s'il n'existe pas
      final demoEmail = '70123456@sotra.bf';
      final demoPassword = 'demo123';
      
      try {
        // Essayer de se connecter
        final response = await _supabase.auth.signInWithPassword(
          email: demoEmail,
          password: demoPassword,
        );
        
        if (response.user != null) {
          _currentUser = await _getUserProfile(response.user!.id);
          return true;
        }
      } catch (e) {
        // Si la connexion échoue, créer le compte démo
        final response = await _supabase.auth.signUp(
          email: demoEmail,
          password: demoPassword,
          data: {
            'phone_number': '+22670123456',
            'name': 'Amadou Traoré',
          },
        );
        
        if (response.user != null) {
          // Créer le profil
          await _supabase.from('users').insert({
            'user_id': response.user!.id,
            'name': 'Amadou Traoré',
            'phone_number': '+22670123456',
            'avatar_id': 'avatar_demo',
            'is_location_enabled': true,
            'reliability_score': 4.5,
            'friends_list': [],
            'latitude': 12.3714,
            'longitude': -1.5197,
            'location_timestamp': DateTime.now().toIso8601String(),
          });
          
          _currentUser = await _getUserProfile(response.user!.id);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la connexion démo: $e');
      return false;
    }
  }
  
  // Déconnexion
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
  
  // Charger le profil utilisateur depuis la base de données
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();
      
      return UserModel(
        userId: data['user_id'] as String,
        name: data['name'] as String,
        phoneNumber: data['phone_number'] as String,
        avatarId: data['avatar_id'] as String,
        location: data['latitude'] != null && data['longitude'] != null
            ? LocationModel(
                latitude: (data['latitude'] as num).toDouble(),
                longitude: (data['longitude'] as num).toDouble(),
                timestamp: DateTime.parse(data['location_timestamp'] as String),
              )
            : null,
        isLocationEnabled: data['is_location_enabled'] as bool,
        reliabilityScore: (data['reliability_score'] as num).toDouble(),
        friendsList: (data['friends_list'] as List<dynamic>).cast<String>(),
      );
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      return null;
    }
  }
  
  // Mettre à jour la localisation de l'utilisateur
  Future<void> updateUserLocation(double latitude, double longitude) async {
    if (_currentUser == null) return;
    
    try {
      await _supabase.from('users').update({
        'latitude': latitude,
        'longitude': longitude,
        'location_timestamp': DateTime.now().toIso8601String(),
      }).eq('user_id', _currentUser!.userId);
      
      _currentUser = _currentUser!.copyWith(
        location: LocationModel(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour de la localisation: $e');
    }
  }
  
  // Vérifier si l'utilisateur est déjà connecté
  Future<bool> checkCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUser = await _getUserProfile(session.user.id);
        return _currentUser != null;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification de la session: $e');
      return false;
    }
  }
}
