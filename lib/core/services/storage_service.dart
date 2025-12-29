import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static bool? isLoggedIn;
  static SharedPreferences? _preferences;

  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _firstNameKey = 'firstName';
  static const String _lastNameKey = 'lastName';
  static const String _emailKey = 'email';
  static const String _phoneNumberKey = 'phoneNumber';
  static const String _roleKey = 'role';
  static const String _passwordKey = 'password';
  static const String _provider = 'provider';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await checkLoggedIn();
  }

  static Future<void> checkLoggedIn() async {
    isLoggedIn = _preferences?.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> makeLoggedIn() async {
    await _preferences?.setBool(_isLoggedInKey, true);
    isLoggedIn = true;
  }

  static Future<void> makeLoggedOut() async {
    await _preferences?.setBool(_isLoggedInKey, false);
    isLoggedIn = false;
  }

  static Future<void> saveToken(String token) async {
    await _preferences?.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _preferences?.getString(_tokenKey);
  }

  // Refresh Token methods
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _preferences?.setString(_refreshTokenKey, refreshToken);
  }

  static String? getRefreshToken() {
    return _preferences?.getString(_refreshTokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    await _preferences?.setString(_userIdKey, userId);
  }

  static String? getUserId() {
    return _preferences?.getString(_userIdKey);
  }

  static Future<void> saveUserRole(String role) async {
    await _preferences?.setString(_roleKey, role);
  }

  static String? getUserRole() {
    return _preferences?.getString(_roleKey);
  }

  static Future<void> saveFirstName(String firstName) async {
    await _preferences?.setString(_firstNameKey, firstName);
  }

  static String? getFirstName() {
    return _preferences?.getString(_firstNameKey);
  }

  static Future<void> saveLastName(String lastName) async {
    await _preferences?.setString(_lastNameKey, lastName);
  }

  static String? getLastName() {
    return _preferences?.getString(_lastNameKey);
  }

  static Future<void> saveEmail(String email) async {
    await _preferences?.setString(_emailKey, email);
  }

  static String? getEmail() {
    return _preferences?.getString(_emailKey);
  }

  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _preferences?.setString(_phoneNumberKey, phoneNumber);
  }

  static String? getPhoneNumber() {
    return _preferences?.getString(_phoneNumberKey);
  }

  static Future<void> savePassword(String password) async {
    await _preferences?.setString(_passwordKey, password);
  }

  static String? getPassword() {
    return _preferences?.getString(_passwordKey);
  }

  static Future<void> saveProvider(String provider) async {
    await _preferences?.setString(_provider, provider);
  }

  static String? getProvider() {
    return _preferences?.getString(_provider);
  }

  static Future<void> clearAllUserData() async {
    await _preferences?.remove(_firstNameKey);
    await _preferences?.remove(_lastNameKey);
    await _preferences?.remove(_emailKey);
    await _preferences?.remove(_phoneNumberKey);
    await _preferences?.remove(_roleKey);
    await _preferences?.remove(_tokenKey);
    await _preferences?.remove(_refreshTokenKey);
    await _preferences?.remove(_userIdKey);
    await _preferences?.remove(_passwordKey);
    await _preferences?.remove(_provider);
    await makeLoggedOut();
  }

  // Alias for clearAllUserData (for API service)
  static Future<void> clearAll() async {
    await clearAllUserData();
  }
}
