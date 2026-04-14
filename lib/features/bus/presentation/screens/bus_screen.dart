import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/sams_state_views.dart';
import '../../data/repositories/fake_bus_repository.dart';
import '../bloc/bus_bloc.dart';

class BusScreen extends StatelessWidget {
  const BusScreen({super.key});

  Future<void> _refreshBus(BuildContext context) async {
    final bloc = context.read<BusBloc>();
    bloc.add(const BusRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != BusStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BusBloc(repository: FakeBusRepository())..add(const BusRequested()),
      child: BlocBuilder<BusBloc, BusState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.snapshot != current.snapshot ||
              previous.routeStops != current.routeStops ||
              previous.liveInfo != current.liveInfo ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          if (state.status == BusStatus.initial ||
              state.status == BusStatus.loading) {
            return const _BusLoadingSkeleton();
          }

          if (state.status == BusStatus.failure || !state.hasData) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: AppBar(
                title: const Text('Bus Tracking'),
                centerTitle: true,
              ),
              body: SamsErrorState(
                title: 'Couldn\'t load bus tracking',
                message:
                    state.errorMessage ??
                    'Failed to load bus tracking. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<BusBloc>().add(const BusRequested()),
              ),
            );
          }

          final snapshot = state.snapshot!;
          final liveInfo = state.liveInfo!;
          final routeStops = state.routeStops;
          final screenWidth = MediaQuery.sizeOf(context).width;
          final mapHeight = screenWidth < 360 ? 250.0 : 300.0;
          final statusColor = state.isInCampus
              ? SamsUiTokens.success
              : const Color(0xFFCC2D2D);

          return Scaffold(
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: AppBar(
              title: const Text('Bus Tracking'),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () => _refreshBus(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: SamsUiTokens.pageInsets(
                    context,
                    top: 10,
                    bottom: 22,
                    regularHorizontal: 12,
                    compactHorizontal: 10,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 8),
                      child: Text(
                        'Live Route',
                        style: TextStyle(
                          color: SamsUiTokens.primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      height: mapHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE6F0F8), Color(0xFFDDEAF5)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: CustomPaint(
                                painter: _MapPlaceholderPainter(),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 12,
                            top: 12,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.menu,
                                size: 18,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                color: Color(0x1AFF3B30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFEF3D3D),
                                size: 38,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    size: 16,
                                    color: SamsUiTokens.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Next stop: ${liveInfo.nextStop} • ETA ${liveInfo.eta}',
                                      style: const TextStyle(
                                        fontSize: 12.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: SamsUiTokens.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monday, Sept 1',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 18,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  liveInfo.routeSummary,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                const Text(
                                  'Current Status: ',
                                  style: TextStyle(
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  snapshot.currentStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Current stop: ${snapshot.currentStop} • ${liveInfo.lastUpdated}',
                              style: const TextStyle(
                                color: SamsUiTokens.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: Column(
                        children: List.generate(routeStops.length, (index) {
                          final row = routeStops[index];
                          final stopNumber = (index + 1).toString().padLeft(
                            2,
                            '0',
                          );
                          final isCurrent = row.status == 'Current';

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == routeStops.length - 1 ? 0 : 8,
                            ),
                            child: SamsPressable(
                              borderRadius: BorderRadius.circular(
                                SamsUiTokens.radiusLg,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    SamsUiTokens.radiusLg,
                                  ),
                                  boxShadow: SamsUiTokens.cardShadow,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? statusColor
                                                : SamsUiTokens.primary
                                                      .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            stopNumber,
                                            style: TextStyle(
                                              color: isCurrent
                                                  ? Colors.white
                                                  : SamsUiTokens.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 2,
                                          height: 32,
                                          color: const Color(0xFFD6DFEA),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            row.stop,
                                            style: const TextStyle(
                                              color: Color(0xFF111827),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            row.status,
                                            style: TextStyle(
                                              color: isCurrent
                                                  ? statusColor
                                                  : const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      row.time,
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFBFD2E3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFD2E0EC)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final parkPaint = Paint()..color = const Color(0xFFBDE7C9);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.24, size.height * 0.30),
        width: 92,
        height: 64,
      ),
      parkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.77, size.height * 0.68),
        width: 80,
        height: 56,
      ),
      parkPaint,
    );

    final mainPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.1,
        size.width * 0.62,
        size.height * 0.26,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.38,
        size.width * 0.92,
        size.height * 0.34,
      );
    canvas.drawPath(mainPath, roadPaint);

    final mainPath2 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.56,
        size.width * 0.92,
        size.height * 0.78,
      );
    canvas.drawPath(mainPath2, roadPaint);

    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.36, size.height),
      thinRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.58, size.height),
      thinRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.46),
      Offset(size.width, size.height * 0.42),
      thinRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BusLoadingSkeleton extends StatelessWidget {
  const _BusLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(title: const Text('Bus Tracking'), centerTitle: true),
      body: ListView(
        padding: SamsUiTokens.pageInsets(
          context,
          top: 10,
          bottom: 22,
          regularHorizontal: 12,
          compactHorizontal: 10,
        ),
        children: [
          const SamsLoadingView(
            title: 'Loading your bus tracking...',
            message: 'Syncing live bus location, route stops, and ETA...',
          ),
          const SizedBox(height: 8),
          const ShimmerWidget(
            height: 280,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          const SizedBox(height: 12),
          const ShimmerWidget(
            height: 110,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 3 ? 0 : 8),
              child: const _BusTimelineShimmerRow(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusTimelineShimmerRow extends StatelessWidget {
  const _BusTimelineShimmerRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: SamsUiTokens.cardShadow,
      ),
      child: Row(
        children: const [
          ShimmerWidget.circle(size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget.line(height: 12, width: 140),
                SizedBox(height: 7),
                ShimmerWidget.line(height: 10, width: 90),
              ],
            ),
          ),
          SizedBox(width: 10),
          ShimmerWidget.line(height: 12, width: 52),
        ],
      ),
    );
  }
}
