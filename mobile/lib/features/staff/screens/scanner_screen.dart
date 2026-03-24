import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/staff_provider.dart';

// ---------------------------------------------------------------------------
// Service catalog — maps service names to default prices (in cents).
// ---------------------------------------------------------------------------

const _services = <String, int>{
  'Classic Haircut': 3000,
  'Fade Haircut': 3500,
  'Beard Trim': 2000,
  'Hair & Beard Combo': 4500,
  'Kids Haircut': 2000,
};

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // QR detected
  // -----------------------------------------------------------------------
  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);
    _cameraController.stop();
    _showCheckInSheet(rawValue);
  }

  // -----------------------------------------------------------------------
  // Bottom sheet with check-in form
  // -----------------------------------------------------------------------
  void _showCheckInSheet(String qrCode) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _CheckInSheet(
        qrCode: qrCode,
        onDone: _resetScanner,
      ),
    ).then((_) => _resetScanner());
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() => _hasScanned = false);
    _cameraController.start();
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview -- full viewport
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Semi-transparent overlay with cutout
          _ScanOverlay(scanAreaSize: scanAreaSize),

          // Label above the cutout
          Positioned(
            top: (size.height - scanAreaSize) / 2 - 56,
            left: 0,
            right: 0,
            child: Text(
              'Scan customer QR code',
              textAlign: TextAlign.center,
              style: AppTypography.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Scan frame border corners
          _ScanFrameCorners(scanAreaSize: scanAreaSize),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Torch toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
              onPressed: () => _cameraController.toggleTorch(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scan overlay — dark layer with a transparent cutout
// ---------------------------------------------------------------------------

class _ScanOverlay extends StatelessWidget {
  final double scanAreaSize;

  const _ScanOverlay({required this.scanAreaSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _OverlayPainter(scanAreaSize: scanAreaSize),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double scanAreaSize;

  _OverlayPainter({required this.scanAreaSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw full overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Cut out the scan area
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)),
      clearPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Corner markers around the scan cutout
// ---------------------------------------------------------------------------

class _ScanFrameCorners extends StatelessWidget {
  final double scanAreaSize;

  const _ScanFrameCorners({required this.scanAreaSize});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    const cornerLength = 24.0;
    const cornerWidth = 3.0;

    return Stack(
      children: [
        // Top-left
        Positioned(
          left: left,
          top: top,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            topLeft: true,
          ),
        ),
        // Top-right
        Positioned(
          right: left,
          top: top,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            topRight: true,
          ),
        ),
        // Bottom-left
        Positioned(
          left: left,
          bottom: size.height - top - scanAreaSize,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            bottomLeft: true,
          ),
        ),
        // Bottom-right
        Positioned(
          right: left,
          bottom: size.height - top - scanAreaSize,
          child: _Corner(
            cornerLength: cornerLength,
            cornerWidth: cornerWidth,
            bottomRight: true,
          ),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final double cornerLength;
  final double cornerWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const _Corner({
    required this.cornerLength,
    required this.cornerWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cornerLength,
      height: cornerLength,
      child: CustomPaint(
        painter: _CornerPainter(
          width: cornerWidth,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double width;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  _CornerPainter({
    required this.width,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (topLeft) {
      canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    } else if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
    } else if (bottomLeft) {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    } else if (bottomRight) {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Check-in bottom sheet
// ---------------------------------------------------------------------------

class _CheckInSheet extends ConsumerStatefulWidget {
  final String qrCode;
  final VoidCallback onDone;

  const _CheckInSheet({required this.qrCode, required this.onDone});

  @override
  ConsumerState<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<_CheckInSheet> {
  String _selectedService = _services.keys.first;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: (_services[_selectedService]! / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onServiceChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedService = value;
      _amountController.text =
          (_services[value]! / 100).toStringAsFixed(2);
    });
  }

  Future<void> _submit() async {
    final amountDollars = double.tryParse(_amountController.text);
    if (amountDollars == null || amountDollars <= 0) return;

    final amountCents = (amountDollars * 100).round();

    await ref.read(checkInProvider.notifier).performCheckIn(
          qrCode: widget.qrCode,
          serviceName: _selectedService,
          amountCents: amountCents,
        );
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: checkInState.result != null
          ? _buildSuccess(checkInState.result!)
          : checkInState.error != null
              ? _buildError(checkInState.error!)
              : _buildForm(checkInState.isLoading),
    );
  }

  // -----------------------------------------------------------------------
  // Form view
  // -----------------------------------------------------------------------
  Widget _buildForm(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Check In Customer', style: AppTypography.titleMedium),
          const SizedBox(height: 20),

          // Service dropdown
          Text('Service', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedService,
              onChanged: _onServiceChanged,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              dropdownColor: AppColors.surface,
              style: AppTypography.bodyMedium,
              items: _services.keys
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Amount field
          Text('Amount (\$)', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.matte,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
                prefixText: '\$ ',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.matte,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Check In', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Success view
  // -----------------------------------------------------------------------
  Widget _buildSuccess(Map<String, dynamic> result) {
    final customerName = result['customer_name'] as String? ?? 'Customer';
    final pointsAwarded = result['points_earned'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Animated checkmark
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fade(duration: 200.ms),
          const SizedBox(height: 20),

          Text('Check-in Successful', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            customerName,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 12),
          Text(
            '+$pointsAwarded pts',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(checkInProvider.notifier).reset();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.matte,
                side: const BorderSide(color: AppColors.matte),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Scan Next', style: AppTypography.labelLarge),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Error view
  // -----------------------------------------------------------------------
  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),

          Text('Check-in Failed', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(checkInProvider.notifier).reset();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.matte,
                side: const BorderSide(color: AppColors.matte),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Try Again', style: AppTypography.labelLarge),
            ),
          ),
        ],
      ),
    );
  }
}
