import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loai/utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppConstants.primaryColor;
  Color _secondaryColor = AppConstants.secondaryColor;
  Color _accentColor = AppConstants.accentColor;
  double _blur = AppConstants.defaultBlur;
  double _transparency = AppConstants.defaultTransparency;
  double _edgeThickness = AppConstants.defaultEdgeThickness;
  Color _edgeColor = Colors.grey;
  double _edgeTransparency = 1.0;
  bool _useGradient = true;
  
  // Theme modes
  ThemeMode get themeMode => _themeMode;
  
  // Colors
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  
  // UI customization
  double get blur => _blur;
  double get transparency => _transparency;
  double get edgeThickness => _edgeThickness;
  Color get edgeColor => _edgeColor;
  double get edgeTransparency => _edgeTransparency;
  bool get useGradient => _useGradient;
  
  // Get current theme
  ThemeData get currentTheme => _buildThemeData(Brightness.light);
  
  // Get dark theme
  ThemeData get darkTheme => _buildThemeData(Brightness.dark);
  
  ThemeProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    _primaryColor = Color(prefs.getInt('primary_color') ?? AppConstants.primaryColor.value);
    _secondaryColor = Color(prefs.getInt('secondary_color') ?? AppConstants.secondaryColor.value);
    _accentColor = Color(prefs.getInt('accent_color') ?? AppConstants.accentColor.value);
    
    _blur = prefs.getDouble('blur') ?? AppConstants.defaultBlur;
    _transparency = prefs.getDouble('transparency') ?? AppConstants.defaultTransparency;
    _edgeThickness = prefs.getDouble('edge_thickness') ?? AppConstants.defaultEdgeThickness;
    _edgeColor = Color(prefs.getInt('edge_color') ?? Colors.grey.value);
    _edgeTransparency = prefs.getDouble('edge_transparency') ?? 1.0;
    _useGradient = prefs.getBool('use_gradient') ?? true;
    
    notifyListeners();
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setInt('primary_color', _primaryColor.value);
    await prefs.setInt('secondary_color', _secondaryColor.value);
    await prefs.setInt('accent_color', _accentColor.value);
    
    await prefs.setDouble('blur', _blur);
    await prefs.setDouble('transparency', _transparency);
    await prefs.setDouble('edge_thickness', _edgeThickness);
    await prefs.setInt('edge_color', _edgeColor.value);
    await prefs.setDouble('edge_transparency', _edgeTransparency);
    await prefs.setBool('use_gradient', _useGradient);
  }
  
  ThemeData _buildThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: _primaryColor,
        primaryContainer: _primaryColor.withOpacity(0.1),
        secondary: _secondaryColor,
        secondaryContainer: _secondaryColor.withOpacity(0.1),
        tertiary: _accentColor,
        surface: isDark ? Colors.grey[900]! : Colors.white,
        background: isDark ? Colors.grey[850]! : AppConstants.backgroundColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
        onBackground: isDark ? Colors.white : Colors.black,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: isDark ? Colors.grey[900]! : AppConstants.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        thickness: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
  
  // Setters
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setSecondaryColor(Color color) async {
    _secondaryColor = color;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setBlur(double value) async {
    _blur = value.clamp(0.0, 100.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setTransparency(double value) async {
    _transparency = value.clamp(0.0, 1.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setEdgeThickness(double value) async {
    _edgeThickness = value.clamp(0.0, 10.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setEdgeColor(Color color) async {
    _edgeColor = color;
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setEdgeTransparency(double value) async {
    _edgeTransparency = value.clamp(0.0, 1.0);
    await _savePreferences();
    notifyListeners();
  }
  
  Future<void> setUseGradient(bool value) async {
    _useGradient = value;
    await _savePreferences();
    notifyListeners();
  }
  
  // Get gradient for user messages
  LinearGradient get userGradient => LinearGradient(
    colors: _useGradient 
      ? [AppConstants.userGradient[0], AppConstants.userGradient[1]]
      : [_primaryColor, _primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Get gradient for bot messages
  LinearGradient get botGradient => LinearGradient(
    colors: _useGradient
      ? [AppConstants.botGradient[0], AppConstants.botGradient[1]]
      : [_secondaryColor, _secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Get chat bubble decoration
  BoxDecoration getChatBubbleDecoration(MessageSender sender, bool isDark) {
    final isUser = sender == MessageSender.user;
    final gradient = isUser ? userGradient : botGradient;
    
    return BoxDecoration(
      gradient: _useGradient ? gradient : null,
      color: !_useGradient ? (isUser ? _primaryColor : _secondaryColor) : null,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _edgeColor.withOpacity(_edgeTransparency),
        width: _edgeThickness,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1 * _transparency),
          blurRadius: _blur,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
