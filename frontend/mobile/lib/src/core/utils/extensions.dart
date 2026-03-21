extension CurrencyFormatter on num {
  /// Formats the number as an LKR currency string (e.g., "LKR 1,500").
  String toLKR() {
    if (this.toDouble().isNaN) return 'N/A';
    
    // Using RegExp for thousands separator
    return "LKR ${this.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}";
  }
}

extension DateFormatter on DateTime {
  /// Returns a human-readable string for the date (e.g., "Mar 21, 2026").
  String toReadableDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[this.month - 1]} ${this.day}, ${this.year}";
  }
}
