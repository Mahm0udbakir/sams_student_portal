import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class FeeReceiptDetailScreen extends StatefulWidget {
  const FeeReceiptDetailScreen({super.key});

  @override
  State<FeeReceiptDetailScreen> createState() => _FeeReceiptDetailScreenState();
}

class _FeeReceiptDetailScreenState extends State<FeeReceiptDetailScreen> {
  String _selectedReceiptId = 'HST-2026-04';

  static const _receipts = [
    (
      id: 'HST-2026-04',
      title: 'Hostel Fee - April 2026',
      amount: 'EGP 4,250',
      paidOn: '03 Apr 2026',
      status: 'Paid',
      method: 'Visa •••• 2145',
    ),
    (
      id: 'HST-2026-03',
      title: 'Hostel Fee - March 2026',
      amount: 'EGP 4,250',
      paidOn: '02 Mar 2026',
      status: 'Paid',
      method: 'Bank transfer',
    ),
    (
      id: 'HST-2026-02',
      title: 'Hostel Fee - February 2026',
      amount: 'EGP 4,250',
      paidOn: 'Pending due 20 Apr 2026',
      status: 'Due',
      method: 'Awaiting payment',
    ),
  ];

  void _requestReceipt() {
    final selected = _receipts.firstWhere(
      (item) => item.id == _selectedReceiptId,
    );
    ModernSnackbars.show(
      context,
      message: '${selected.title} PDF request sent to your SAMS email.',
      type: ModernSnackbarType.success,
    );
  }

  void _downloadReceipt(
    ({
      String id,
      String title,
      String amount,
      String paidOn,
      String status,
      String method,
    })
    receipt,
  ) {
    if (receipt.status != 'Paid') {
      ModernSnackbars.show(
        context,
        message: 'Receipt unavailable until payment is completed.',
        type: ModernSnackbarType.info,
      );
      return;
    }

    ModernSnackbars.show(
      context,
      message: '${receipt.title} downloaded (demo).',
      type: ModernSnackbarType.success,
    );
  }

  void _shareReceipt(
    ({
      String id,
      String title,
      String amount,
      String paidOn,
      String status,
      String method,
    })
    receipt,
  ) {
    ModernSnackbars.show(
      context,
      message: '${receipt.title} share link copied (demo).',
      type: ModernSnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Fee Receipt'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF063454), Color(0xFF0A4A75)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E063454),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFFD7E9FA),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      SamsLocaleText(
                        'Payment summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SamsLocaleText(
                    'Academic Year 2025/2026\nTotal paid: EGP 8,500 • Outstanding: EGP 4,250',
                    style: TextStyle(
                      color: Color(0xFFD7E9FA),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SamsLocaleText(
              'Available receipts',
              style: TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ..._receipts.map((receipt) {
              final selected = _selectedReceiptId == receipt.id;
              final isPaid = receipt.status == 'Paid';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SamsPressable(
                  onTap: () => setState(() => _selectedReceiptId = receipt.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? SamsUiTokens.primary.withValues(alpha: 0.42)
                            : const Color(0xFFDDE5EE),
                        width: selected ? 1.4 : 1,
                      ),
                      boxShadow: selected ? SamsUiTokens.cardShadow : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SamsLocaleText(
                                receipt.title,
                                style: const TextStyle(
                                  color: SamsUiTokens.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? const Color(0xFFE9F8EF)
                                    : const Color(0xFFFFF6E9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: SamsLocaleText(
                                receipt.status,
                                style: TextStyle(
                                  color: isPaid
                                      ? const Color(0xFF0E8F54)
                                      : const Color(0xFFB7791F),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SamsLocaleText(
                          '${receipt.amount} • ${receipt.paidOn}',
                          style: const TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        SamsLocaleText(
                          receipt.method,
                          style: const TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontSize: 12.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SamsTapScale(
                                child: OutlinedButton.icon(
                                  onPressed: () => _shareReceipt(receipt),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(38),
                                    foregroundColor: SamsUiTokens.primary,
                                    side: BorderSide(
                                      color: SamsUiTokens.primary.withValues(
                                        alpha: 0.32,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.ios_share_rounded,
                                    size: 18,
                                  ),
                                  label: const SamsLocaleText('Share'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SamsTapScale(
                                child: ElevatedButton.icon(
                                  onPressed: () => _downloadReceipt(receipt),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(38),
                                    backgroundColor: receipt.status == 'Paid'
                                        ? SamsUiTokens.primary
                                        : const Color(0xFF9CA3AF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 18,
                                  ),
                                  label: SamsLocaleText(
                                    receipt.status == 'Paid'
                                        ? 'Download'
                                        : 'Unavailable',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCE5EE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: SamsUiTokens.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: SamsLocaleText(
                      'Official stamped receipts are generated within 1-2 minutes and sent to your registered email.',
                      style: TextStyle(
                        color: SamsUiTokens.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SamsTapScale(
              child: ElevatedButton.icon(
                onPressed: _requestReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const SamsLocaleText('Request selected receipt PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
