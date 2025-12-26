import '../models/user_model.dart';

class AuthService {
  UserModel? _currentUser;

  // Utilisateur fictif pour la démo
  final UserModel _demoUser = UserModel(
    userId: 'demo_001',
    name: 'Amadou Traoré',
    phoneNumber: '+22670123456',
    avatarId: 'avatar_001',
    location: LocationModel(
      latitude: 12.3714,
      longitude: -1.5197,
      timestamp: DateTime.now(),
    ),
    isLocationEnabled: true,
    reliabilityScore: 4.5,
    friendsList: ['friend_001', 'friend_002', 'friend_003'],
  );

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> loginWithDemo() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = _demoUser;
    return true;
  }

  Future<bool> login(String phoneNumber, String password) async {
    // Simulation d'authentification
    await Future.delayed(const Duration(seconds: 2));
    
    if (phoneNumber == '+22670123456' || phoneNumber == '70123456') {
      _currentUser = _demoUser;
      return true;
    }
    
    return false;
  }

  Future<bool> register(String name, String phoneNumber, String password) async {
    // Simulation d'inscription
    await Future.delayed(const Duration(seconds: 2));
    
    _currentUser = UserModel(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phoneNumber: phoneNumber,
      isLocationEnabled: false,
      reliabilityScore: 0.0,
      friendsList: [],
    );
    
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  Future<void> updateUserLocation(LocationModel location) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(location: location);
    }
  }

  Future<void> toggleLocationEnabled() async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isLocationEnabled: !_currentUser!.isLocationEnabled,
      );
    }
  }
}
