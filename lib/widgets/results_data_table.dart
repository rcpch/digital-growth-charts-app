import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/digital_growth_charts_api_response.dart';
import '../definitions/enums.dart';

/// Column widths are fixed and shared between the pinned header and every card
/// row. This is the thing that makes the list read as a table: if the widths
/// were intrinsic, each card would size its columns independently and they
/// would drift apart down the list.
///
/// The widths scale with the platform text scale so the layout survives
/// accessibility settings, but are clamped so very large scales don't squeeze
/// the measure name to nothing.
abstract final class GrowthListMetrics {
  static const double valueColumnBase = 74;
  static const double centileColumnBase = 54;
  static const double sdsColumnBase = 52;

  static const double columnGap = 8;
  static const double cardInset = 12;
  static const double cardPadding = 12;
  static const double cardRadius = 12;

  /// Horizontal inset needed to align the pinned header with the card columns.
  static const double headerInset = cardInset + cardPadding;

  static double scaled(BuildContext context, double base) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return base * scale;
  }

  static double valueColumn(BuildContext c) => scaled(c, valueColumnBase);
  static double centileColumn(BuildContext c) => scaled(c, centileColumnBase);
  static double sdsColumn(BuildContext c) => scaled(c, sdsColumnBase);
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

/// Whole centiles in the middle of the range, one decimal place in the tails
/// where whole numbers stop being informative, and an explicit bound beyond
/// the outermost plotted centiles. Returns '—' for a missing value so the
/// column layout still holds.
String formatCentile(double? centile) {
  if (centile == null) return '—';
  if (centile < 0.4) return '<0.4th';
  if (centile > 99.6) return '>99.6th';
  if (centile < 1 || centile > 99) return '${centile.toStringAsFixed(1)}th';
  final rounded = centile.round();
  return '$rounded${_ordinalSuffix(rounded)}';
}

