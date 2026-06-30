import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/domain/trip.dart';
import '../application/itinerary_repository.dart';
import '../domain/itinerary.dart';
import 'nearby_picker.dart';

enum _Step { preferences, generating, edit }

/// Interactive day-by-day planner.
///
/// - [aiMode] true  → guided preferences → AI draft → editable days.
/// - [aiMode] false → straight to an editable, empty (dated) day list.
/// - [existing] non-null → edit a previously saved plan.
class ItineraryPlannerScreen extends ConsumerStatefulWidget {
  final Trip trip;
  final bool aiMode;
  final ItineraryPlan? existing;

  const ItineraryPlannerScreen({
    super.key,
    required this.trip,
    this.aiMode = true,
    this.existing,
  });

  @override
  ConsumerState<ItineraryPlannerScreen> createState() =>
      _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState
    extends ConsumerState<ItineraryPlannerScreen> {
  late _Step _step;
  List<ItineraryDay> _days = [];
  bool _saving = false;
  String? _error;

  // Preferences working state.
  String _pace = 'balanced';
  final Set<String> _interests = {};
  bool _keepFirstDayLight = true;

  static const _interestOptions = [
    'Food',
    'Nature',
    'Culture',
    'Beaches',
    'History',
    'Shopping',
    'Nightlife',
    'Kids',
    'Adventure',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null && widget.existing!.days.isNotEmpty) {
      _days = List.of(widget.existing!.days);
      _step = _Step.edit;
    } else if (widget.aiMode) {
      _step = _Step.preferences;
    } else {
      _days = _seedEmptyDays();
      _step = _Step.edit;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ---- Date helpers ------------------------------------------------------
  List<DateTime> _tripDates() {
    DateTime? start = DateTime.tryParse(widget.trip.startDate);
    DateTime? end = DateTime.tryParse(widget.trip.endDate);
    if (start == null) return const [];
    end ??= start;
    if (end.isBefore(start)) end = start;
    final days = end.difference(start).inDays.clamp(0, 60);
    return [for (var i = 0; i <= days; i++) start.add(Duration(days: i))];
  }

  List<ItineraryDay> _seedEmptyDays() {
    final dates = _tripDates();
    final lastCity = widget.trip.destinations.isNotEmpty
        ? widget.trip.destinations.last.city
        : '';
    final firstCity = widget.trip.destinations.isNotEmpty
        ? widget.trip.destinations.first.city
        : '';
    return [
      for (var i = 0; i < dates.length; i++)
        ItineraryDay(
          dayIndex: i,
          date: dates[i].toIso8601String().substring(0, 10),
          area: i == dates.length - 1 ? lastCity : firstCity,
          isLight: i == 0 || i == dates.length - 1,
          activities: const [],
        ),
    ];
  }

  static String _fmtDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mo = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${wk[d.weekday - 1]}, ${d.day} ${mo[d.month - 1]}';
  }

  // ---- Generation --------------------------------------------------------
  Future<void> _generate() async {
    setState(() {
      _step = _Step.generating;
      _error = null;
    });
    try {
      final prefs = PlanPreferences(
        pace: _pace,
        interests: _interests.toList(),
        keepFirstDayLight: _keepFirstDayLight,
      );
      final plan = await ref
          .read(itineraryRepositoryProvider)
          .generate(widget.trip.id, prefs);
      if (!mounted) return;
      setState(() {
        _days = plan.days.isNotEmpty ? plan.days : _seedEmptyDays();
        _step = _Step.edit;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Couldn\'t build a plan. Try again, or enter days yourself.';
        _step = _Step.preferences;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(itineraryRepositoryProvider).save(widget.trip.id, _days);
      ref.invalidate(itineraryProvider(widget.trip.id));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Itinerary saved')));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  // ---- Day / activity editing -------------------------------------------
  void _replaceDay(int index, ItineraryDay day) {
    setState(
      () => _days = [
        for (var i = 0; i < _days.length; i++) i == index ? day : _days[i],
      ],
    );
  }

  Future<void> _browseNearby(int dayIndex) async {
    final added = await NearbyPicker.show(context, widget.trip.id);
    if (added == null || added.isEmpty) return;
    final day = _days[dayIndex];
    _replaceDay(
      dayIndex,
      day.copyWith(activities: [...day.activities, ...added]),
    );
  }

  Future<void> _editActivity(int dayIndex, {int? actIndex}) async {
    final existing = actIndex != null
        ? _days[dayIndex].activities[actIndex]
        : null;
    final result = await showDialog<Activity>(
      context: context,
      builder: (_) => _ActivityDialog(initial: existing),
    );
    if (result == null) return;
    final day = _days[dayIndex];
    final acts = [...day.activities];
    if (actIndex != null) {
      acts[actIndex] = result;
    } else {
      acts.add(result);
    }
    _replaceDay(dayIndex, day.copyWith(activities: acts));
  }

  void _deleteActivity(int dayIndex, int actIndex) {
    final day = _days[dayIndex];
    final acts = [...day.activities]..removeAt(actIndex);
    _replaceDay(dayIndex, day.copyWith(activities: acts));
  }

  void _moveActivity(int dayIndex, int actIndex, int delta) {
    final day = _days[dayIndex];
    final ni = actIndex + delta;
    if (ni < 0 || ni >= day.activities.length) return;
    final acts = [...day.activities];
    final a = acts.removeAt(actIndex);
    acts.insert(ni, a);
    _replaceDay(dayIndex, day.copyWith(activities: acts));
  }

  // ---- Build -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(_step == _Step.edit ? 'Your plan' : 'Plan your days'),
        actions: [
          if (_step == _Step.edit)
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
        ],
      ),
      body: switch (_step) {
        _Step.preferences => _PreferencesView(
          trip: widget.trip,
          pace: _pace,
          onPace: (p) => setState(() => _pace = p),
          interests: _interests,
          interestOptions: _interestOptions,
          onToggleInterest: (i) => setState(() {
            _interests.contains(i) ? _interests.remove(i) : _interests.add(i);
          }),
          keepFirstDayLight: _keepFirstDayLight,
          onKeepFirstDayLight: (v) => setState(() => _keepFirstDayLight = v),
          error: _error,
          onGenerate: _generate,
          onManual: () => setState(() {
            _days = _seedEmptyDays();
            _step = _Step.edit;
          }),
        ),
        _Step.generating => const _GeneratingView(),
        _Step.edit => _buildEdit(),
      },
    );
  }

  Widget _buildEdit() {
    if (_days.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Add your travel dates to the trip first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedForeground),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: _days.length,
      itemBuilder: (_, i) => _DayCard(
        index: i,
        day: _days[i],
        onToggleLight: (v) => _replaceDay(i, _days[i].copyWith(isLight: v)),
        onBrowseNearby: () => _browseNearby(i),
        onAddManual: () => _editActivity(i),
        onEditActivity: (ai) => _editActivity(i, actIndex: ai),
        onDeleteActivity: (ai) => _deleteActivity(i, ai),
        onMoveActivity: (ai, delta) => _moveActivity(i, ai, delta),
      ),
    );
  }
}

// ---- Preferences view ----------------------------------------------------
class _PreferencesView extends StatelessWidget {
  final Trip trip;
  final String pace;
  final ValueChanged<String> onPace;
  final Set<String> interests;
  final List<String> interestOptions;
  final ValueChanged<String> onToggleInterest;
  final bool keepFirstDayLight;
  final ValueChanged<bool> onKeepFirstDayLight;
  final String? error;
  final VoidCallback onGenerate;
  final VoidCallback onManual;

