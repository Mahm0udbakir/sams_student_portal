import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_state_views.dart';
import '../../data/repositories/fake_bus_repository.dart';
import '../bloc/bus_bloc.dart';

class BusScreen extends StatelessWidget {
  const BusScreen({super.key});

  Future<void> _refreshBus(BuildContext context) async {
    final bloc = context.read<BusBloc>();
    bloc.add(const BusRequested());
    await bloc.stream.firstWhere((state) => state.status != BusStatus.loading);
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusBloc(repository: FakeBusRepository())..add(const BusRequested()),
      child: BlocBuilder<BusBloc, BusState>(
        builder: (context, state) {
          if (state.status == BusStatus.initial || state.status == BusStatus.loading) {
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
                    state.errorMessage ?? 'Failed to load bus tracking. Please try again.',
                retryLabel: 'Retry',
                onRetry: () => context.read<BusBloc>().add(const BusRequested()),
              ),
            );
          }

          final snapshot = state.snapshot!;
          final liveInfo = state.liveInfo!;
          final routeStops = state.routeStops;
          final screenWidth = MediaQuery.sizeOf(context).width;
          final mapHeight = screenWidth < 360 ? 250.0 : 300.0;
          final statusColor = state.isInCampus ? SamsUiTokens.success : const Color(0xFFCC2D2D);

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
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
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
                        colors: [
                          Color(0xFFE6F0F8),
                          Color(0xFFDDEAF5),
                        ],
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
                            child: Icon(Icons.menu, size: 18, color: Color(0xFF4B5563)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.map_outlined, size: 16, color: Color(0xFF063454)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Next stop: ${liveInfo.nextStop} • ETA ${liveInfo.eta}',
                                    style: const TextStyle(fontSize: 12.2, fontWeight: FontWeight.w600),
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                              const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF6B7280)),
                              const SizedBox(width: 6),
                              Text(
                                liveInfo.routeSummary,
                                style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                        boxShadow: SamsUiTokens.cardShadow,
                      ),
                      child: Column(
                        children: List.generate(routeStops.length, (index) {
                          final row = routeStops[index];
                          final stopNumber = (index + 1).toString().padLeft(2, '0');
                          final isCurrent = row.status == 'Current';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                            : const Color(0xFF063454).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        stopNumber,
                                        style: TextStyle(
                                          color: isCurrent ? Colors.white : const Color(0xFF063454),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    if (index != routeStops.length - 1)
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: isCurrent ? statusColor : const Color(0xFF6B7280),
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
                          );
                        }),
                      ),
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
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.1, size.width * 0.62, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.38, size.width * 0.92, size.height * 0.34);
    canvas.drawPath(mainPath, roadPaint);

    final mainPath2 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.56, size.width * 0.92, size.height * 0.78);
    canvas.drawPath(mainPath2, roadPaint);

    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.36, size.height), thinRoadPaint);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.58, size.height), thinRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.46), Offset(size.width, size.height * 0.42), thinRoadPaint);
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
      appBar: AppBar(
        title: const Text('Bus Tracking'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
        children: const [
          SamsLoadingView(
            title: 'Loading live route',
            message: 'Syncing bus location, stops and arrival times...',
          ),
          SizedBox(height: 8),
          SamsSkeletonBox(height: 280, radius: 22),
          SizedBox(height: 12),
          SamsSkeletonBox(height: 110, radius: 20),
          SizedBox(height: 12),
          SamsSkeletonBox(height: 66, radius: 16),
          SizedBox(height: 8),
          SamsSkeletonBox(height: 66, radius: 16),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

class BusScreen extends StatelessWidget {
  const BusScreen({super.key});

  static const Color _samsPrimary = Color(0xFF063454);

  @override
  Widget build(BuildContext context) {
    final routeStops = const [
  (stop: 'SAMS University', time: '9:15am', status: 'Current'),
      (stop: 'Zirakpur Lights', time: '8:45am', status: 'Passed'),
      (stop: 'Elante Lights', time: '8:30am', status: 'Passed'),
      (stop: 'Sector 28', time: '8:20am', status: 'Origin'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text('Bus Tracking'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          children: [
            Text(
              'Live Route',
              style: TextStyle(
                color: _samsPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 255,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE6F0F8),
                    Color(0xFFDDEAF5),
                  ],
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
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: _MapPlaceholderPainter(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.map_outlined, size: 16, color: Color(0xFF063454)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Map Placeholder • Bus location shown in real-time',
                              style: TextStyle(fontSize: 12.2, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
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
                      const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        'Duration: 55 min',
                        style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.route_rounded, size: 18, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        '4 Stops • 14.2 km',
                        style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Row(
                    children: [
                      Text(
                        'Current Status: ',
                        style: TextStyle(
                          Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: row.status == 'Current'
                                      ? const Color(0xFFCC2D2D)
                                      : const Color(0xFF063454).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  stopNumber,
                                  style: TextStyle(
                                    color: row.status == 'Current' ? Colors.white : const Color(0xFF063454),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              if (index != routeStops.length - 1)
                                Container(
                                  width: 2,
                                  height: 32,
                                  color: const Color(0xFFD6DFEA),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                        ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: row.status == 'Current' ? const Color(0xFFCC2D2D) : const Color(0xFF6B7280),
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
                    );
                  }),
                ),
              ),
            ],
          ),
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

      // Curved and straight roads to mimic a map look.
      final mainPath = Path()
        ..moveTo(size.width * 0.1, size.height * 0.2)
        ..quadraticBezierTo(size.width * 0.38, size.height * 0.1, size.width * 0.62, size.height * 0.26)
        ..quadraticBezierTo(size.width * 0.8, size.height * 0.38, size.width * 0.92, size.height * 0.34);
      canvas.drawPath(mainPath, roadPaint);

      final mainPath2 = Path()
        ..moveTo(size.width * 0.08, size.height * 0.72)
        ..quadraticBezierTo(size.width * 0.42, size.height * 0.56, size.width * 0.92, size.height * 0.78);
      canvas.drawPath(mainPath2, roadPaint);

      canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.36, size.height), thinRoadPaint);
      canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.58, size.height), thinRoadPaint);
      canvas.drawLine(Offset(0, size.height * 0.46), Offset(size.width, size.height * 0.42), thinRoadPaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
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

    // Curved and straight roads to mimic a map look.
    final mainPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.1, size.width * 0.62, size.height * 0.26)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.38, size.width * 0.92, size.height * 0.34);
    canvas.drawPath(mainPath, roadPaint);

    final mainPath2 = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.56, size.width * 0.92, size.height * 0.78);
    canvas.drawPath(mainPath2, roadPaint);

    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.36, size.height), thinRoadPaint);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.58, size.height), thinRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.46), Offset(size.width, size.height * 0.42), thinRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/
