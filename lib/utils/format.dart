/// "40000.00" + "KHR" → "40,000៛"
/// "2.5" + "USD"      → "$2.50"
String formatMoney(String raw, String currency) {
  final value = double.tryParse(raw) ?? 0;
  final isUsd = currency == 'USD';

  final parts = value.toStringAsFixed(isUsd ? 2 : 0).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  final text = parts.length > 1 ? '$whole.${parts[1]}' : whole;

  return isUsd ? '\$$text' : '$text៛';
}