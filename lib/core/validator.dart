abstract final class Validator {
  static String? name(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return "Ім'я не може бути порожнім";
    if (trimmed.length < 2) return "Ім'я занадто коротке";
    if (trimmed.contains(RegExp(r'\d'))) {
      return "Ім'я не повинно містити цифри";
    }
    return null;
  }

  static String? email(String value) {
    if (!value.contains('@') || !value.contains('.')) {
      return 'Некоректний формат email';
    }
    return null;
  }

  static String? password(String value) {
    if (value.length < 6) return 'Мінімум 6 символів';
    return null;
  }

  static String? confirmPassword(String pass, String confirm) {
    if (pass != confirm) return 'Паролі не співпадають';
    return null;
  }
}
