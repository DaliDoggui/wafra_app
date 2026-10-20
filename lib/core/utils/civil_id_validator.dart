/// Kuwait PACI (Public Authority for Civil Information) Modulo-11 Checksum Validator
/// Used to validate authentic 12-digit Kuwait Civil IDs across client applications.
bool isValidKuwaitCivilId(String civilId) {
  final clean = civilId.trim();
  if (clean.length != 12 || !RegExp(r'^\d{12}$').hasMatch(clean)) {
    return false;
  }

  const weights = [2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
  int total = 0;
  for (int i = 0; i < 11; i++) {
    total += int.parse(clean[i]) * weights[i];
  }

  final remainder = total % 11;
  int checkDigit = 11 - remainder;

  if (checkDigit == 11) {
    checkDigit = 0;
  } else if (checkDigit == 10) {
    return false; // PACI does not issue IDs with check digit 10
  }

  return checkDigit == int.parse(clean[11]);
}