String _ordinalSuffix(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return 'th';
  return switch (n % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}

/// Uses a true minus sign (U+2212) rather than a hyphen. In a font with
/// tabular figures enabled the minus matches the digit width; a hyphen
/// usually doesn't, and the column stops lining up. Returns '—' for a
/// missing value.
String formatSds(double? sds) {
  if (sds == null) return '—';
  final magnitude = sds.abs().toStringAsFixed(2);
  if (sds > 0.005) return '+$magnitude';
  if (sds < -0.005) return '\u2212$magnitude';
  return '0.00';
}

String _spokenSds(double sds) {
  final magnitude = sds.abs().toStringAsFixed(2);
  if (sds > 0.005) return 'plus $magnitude';
  if (sds < -0.005) return 'minus $magnitude';
  return 'zero';
}

/// Display metadata for [MeasurementMethod], which the native enum doesn't
/// carry itself. Kept here so the table can format values like the example
/// without altering the enum or the API models.
extension MeasurementMethodPresentation on MeasurementMethod {
  String get label => switch (this) {
    MeasurementMethod.height => 'Height',
    MeasurementMethod.weight => 'Weight',
    MeasurementMethod.ofc => 'Head circ.',
    MeasurementMethod.bmi => 'BMI',
  };

  String? get unit => switch (this) {
    MeasurementMethod.height || MeasurementMethod.ofc => 'cm',
    MeasurementMethod.weight => 'kg',
    MeasurementMethod.bmi => null,
  };

  int get decimals => 1;
}

/// A [GrowthDataResponse] tagged with the [MeasurementMethod] it was stored
/// under. The method is the map key in `organizedGrowthData`, so we carry it
/// through the grouping rather than re-reading the `measurement_method` string
/// on the response (which may be null).
typedef _TaggedMeasurement = ({
  MeasurementMethod method,
  GrowthDataResponse response,
});

/// One date's worth of measurements, grouped for display. Wraps native
/// [GrowthDataResponse]s rather than replacing them.
class _MeasurementOccasion {
  _MeasurementOccasion({
    required this.sortKey,
    required this.dateLabel,
    required this.ageLabel,
    this.correctedAgeLabel,
    this.correctedAgeComment,
    required this.measurements,
  });

  /// The raw observation-date string, used only for sorting. ISO dates sort
  /// lexically; empty when the date was missing, so those occasions fall last.
  final String sortKey;

  final String dateLabel;
  final String ageLabel;
  final String? correctedAgeLabel;
  final String? correctedAgeComment;
  final List<_TaggedMeasurement> measurements;

  String get dateSummary => dateLabel.isEmpty ? 'Unknown date' : dateLabel;

  /// Age to show on the card header, honouring the page's age-correction
  /// selection. Corrected age falls back to chronological when it wasn't
  /// computed (e.g. term child), so the header never reads "Unknown age".
  String displayAge(AgeCorrectionMethod method) {
    switch (method) {
      case AgeCorrectionMethod.corrected:
        return correctedAgeLabel?.isNotEmpty == true
            ? correctedAgeLabel!
            : ageLabel;
      case AgeCorrectionMethod.both:
      case AgeCorrectionMethod.chronological:
        return ageLabel;
    }
  }
}

// ---------------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------------

class ResultsDataTable extends StatelessWidget {
  /// Measurements keyed by method, as produced by [AppState]. The table
  /// regroups them by observation date for display.
  final Map<MeasurementMethod, List<GrowthDataResponse>> organizedGrowthData;

  /// Which age the card header should show: the chronological age, the
  /// corrected age (falling back to chronological when there's no
  /// correction), or both. Mirrors the toggle in [ResultsPage]'s header
  /// dialog.
  final AgeCorrectionMethod ageCorrectionMethod;

  const ResultsDataTable({
    super.key,
    required this.organizedGrowthData,
    this.ageCorrectionMethod = AgeCorrectionMethod.chronological,
  });

  @override
  Widget build(BuildContext context) {
    final occasions = _groupOccasions(organizedGrowthData);
    if (occasions.isEmpty) return const _EmptyState();

    return CustomScrollView(
      slivers: [
        const SliverPersistentHeader(
          pinned: true,
          delegate: _ColumnHeaderDelegate(),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList.builder(
            itemCount: occasions.length,
            itemBuilder: (context, index) {
              final occasion = occasions[index];
              return _OccasionCard(
                occasion: occasion,
                ageCorrectionMethod: ageCorrectionMethod,
                onTap: () => _showDetailsModal(context, occasion),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Flattens the method-keyed map and regroups by `observation_date`. Most
/// recent date first; occasions with a missing date sort last.
List<_MeasurementOccasion> _groupOccasions(
  Map<MeasurementMethod, List<GrowthDataResponse>> data,
) {
  final byDate = <String, List<_TaggedMeasurement>>{};
  for (final entry in data.entries) {
    final method = entry.key;
    for (final response in entry.value) {
      final key = response.measurementDates?.observationDate ?? '';
      (byDate[key] ??= <_TaggedMeasurement>[]).add((
        method: method,
        response: response,
      ));
    }
  }

  final occasions = <_MeasurementOccasion>[];
  for (final entry in byDate.entries) {
    final dates = entry.value.first.response.measurementDates;
    occasions.add(
      _MeasurementOccasion(
        sortKey: entry.key,
        dateLabel: _formatDate(dates?.observationDate),
        ageLabel: _abbreviateAge(dates?.chronologicalCalendarAge ?? ''),
        correctedAgeLabel: _abbreviateAge(dates?.correctedCalendarAge ?? ''),
        correctedAgeComment:
            dates?.comments?.clinicianCorrectedDecimalAgeComment,
        measurements: entry.value,
      ),
    );
  }

  occasions.sort((a, b) => b.sortKey.compareTo(a.sortKey));
  return occasions;
}

String _formatDate(String? observationDate) {
  if (observationDate == null || observationDate.isEmpty) {
    return 'Unknown date';
  }
  final parsed = DateTime.tryParse(observationDate);
  if (parsed == null) return observationDate;
  return DateFormat.yMMMd().format(parsed);
}

/// Compacts a RCPCH calendar-age string for use as a card title.
///
/// The API returns ages like `"18 years, 11 months, 3 weeks and 5 days"`,
/// which is accurate but too wide to lead a card with. This rewrites each
/// unit to its initial and glues it to its number, so the same age reads
/// `18y, 11m, 3w & 5d`. Unparseable input is returned untouched.
String _abbreviateAge(String age) {
  if (age.isEmpty) return age;
  // number, optional spaces, unit word → number + unit initial
  var out = age.replaceAllMapped(
    RegExp(r'(\d+)\s*\b(year|month|week|day)s?\b'),
    (m) => '${m[1]}${m[2]![0]}',
  );
  // tidy the remaining punctuation
  out = out.replaceAll(RegExp(r',\s*'), ', ');
  out = out.replaceAll(RegExp(r'\s+and\s+'), ' & ');
  return out;
}

String _formatValue(MeasurementMethod method, double? value) {
  if (value == null) return '—';
  final v = value.toStringAsFixed(method.decimals);
  final unit = method.unit;
  return unit == null ? v : '$v $unit';
}

String _semanticsLabel(
  MeasurementMethod method,
  double? value,
  MeasurementCalculatedValues? values,
) {
  final unit = method.unit;
  final valuePart = value == null
      ? 'no value'
      : unit == null
      ? value.toStringAsFixed(method.decimals)
      : '${value.toStringAsFixed(method.decimals)} $unit';
  final centile = values?.chronologicalCentile;
  final sds = values?.chronologicalSds;
  return '${method.label}, $valuePart, '
      '${centile == null ? 'no centile' : '${formatCentile(centile)} centile'}, '
      '${sds == null ? 'no SDS' : '${_spokenSds(sds)} SDS'}';
}

// ---------------------------------------------------------------------------
// Pinned header
// ---------------------------------------------------------------------------

/// Pinned so the column labels stay visible while scrolling — without them the
/// bare numbers lose their meaning a screen or two down.
class _ColumnHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ColumnHeaderDelegate();

  static const double _height = 34;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Container(
      height: _height,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: GrowthListMetrics.headerInset,
      ),
      alignment: Alignment.bottomCenter,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Spacer(),
              _cell(context, 'Value', GrowthListMetrics.valueColumn, style),
              const SizedBox(width: GrowthListMetrics.columnGap),
              _cell(context, 'Centile', GrowthListMetrics.centileColumn, style),
              const SizedBox(width: GrowthListMetrics.columnGap),
              _cell(context, 'SDS', GrowthListMetrics.sdsColumn, style),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _cell(
    BuildContext context,
    String text,
    double Function(BuildContext) width,
    TextStyle? style,
  ) {
    return SizedBox(
      width: width(context),
      child: Text(text, textAlign: TextAlign.end, style: style, maxLines: 1),
    );
  }

  @override
  bool shouldRebuild(covariant _ColumnHeaderDelegate oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

class _OccasionCard extends StatelessWidget {
  const _OccasionCard({
    required this.occasion,
    required this.ageCorrectionMethod,
    this.onTap,
  });

  final _MeasurementOccasion occasion;
  final AgeCorrectionMethod ageCorrectionMethod;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GrowthListMetrics.cardInset,
        vertical: 5,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrowthListMetrics.cardRadius),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GrowthListMetrics.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OccasionHeader(
                  ageLabel: occasion.displayAge(ageCorrectionMethod),
                  dateSummary: occasion.dateSummary,
                  showChevron: onTap != null,
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(height: 4),
                for (final measurement in occasion.measurements)
                  _MeasurementRow(measurement: measurement),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OccasionHeader extends StatelessWidget {
  const _OccasionHeader({
    required this.ageLabel,
    required this.dateSummary,
    required this.showChevron,
  });

  final String ageLabel;
  final String dateSummary;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ageLabel.isEmpty ? 'Unknown age' : ageLabel,
                  style: theme.textTheme.titleSmall,
                ),
                if (dateSummary.isNotEmpty)
                  TextSpan(
                    text: '  ·  $dateSummary',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showChevron)
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({required this.measurement});

  final _TaggedMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final method = measurement.method;
    final response = measurement.response;
    final values = response.measurementCalculatedValues;
    final observation = response.childObservationValue?.observationValue;

    final body = theme.textTheme.bodyMedium;
    // Tabular figures keep the right-aligned columns from wobbling row to row.
    final numeric = body?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final centileStyle = numeric?.copyWith(fontWeight: FontWeight.w600);
    final sdsStyle = theme.textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Semantics(
      label: _semanticsLabel(method, observation, values),
      excludeSemantics: true,
      child: Padding(
        // Padding rather than a fixed height so the row grows with text scale.
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                method.label,
                style: body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _cell(
              context,
              _formatValue(method, observation),
              GrowthListMetrics.valueColumn,
              numeric,
            ),
            const SizedBox(width: GrowthListMetrics.columnGap),
            _cell(
              context,
              formatCentile(values?.chronologicalCentile),
              GrowthListMetrics.centileColumn,
              centileStyle,
            ),
            const SizedBox(width: GrowthListMetrics.columnGap),
            _cell(
              context,
              formatSds(values?.chronologicalSds),
              GrowthListMetrics.sdsColumn,
              sdsStyle,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _cell(
    BuildContext context,
    String text,
    double Function(BuildContext) width,
    TextStyle? style,
  ) {
    return SizedBox(
      width: width(context),
      child: Text(text, textAlign: TextAlign.end, style: style, maxLines: 1),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No growth data available to display.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Details modal
// ---------------------------------------------------------------------------

void _showDetailsModal(BuildContext context, _MeasurementOccasion occasion) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Measurement details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle('Ages', theme),
              _labeled('Date: ', occasion.dateLabel, theme),
              _labeled('Chronological age: ', occasion.ageLabel, theme),
              if (occasion.correctedAgeLabel != null)
                _labeled('Corrected age: ', occasion.correctedAgeLabel!, theme),
              if (occasion.correctedAgeComment != null &&
                  occasion.correctedAgeComment!.isNotEmpty)
                _labeled('Comment: ', occasion.correctedAgeComment!, theme),
              const SizedBox(height: 16),
              _sectionTitle('Measurements', theme),
              for (final measurement in occasion.measurements) ...[
                _MeasurementDetail(measurement: measurement),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class _MeasurementDetail extends StatelessWidget {
  const _MeasurementDetail({required this.measurement});

  final _TaggedMeasurement measurement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final method = measurement.method;
    final response = measurement.response;
    final values = response.measurementCalculatedValues;
    final observation = response.childObservationValue?.observationValue;
    final chronoBand = values?.chronologicalCentileBand;
    final correctedBand = values?.correctedCentileBand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          method.label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        _labeled('Value: ', _formatValue(method, observation), theme),
        const SizedBox(height: 8),
        Text(
          'Chronological',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        _labeled(
          'Centile: ',
          formatCentile(values?.chronologicalCentile),
          theme,
        ),
        _labeled('SDS: ', formatSds(values?.chronologicalSds), theme),
        if (chronoBand != null) _labeled('Interpretation: ', chronoBand, theme),
        const SizedBox(height: 8),
        Text(
          'Corrected',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        _labeled('Centile: ', formatCentile(values?.correctedCentile), theme),
        _labeled('SDS: ', formatSds(values?.correctedSds), theme),
        if (correctedBand != null)
          _labeled('Interpretation: ', correctedBand, theme),
      ],
    );
  }
}

Widget _sectionTitle(String text, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.secondary,
      ),
    ),
  );
}

Widget _labeled(String label, String value, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text.rich(
      TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
