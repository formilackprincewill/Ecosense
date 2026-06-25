// lib/models/analytics_models.dart

class AnalyticsResult {
  final int totalRecords;
  final MetricSummary noise;
  final MetricSummary light;
  final MetricSummary pressure;
  final PredictionResult predictions;
  final List<LocationGroup> locationInsights;

  AnalyticsResult({
    required this.totalRecords,
    required this.noise,
    required this.light,
    required this.pressure,
    required this.predictions,
    required this.locationInsights,
  });

  factory AnalyticsResult.fromJson(Map<String, dynamic> json) {
    return AnalyticsResult(
      totalRecords: json['totalRecords'] ?? json['total_records'] ?? 0,
      noise: MetricSummary.fromJson(json['noise'] ?? {}),
      light: MetricSummary.fromJson(json['light'] ?? {}),
      pressure: MetricSummary.fromJson(json['pressure'] ?? {}),
      predictions: PredictionResult.fromJson(json['predictions'] ?? {}),
      locationInsights: (json['locationInsights'] ?? json['location_insights'] as List?)
              ?.map((item) => LocationGroup.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalRecords': totalRecords,
        'noise': noise.toJson(),
        'light': light.toJson(),
        'pressure': pressure.toJson(),
        'predictions': predictions.toJson(),
        'locationInsights': locationInsights.map((e) => e.toJson()).toList(),
      };
}

class MetricSummary {
  final double average;
  final double min;
  final double max;

  MetricSummary({
    required this.average,
    required this.min,
    required this.max,
  });

  factory MetricSummary.fromJson(Map<String, dynamic> json) {
    return MetricSummary(
      average: (json['average'] ?? 0.0).toDouble(),
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'average': average,
        'min': min,
        'max': max,
      };
}

class PredictionResult {
  final double nextNoise;
  final double nextLight;
  final double nextPressure;
  final String noiseTrend; // "Increasing", "Decreasing", or "Stable"
  final String lightTrend;
  final String pressureTrend;

  PredictionResult({
    required this.nextNoise,
    required this.nextLight,
    required this.nextPressure,
    required this.noiseTrend,
    required this.lightTrend,
    required this.pressureTrend,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      nextNoise: (json['nextNoise'] ?? json['next_noise'] ?? 0.0).toDouble(),
      nextLight: (json['nextLight'] ?? json['next_light'] ?? 0.0).toDouble(),
      nextPressure: (json['nextPressure'] ?? json['next_pressure'] ?? 0.0).toDouble(),
      noiseTrend: json['noiseTrend'] ?? json['noise_trend'] ?? 'Stable',
      lightTrend: json['lightTrend'] ?? json['light_trend'] ?? 'Stable',
      pressureTrend: json['pressureTrend'] ?? json['pressure_trend'] ?? 'Stable',
    );
  }

  Map<String, dynamic> toJson() => {
        'nextNoise': nextNoise,
        'nextLight': nextLight,
        'nextPressure': nextPressure,
        'noiseTrend': noiseTrend,
        'lightTrend': lightTrend,
        'pressureTrend': pressureTrend,
      };
}

class LocationGroup {
  final String coordinates; // The lat,long string
  final String readableAddress; // "Cameroon, Buea, Mayor Street"
  final double avgNoise;
  final double avgLight;
  final double avgPressure;
  final int recordCount;
  final String noiseTrend;
  final String lightTrend;
  final String pressureTrend;

  LocationGroup({
    required this.coordinates,
    required this.readableAddress,
    required this.avgNoise,
    required this.avgLight,
    required this.avgPressure,
    required this.recordCount,
    required this.noiseTrend,
    required this.lightTrend,
    required this.pressureTrend,
  });

  factory LocationGroup.fromJson(Map<String, dynamic> json) {
    return LocationGroup(
      coordinates: json['coordinates'] ?? '',
      readableAddress: json['readableAddress'] ?? json['readable_address'] ?? 'Unknown Location',
      avgNoise: (json['avgNoise'] ?? json['avg_noise'] ?? 0.0).toDouble(),
      avgLight: (json['avgLight'] ?? json['avg_light'] ?? 0.0).toDouble(),
      avgPressure: (json['avgPressure'] ?? json['avg_pressure'] ?? 0.0).toDouble(),
      recordCount: json['recordCount'] ?? json['record_count'] ?? 0,
      noiseTrend: json['noiseTrend'] ?? json['noise_trend'] ?? 'Stable',
      lightTrend: json['lightTrend'] ?? json['light_trend'] ?? 'Stable',
      pressureTrend: json['pressureTrend'] ?? json['pressure_trend'] ?? 'Stable',
    );
  }

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates,
        'readableAddress': readableAddress,
        'avgNoise': avgNoise,
        'avgLight': avgLight,
        'avgPressure': avgPressure,
        'recordCount': recordCount,
        'noiseTrend': noiseTrend,
        'lightTrend': lightTrend,
        'pressureTrend': pressureTrend,
      };
}