  const _PreferencesView({
    required this.trip,
    required this.pace,
    required this.onPace,
    required this.interests,
    required this.interestOptions,
    required this.onToggleInterest,
    required this.keepFirstDayLight,
    required this.onKeepFirstDayLight,
    required this.error,
    required this.onGenerate,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    const paces = [
      ('light', 'Light', 'Relaxed, 2–3 stops'),
      ('balanced', 'Balanced', 'A good mix'),
      ('packed', 'Packed', 'See it all'),
    ];
    final hotel = trip.destinations.isNotEmpty
        ? trip.destinations.first.hotelName
        : '';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        if (hotel.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.ocean.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hotel_rounded,
                  color: AppColors.ocean,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I\'ll suggest things near $hotel and your other stays.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const _Label('How packed should each day be?'),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final p in paces) ...[
              Expanded(
                child: _PaceTile(
                  selected: pace == p.$1,
                  title: p.$2,
                  subtitle: p.$3,
                  onTap: () => onPace(p.$1),
                ),
              ),
              if (p != paces.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 24),
        const _Label('What are you into?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final i in interestOptions)
              FilterChip(
                label: Text(i),
                selected: interests.contains(i),
                onSelected: (_) => onToggleInterest(i),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
              ),
          ],
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.primary,
          value: keepFirstDayLight,
          onChanged: onKeepFirstDayLight,
          title: const Text(
            'Keep the first day light',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Ease in after you arrive and check in'),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(color: AppColors.destructive, fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onGenerate,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Build my plan'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: onManual,
            child: const Text(
              'Skip — I\'ll enter days myself',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaceTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaceTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.foreground,
    ),
  );
}

// ---- Generating view -----------------------------------------------------
class _GeneratingView extends StatelessWidget {
  const _GeneratingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.ocean),
          SizedBox(height: 18),
          Text(
            'Finding the best spots near your hotel…',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

// ---- Day card ------------------------------------------------------------
class _DayCard extends StatelessWidget {
  final int index;
  final ItineraryDay day;
  final ValueChanged<bool> onToggleLight;
  final VoidCallback onBrowseNearby;
  final VoidCallback onAddManual;
  final ValueChanged<int> onEditActivity;
  final ValueChanged<int> onDeleteActivity;
  final void Function(int actIndex, int delta) onMoveActivity;

  const _DayCard({
    required this.index,
    required this.day,
    required this.onToggleLight,
    required this.onBrowseNearby,
    required this.onAddManual,
    required this.onEditActivity,
    required this.onDeleteActivity,
    required this.onMoveActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${index + 1}'
                        '${day.date.isNotEmpty ? ' · ${_ItineraryPlannerScreenState._fmtDate(day.date)}' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      if (day.title.isNotEmpty || day.area.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            day.title.isNotEmpty ? day.title : day.area,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _LightChip(value: day.isLight, onChanged: onToggleLight),
              ],
            ),
          ),
          if (day.activities.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Text(
                'No activities yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            )
          else ...[
            for (var ai = 0; ai < day.activities.length; ai++)
              _ActivityRow(
                activity: day.activities[ai],
                isFirst: ai == 0,
                isLast: ai == day.activities.length - 1,
                onEdit: () => onEditActivity(ai),
                onDelete: () => onDeleteActivity(ai),
                onMoveUp: () => onMoveActivity(ai, -1),
                onMoveDown: () => onMoveActivity(ai, 1),
              ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onBrowseNearby,
                  icon: const Icon(Icons.explore_rounded, size: 18),
                  label: const Text('Browse nearby'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.ocean),
                ),
                TextButton.icon(
                  onPressed: onAddManual,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LightChip extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LightChip({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value
              ? AppColors.sunset.withValues(alpha: 0.14)
              : AppColors.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
              size: 14,
              color: value ? AppColors.sunset : AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              'Light day',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.sunset : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Activity activity;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _ActivityRow({
    required this.activity,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: activity.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                activity.category.icon,
                size: 18,
                color: activity.category.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (activity.time.isNotEmpty) ...[
                        Text(
                          activity.time,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ocean,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activity.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        activity.description,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  if (activity.rating.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.sunset,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            activity.rating,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              onSelected: (v) => switch (v) {
                'edit' => onEdit(),
                'up' => onMoveUp(),
                'down' => onMoveDown(),
                'delete' => onDelete(),
                _ => null,
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (!isFirst)
                  const PopupMenuItem(value: 'up', child: Text('Move up')),
                if (!isLast)
                  const PopupMenuItem(value: 'down', child: Text('Move down')),
                const PopupMenuItem(value: 'delete', child: Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Activity add/edit dialog -------------------------------------------
class _ActivityDialog extends StatefulWidget {
  final Activity? initial;
  const _ActivityDialog({this.initial});
  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  late final TextEditingController _title;
  late final TextEditingController _time;
  late final TextEditingController _desc;
  late ActivityCategory _category;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _time = TextEditingController(text: widget.initial?.time ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _category = widget.initial?.category ?? ActivityCategory.sightseeing;
  }

  @override
  void dispose() {
    _title.dispose();
    _time.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final base = widget.initial;
    final result = (base ?? Activity(title: title)).copyWith(
      title: title,
      time: _time.text.trim(),
      description: _desc.text.trim(),
      category: _category,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(widget.initial == null ? 'Add activity' : 'Edit activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _time,
              decoration: const InputDecoration(
                labelText: 'Time (optional)',
                hintText: 'e.g. 09:30 or Morning',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActivityCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in ActivityCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
