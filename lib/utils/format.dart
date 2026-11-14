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


/// "2026-11-12T00:40:23.000000Z" (UTC) → "12/11/2026 07:40" (ម៉ោងទូរស័ព្ទ)
String formatDateTime(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '-';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}