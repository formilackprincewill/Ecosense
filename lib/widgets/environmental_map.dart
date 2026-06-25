import 'package:flutter/material.dart';
import 'dart:math';

class EnvironmentalMap extends StatefulWidget {
  const EnvironmentalMap({super.key});

  @override
  State<EnvironmentalMap> createState() => _EnvironmentalMapState();
}

class _EnvironmentalMapState extends State<EnvironmentalMap> {
  final List<DataPoint> _dataPoints = [];

  @override
  void initState() {
    super.initState();
    _generateSampleData();
  }

  void _generateSampleData() {
    final random = Random();

    // Generate sample environmental data points
    for (int i = 0; i < 15; i++) {
      _dataPoints.add(
        DataPoint(
          x: random.nextDouble() * 300 + 50,
          y: random.nextDouble() * 200 + 50,
          type: DataType.values[random.nextInt(DataType.values.length)],
          value: random.nextDouble() * 100,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background map pattern
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: CustomPaint(painter: _MapPatternPainter()),
            ),

            // Data points
            ..._dataPoints.map((point) => _buildDataPoint(context, point)),

            // Legend
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(context, 'Noise', DataType.noise),
                    const SizedBox(width: 12),
                    _buildLegendItem(context, 'Light', DataType.light),
                    const SizedBox(width: 12),
                    _buildLegendItem(context, 'Air', DataType.air),
                  ],
                ),
              ),
            ),

            // Overlay with tap to zoom message
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to zoom',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(BuildContext context, DataPoint point) {
    return Positioned(
      left: point.x,
      top: point.y,
      child: GestureDetector(
        onTap: () {
          _showDataPointDetails(context, point);
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getColorForDataType(point.type),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: _getColorForDataType(point.type).withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _getIconForDataType(point.type),
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, DataType type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getColorForDataType(type),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getColorForDataType(DataType type) {
    switch (type) {
      case DataType.noise:
        return const Color(0xFF9C27B0); // Purple
      case DataType.light:
        return const Color(0xFFFFEB3B); // Yellow
      case DataType.air:
        return const Color(0xFF4CAF50); // Green
    }
  }

  IconData _getIconForDataType(DataType type) {
    switch (type) {
      case DataType.noise:
        return Icons.graphic_eq;
      case DataType.light:
        return Icons.wb_sunny;
      case DataType.air:
        return Icons.air;
    }
  }

  void _showDataPointDetails(BuildContext context, DataPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForDataType(point.type),
              color: _getColorForDataType(point.type),
            ),
            const SizedBox(width: 8),
            Text(_getDataTypeName(point.type)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Value: ${point.value.toStringAsFixed(1)} ${_getUnit(point.type)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${point.x.toStringAsFixed(1)}, ${point.y.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Collected: ${DateTime.now().subtract(Duration(minutes: Random().nextInt(60))).toString().split('.')[0]}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getDataTypeName(DataType type) {
    switch (type) {
      case DataType.noise:
        return 'Noise Level';
      case DataType.light:
        return 'Light Level';
      case DataType.air:
        return 'Air Quality';
    }
  }

  String _getUnit(DataType type) {
    switch (type) {
      case DataType.noise:
        return 'dB';
      case DataType.light:
        return 'lux';
      case DataType.air:
        return 'AQI';
    }
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DataPoint {
  final double x;
  final double y;
  final DataType type;
  final double value;

  DataPoint({
    required this.x,
    required this.y,
    required this.type,
    required this.value,
  });
}

enum DataType { noise, light, air }
