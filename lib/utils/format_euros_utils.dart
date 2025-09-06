class FormatEurosUtils {
  static String formatEuro(double v) =>
      '€${v.toStringAsFixed(2).replaceAll('.', ',')}';
}
