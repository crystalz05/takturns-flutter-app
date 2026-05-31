String maskWalletAddress(String address, {int leadingChars = 4, int trailingChars = 3}) {
  // Return early or handle empty/invalid strings gracefully
  if (address.isEmpty) return '';

  // Clean up any accidental leading/trailing whitespace
  final cleanAddress = address.trim();

  // If the address is too short to mask properly, return it as-is
  // (Standard EVM addresses are 42 characters, including '0x')
  final totalVisible = 2 + leadingChars + trailingChars; // '0x' + start + end
  if (cleanAddress.length <= totalVisible) {
    return cleanAddress;
  }

  // Extract the components
  final prefix = cleanAddress.substring(0, 2); // Extracts '0x'
  final start = cleanAddress.substring(2, 2 + leadingChars);
  final end = cleanAddress.substring(cleanAddress.length - trailingChars);

  // Combine them with the asterisks mask
  return '$prefix$start***$end';
}