import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'machine_models.dart';

/// Machine card overlay that floats above the map at the machine's coordinates.
///
/// UX:
/// - Unselected: dot + card with ONLY machine name.
/// - Selected: card expands slightly, shows icon (left) + name + location (below).
/// - No buttons in the card.
class MachineCardOverlay extends StatefulWidget {
  final VendingMachine machine;
  final MapLibreMapController? controller;
  final ValueListenable<int> cameraTickListenable;
  final bool isSelected;
  final VoidCallback onTap;

  const MachineCardOverlay({
    required this.machine,
    required this.controller,
    required this.cameraTickListenable,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  State<MachineCardOverlay> createState() => _MachineCardOverlayState();
}

class _MachineCardOverlayState extends State<MachineCardOverlay> {
  Offset? _screenPosition;
  bool _retryScheduled = false;

  void _onCameraTick() {
    _requestUpdate();
  }

  @override
  void initState() {
    super.initState();
    widget.cameraTickListenable.addListener(_onCameraTick);
    _updateScreenPosition();
  }

  @override
  void dispose() {
    widget.cameraTickListenable.removeListener(_onCameraTick);
    super.dispose();
  }

  @override
  void didUpdateWidget(MachineCardOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cameraTickListenable != widget.cameraTickListenable) {
      oldWidget.cameraTickListenable.removeListener(_onCameraTick);
      widget.cameraTickListenable.addListener(_onCameraTick);
    }

    if (oldWidget.controller != widget.controller ||
        oldWidget.machine.id != widget.machine.id) {
      _requestUpdate();
    }
  }

  void _requestUpdate() {
    // Always update immediately - don't block on _isUpdating flag
    // This ensures real-time tracking during continuous camera movement
    _updateScreenPosition();
  }

  Future<void> _updateScreenPosition() async {
    final controller = widget.controller;
    if (controller == null || !widget.machine.hasCoordinates) return;

    Offset? next;
    try {
      final latLng = LatLng(widget.machine.lat!, widget.machine.lng!);
      final point = await controller.toScreenLocation(latLng);

      // Some MapLibre builds return physical pixels here.
      // Our Flutter layout uses logical pixels, so adapt if needed.
      final raw = Offset(point.x.toDouble(), point.y.toDouble());
      final media = MediaQuery.maybeOf(context);
      if (media == null) {
        next = raw;
      } else {
        final size = media.size;
        final dpr = media.devicePixelRatio;
        final looksLikePhysical =
            raw.dx > size.width + 50 || raw.dy > size.height + 50;
        next = looksLikePhysical ? raw / dpr : raw;
      }

      // Reset retry gate once we successfully computed a position.
      _retryScheduled = false;
    } catch (_) {
      // Style/camera may not be ready yet; keep last known position.
    }

    if (!mounted) return;

    if (next != null) {
      final prev = _screenPosition;
      // Allow real-time updates - update every time position changes by > 0.5px
      // This ensures smooth tracking without excessive rebuilds
      if (prev == null || (prev - next).distance > 0.5) {
        setState(() => _screenPosition = next);
      }
    } else {
      // If we never got an initial position, retry multiple times with increasing delays
      if (_screenPosition == null && !_retryScheduled) {
        _retryScheduled = true;
        // Try 3 times: 50ms, 150ms, 300ms
        for (var delay in [50, 150, 300]) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted && _screenPosition == null) {
              _retryScheduled = false;
              _requestUpdate();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _screenPosition;
    if (p == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isExpanded = widget.isSelected;

    return Positioned(
      left: p.dx,
      top: p.dy,
      child: FractionalTranslation(
        // Anchor the triangle tip (bottom-center) at the map coordinate.
        translation: const Offset(-0.5, -1.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                constraints: BoxConstraints(
                  minWidth: isExpanded ? 165 : 125,
                  maxWidth: isExpanded ? 225 : 175,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 12 : 10,
                  vertical: isExpanded ? 10 : 7,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isExpanded
                        ? [scheme.primaryContainer, scheme.secondaryContainer]
                        : [scheme.surface, scheme.surfaceContainerHighest],
                  ),
                  borderRadius: BorderRadius.circular(isExpanded ? 15 : 11),
                  border: Border.all(
                    color: isExpanded
                        ? scheme.primary
                        : scheme.outline.withOpacity(0.5),
                    width: isExpanded ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isExpanded ? scheme.primary : Colors.black)
                          .withOpacity(isExpanded ? 0.3 : 0.15),
                      blurRadius: isExpanded ? 14 : 7,
                      spreadRadius: isExpanded ? 0.5 : 0,
                      offset: Offset(0, isExpanded ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isExpanded)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              Icons.store,
                              size: 16,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              widget.machine.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: scheme.onPrimaryContainer,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        widget.machine.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (isExpanded &&
                        widget.machine.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: scheme.onSecondaryContainer.withOpacity(0.7),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              widget.machine.location,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: scheme.onSecondaryContainer
                                        .withOpacity(0.85),
                                    fontSize: 10.5,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              CustomPaint(
                size: Size(isExpanded ? 18 : 13, isExpanded ? 9 : 6.5),
                painter: _TrianglePainter(
                  fillColor: isExpanded
                      ? scheme.secondaryContainer
                      : scheme.surfaceContainerHighest,
                  borderColor: isExpanded
                      ? scheme.primary
                      : scheme.outline.withOpacity(0.5),
                  borderWidth: isExpanded ? 2.5 : 1.5,
                ),
              ),

              // Machine dot is rendered as a MapLibre circle annotation.
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  _TrianglePainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
