class AppConstants {
  AppConstants._();

  // ─── Network ────────────────────────────────────────────────────────────────
  static const String rpcUrl =
      'https://sepolia-rollup.arbitrum.io/rpc';
  static const int chainId = 421614; // Arbitrum Sepolia

  // ─── Contracts ──────────────────────────────────────────────────────────────
  static const String factoryAddress =
      '0x7541fb68E778ceF41586368516A8Cf0Dd15227a3';
  // static const String groupImplementationAddress =
  //     '0x17889c0e094F88f9f6caF75Fbc7Ed52192632207';
  static const String usdcAddress =
      '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d';

  // ─── USDC ───────────────────────────────────────────────────────────────────
  static const int usdcDecimals = 6;
  static final BigInt maxUint256 = BigInt.parse(
    '115792089237316195423570985008687907853269984665640564039457584007913129639935',
  );

  // ─── Group states ────────────────────────────────────────────────────────────
  static const int statePending = 0;
  static const int stateActive = 1;
  static const int stateCompleted = 2;
  static const int stateDissolved = 3;

  // ─── Vote options ────────────────────────────────────────────────────────────
  static const int voteContinue = 1;
  static const int voteDissolve = 2;
}
