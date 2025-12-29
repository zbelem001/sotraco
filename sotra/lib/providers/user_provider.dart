import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isAdmin => _user?['role'] == 'admin';

  // Charger l'utilisateur depuis SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    
    if (userJson != null) {
      _user = jsonDecode(userJson);
      notifyListeners();
    }
  }

  // Sauvegarder l'utilisateur après connexion/inscription
  Future<void> setUser(Map<String, dynamic> userData, String authToken) async {
    _user = userData;
    _token = authToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authToken);
    await prefs.setString('user_data', jsonEncode(userData));
    
    notifyListeners();
  }

  // Mettre à jour les infos utilisateur
  Future<void> updateUser(Map<String, dynamic> updates) async {
    if (_user != null) {
      _user = {..._user!, ...updates};
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));
      
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    
    notifyListeners();
  }

  // Getters pratiques
  String get userName => _user?['name'] ?? 'Utilisateur';
  String get userPhone => _user?['phoneNumber'] ?? '';
  String get userId => _user?['userId'] ?? '';
  double get reliabilityScore => (_user?['reliabilityScore'] is String) 
      ? double.tryParse(_user!['reliabilityScore']) ?? 5.0
      : (_user?['reliabilityScore'] ?? 5.0).toDouble();
  String? get avatarId => _user?['avatarId'];
  String get userRole => _user?['role'] ?? 'user';
}
