import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/design/components/fields/q_search_field.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

/// Opens the offline city → IANA place picker and returns the chosen city.
Future<CityRecord?> showPlacePickerSheet({required BuildContext context}) {
  return showQSheet<CityRecord>(
    context: context,
    builder: (context) => const PlacePickerSheet(),
  );
}

class PlacePickerSheet extends ConsumerStatefulWidget {
  const PlacePickerSheet({super.key});

  @override
  ConsumerState<PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends ConsumerState<PlacePickerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _deviceIana;
  CityRecord? _sameAsMe;

  @override
  void initState() {
    super.initState();
    _resolveDeviceZone();
  }

  Future<void> _resolveDeviceZone() async {
    final iana = await ref.read(deviceTimezoneSourceProvider).currentIanaName();
    if (!mounted) return;
    final match = () {
      for (final city in cityDataset) {
        if (city.ianaTimezone == iana) return city;
      }
      return null;
    }();
    setState(() {
      _deviceIana = iana;
      _sameAsMe =
          match ??
          CityRecord(
            city: 'Same as me',
            region: iana,
            country: 'This phone',
            ianaTimezone: iana,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(CityRecord city) {
    Navigator.of(context).pop(city);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final normalized = _query.trim().toLowerCase();
    final results = cityDataset
        .where((city) => city.matches(_query))
        .toList(growable: false);
    if (normalized.isNotEmpty) {
      results.sort((a, b) {
        final aExact = a.city.toLowerCase() == normalized;
        final bExact = b.city.toLowerCase() == normalized;
        if (aExact != bExact) return aExact ? -1 : 1;
        final aStarts = a.city.toLowerCase().startsWith(normalized);
        final bStarts = b.city.toLowerCase().startsWith(normalized);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        return a.city.compareTo(b.city);
      });
    }

    final showSameAsMe =
        _sameAsMe != null &&
        (normalized.isEmpty ||
            'same as me'.contains(normalized) ||
            (_deviceIana?.toLowerCase().contains(normalized) ?? false));

    return QSheet(
      title: 'Where do they live?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QSearchField(
            controller: _controller,
            autofocus: true,
            placeholder: 'Search a city',
            onChanged: (value) => setState(() => _query = value),
          ),
          SizedBox(height: q.space.base),
          Expanded(
            child: results.isEmpty && !showSameAsMe
                ? Text(
                    'Nothing matches that place yet. Try another spelling.',
                    style: q.text.body.tinted(q.color.textSecondary),
                  )
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: results.length + (showSameAsMe ? 1 : 0),
                    separatorBuilder: (_, _) => const QHairline(),
                    itemBuilder: (context, index) {
                      if (showSameAsMe && index == 0) {
                        final same = _sameAsMe!;
                        return QSettingRow(
                          label: 'Same as me',
                          subtitle: same.ianaTimezone.replaceAll('_', ' '),
                          onTap: () => _select(same),
                        );
                      }
                      final city = results[showSameAsMe ? index - 1 : index];
                      return QSettingRow(
                        label: city.city,
                        subtitle: '${city.region} · ${city.country}',
                        onTap: () => _select(city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
