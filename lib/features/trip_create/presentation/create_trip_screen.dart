import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../../itinerary/application/itinerary_repository.dart';
import '../../trips/application/trips_repository.dart';
import '../../trips/domain/trip.dart';

/// Common airlines for the flight dropdown. "Other" reveals a free-text field.
const List<String> kAirlines = [
  'IndiGo',
  'Air India',
  'Air India Express',
  'Vistara',
  'SpiceJet',
  'Akasa Air',
  'GoFirst',
  'Thai Airways',
  'Thai AirAsia',
  'Bangkok Airways',
  'Singapore Airlines',
  'Scoot',
  'Malaysia Airlines',
  'AirAsia',
  'Emirates',
  'Etihad Airways',
  'Qatar Airways',
  'Lufthansa',
  'British Airways',
  'Air France',
  'KLM',
  'Turkish Airlines',
  'Cathay Pacific',
  'Japan Airlines',
  'ANA',
  'Qantas',
  'United Airlines',
  'American Airlines',
  'Delta Air Lines',
  'Other',
];

/// Multi-step "Create a trip" wizard:
/// name → dates → first city + hotel → flight home → extra cities (with
/// transport mode) → review → create. Pass [existing] to edit a trip instead.
class CreateTripScreen extends ConsumerStatefulWidget {
  final Trip? existing;
  const CreateTripScreen({super.key, this.existing});

  static Future<Trip?> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push<Trip>(MaterialPageRoute(builder: (_) => const CreateTripScreen()));
  }

  /// Opens the wizard pre-filled to edit an existing trip.
  static Future<Trip?> edit(BuildContext context, Trip trip) {
    return Navigator.of(context).push<Trip>(
      MaterialPageRoute(builder: (_) => CreateTripScreen(existing: trip)),
    );
  }

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CityDraft {
  final cityCtrl = TextEditingController();
  final hotelCtrl = TextEditingController();
  String hotelAddress = '';
  bool resolving = false;
  List<HotelOption> hotelOptions = [];
  // Transport used to reach this city (for city index 0 this is the inbound trip).
  TransportMode mode = TransportMode.flight;
  final flightNumberCtrl = TextEditingController();
  String airline = '';
  final airlineOtherCtrl = TextEditingController();
  final routeCtrl = TextEditingController();

  void dispose() {
    cityCtrl.dispose();
    hotelCtrl.dispose();
    flightNumberCtrl.dispose();
    airlineOtherCtrl.dispose();
    routeCtrl.dispose();
  }
}

/// One traveller on the trip: name, age and sex. The first traveller is "me".
class _TravellerDraft {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  String sex = ''; // male | female | other | ''
  final bool isMe;

  _TravellerDraft({this.isMe = false});

  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
  }
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  int _step = 0;
  static const _lastStep = 5;

  final _nameCtrl = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  // Departure (home) flight — date & local time the traveller flies back.
  DateTime? _depDate;
  TimeOfDay? _depTime;
  bool _lookingUpFlight = false;
  String _gradient = 'sunset';
  String _currency = 'THB';
  bool _submitting = false;

  final List<_CityDraft> _cities = [_CityDraft()];

  // Travellers — the first one is "me" (Prateek) by default.
  final List<_TravellerDraft> _travellers = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;

    // Seed travellers: an existing trip's saved list, otherwise a default
    // "me" = Prateek (42) which the user can edit.
    if (t != null && t.travellers.isNotEmpty) {
      for (final tr in t.travellers) {
        final d = _TravellerDraft(isMe: tr.isMe);
        d.nameCtrl.text = tr.name;
        d.ageCtrl.text = tr.age > 0 ? tr.age.toString() : '';
        d.sex = tr.sex;
        _travellers.add(d);
      }
    } else {
      final me = _TravellerDraft(isMe: true);
      me.nameCtrl.text = 'Prateek';
      me.ageCtrl.text = '42';
      _travellers.add(me);
    }

    if (t == null) return;
    _nameCtrl.text = t.name;
    _start = DateTime.tryParse(t.startDate);
    _end = DateTime.tryParse(t.endDate);
    _gradient = t.coverGradient.isEmpty ? 'sunset' : t.coverGradient;
    _currency = t.currency.isEmpty ? 'THB' : t.currency;

    if (t.destinations.isNotEmpty) {
      _cities.clear();
      for (var i = 0; i < t.destinations.length; i++) {
        final d = t.destinations[i];
        final j = i < t.journeys.length ? t.journeys[i] : null;
        final draft = _CityDraft();
        draft.cityCtrl.text = d.city;
        draft.hotelCtrl.text = d.hotelName;
        draft.hotelAddress = d.hotelAddress;
        if (j != null) {
          draft.mode = j.mode;
          draft.flightNumberCtrl.text = j.flightNumber;
          draft.routeCtrl.text = j.route;
          if (j.airline.isEmpty) {
            draft.airline = '';
          } else if (kAirlines.contains(j.airline)) {
            draft.airline = j.airline;
          } else {
            draft.airline = 'Other';
            draft.airlineOtherCtrl.text = j.airline;
          }
        }
        _cities.add(draft);
      }
    }

    // Restore the departure (home) flight date & local time from journey 0.
    final dep = t.journeys.isNotEmpty ? t.journeys.first.depart : '';
    final depDt = DateTime.tryParse(dep);
    if (depDt != null) {
      _depDate = DateTime(depDt.year, depDt.month, depDt.day);
      if (dep.contains('T')) {
        _depTime = TimeOfDay(hour: depDt.hour, minute: depDt.minute);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final c in _cities) {
      c.dispose();
    }
    for (final t in _travellers) {
      t.dispose();
    }
    super.dispose();
  }

  // ---- validation per step ----
  bool get _canAdvance => switch (_step) {
    0 => _nameCtrl.text.trim().isNotEmpty,
    1 => _start != null && _end != null && !_end!.isBefore(_start!),
    2 =>
      _travellers.isNotEmpty &&
          _travellers.every((t) => t.nameCtrl.text.trim().isNotEmpty),
    3 =>
      _cities.first.cityCtrl.text.trim().isNotEmpty &&
          _cities.first.hotelCtrl.text.trim().isNotEmpty,
    4 => true, // inbound flight optional fields
    5 =>
      _cities
          .skip(1)
          .every(
            (c) =>
                c.cityCtrl.text.trim().isNotEmpty &&
                c.hotelCtrl.text.trim().isNotEmpty,
          ),
    _ => true,
  };

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _airlineValue(_CityDraft c) {
    if (c.airline == 'Other') return c.airlineOtherCtrl.text.trim();
    return c.airline.trim();
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = start ? (_start ?? now) : (_end ?? _start ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = null;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _pickDepDate() async {
    final base = _depDate ?? _end ?? _start ?? DateTime.now();
    final first = _start ?? DateTime.now().subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: first,
      lastDate: (_end ?? base).add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _depDate = picked);
  }

  Future<void> _pickDepTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _depTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;
    setState(() => _depTime = picked);
  }

  /// Auto-fill the departure time by looking up the flight number + date.
  Future<void> _lookupDepTime() async {
    final c = _cities.first;
    final fno = c.flightNumberCtrl.text.trim();
    if (fno.isEmpty) {
      _snack('Enter the flight number first.');
      return;
    }
    final d = _depDate ?? _end;
    if (d == null) {
      _snack('Pick the departure date first.');
      return;
    }
    setState(() => _lookingUpFlight = true);
    try {
      final time = await ref
          .read(itineraryRepositoryProvider)
          .lookupFlightTime(fno, _fmt(d));
      if (!mounted) return;
      if (time == null) {
        _snack('Couldn\'t find $fno on ${_fmt(d)}. Enter the time manually.');
      } else {
        final parts = time.split(':');
        setState(() {
          _depTime = TimeOfDay(
            hour: int.tryParse(parts.first) ?? 0,
            minute: int.tryParse(parts.last) ?? 0,
          );
        });
        _snack('Departure time set to $time (local).');
      }
    } catch (_) {
      if (mounted) _snack('Lookup failed. Enter the time manually.');
    } finally {
      if (mounted) setState(() => _lookingUpFlight = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// The departure flight datetime as a local ISO string (date, or date+time).
  String _depDateTimeIso() {
    final d = _depDate ?? _end;
    if (d == null) return '';
    final dd = _fmt(d);
    if (_depTime == null) return dd;
    final hh = _depTime!.hour.toString().padLeft(2, '0');
    final mm = _depTime!.minute.toString().padLeft(2, '0');
    return '${dd}T$hh:$mm';
  }

  Future<void> _resolveHotel(_CityDraft c) async {
    final query = c.hotelCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => c.resolving = true);
    try {
      final options = await ref
          .read(tripsRepositoryProvider)
          .searchHotels(query, c.cityCtrl.text.trim());
      setState(() {
        c.hotelOptions = options;
        c.resolving = false;
        // Auto-fill address if there's an exact single match.
        if (options.length == 1) {
          c.hotelCtrl.text = options.first.name;
          c.hotelAddress = options.first.address;
          c.hotelOptions = [];
        }
      });
    } catch (_) {
      setState(() => c.resolving = false);
    }
  }

  void _pickHotel(_CityDraft c, HotelOption option) {
    setState(() {
      c.hotelCtrl.text = option.name;
      c.hotelAddress = option.address;
      c.hotelOptions = [];
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final destinations = <Destination>[];
    final journeys = <Journey>[];
    final lastCity = _cities.last.cityCtrl.text.trim();
    for (var i = 0; i < _cities.length; i++) {
      final c = _cities[i];
      destinations.add(
        Destination(
          city: c.cityCtrl.text.trim(),
          hotelName: c.hotelCtrl.text.trim(),
          hotelAddress: c.hotelAddress,
          checkin: i == 0 ? _fmt(_start!) : '',
          checkout: i == _cities.length - 1 ? _fmt(_end!) : '',
        ),
      );
      // Journey 0 carries the departure (home) flight; later journeys are the
      // inter-city legs. We only plan the flight home, not the arrival.
      if (i == 0) {
        journeys.add(
          Journey(
            mode: c.mode,
            fromCity: lastCity,
            toCity: 'Home',
            flightNumber: c.flightNumberCtrl.text.trim(),
            airline: _airlineValue(c),
            route: c.routeCtrl.text.trim(),
            depart: _depDateTimeIso(),
          ),
        );
      } else {
        journeys.add(
          Journey(
            mode: c.mode,
            fromCity: _cities[i - 1].cityCtrl.text.trim(),
            toCity: c.cityCtrl.text.trim(),
            flightNumber: c.flightNumberCtrl.text.trim(),
            airline: _airlineValue(c),
            route: c.routeCtrl.text.trim(),
            depart: '',
          ),
        );
      }
    }
    try {
      final repo = ref.read(tripsRepositoryProvider);
      final existing = widget.existing;
      final travellers = [
        for (final t in _travellers)
          if (t.nameCtrl.text.trim().isNotEmpty)
            Traveller(
              name: t.nameCtrl.text.trim(),
              age: int.tryParse(t.ageCtrl.text.trim()) ?? 0,
              sex: t.sex,
              isMe: t.isMe,
            ),
      ];
      final trip = existing == null
          ? await repo.create(
              name: _nameCtrl.text.trim(),
              startDate: _fmt(_start!),
              endDate: _fmt(_end!),
              currency: _currency,
              coverGradient: _gradient,
              destinations: destinations,
              journeys: journeys,
              travellers: travellers,
            )
          : await repo.update(
              tripId: existing.id,
              name: _nameCtrl.text.trim(),
              startDate: _fmt(_start!),
              endDate: _fmt(_end!),
              currency: _currency,
              coverGradient: _gradient,
              destinations: destinations,
              journeys: journeys,
              travellers: travellers,
            );
      ref.invalidate(tripsListProvider);
      if (!mounted) return;
      Navigator.of(context).pop(trip);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Could not save changes. Is the backend running?'
                : 'Could not create trip. Is the backend running?',
          ),
        ),
      );
    }
  }

  void _next() {
    if (_step < _lastStep) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Screen(
        child: Column(
          children: [
            ScreenHeader(
              title: _isEdit ? 'Edit trip' : 'New trip',
              subtitle: 'Step ${_step + 1} of ${_lastStep + 1}',
              leading: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.foreground,
                ),
                onPressed: _back,
              ),
            ),
            _Progress(step: _step, total: _lastStep + 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: _buildStep(),
                ),
              ),
            ),
            _Footer(
              canAdvance: _canAdvance && !_submitting,
              submitting: _submitting,
              isLast: _step == _lastStep,
              lastLabel: _isEdit ? 'Save changes' : 'Create trip',
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => _stepName(),
    1 => _stepDates(),
    2 => _stepTravellers(),
    3 => _stepFirstCity(),
    4 => _stepInboundFlight(),
    _ => _stepExtraCities(),
  };

  // Step 0 — name + cover
  Widget _stepName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we call this trip?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Trip name',
            hintText: 'Thailand with the family',
          ),
        ),
        const SizedBox(height: 24),
        const Text('Cover', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            _GradientChoice(
              colors: AppColors.gradientSunset,
              selected: _gradient == 'sunset',
              onTap: () => setState(() => _gradient = 'sunset'),
            ),
            const SizedBox(width: 12),
            _GradientChoice(
              colors: AppColors.gradientOcean,
              selected: _gradient == 'ocean',
              onTap: () => setState(() => _gradient = 'ocean'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 1 — dates + currency
  Widget _stepDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When are you travelling?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'From',
          value: _start == null ? null : _fmt(_start!),
          onTap: () => _pickDate(start: true),
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'To',
          value: _end == null ? null : _fmt(_end!),
          onTap: () => _pickDate(start: false),
        ),
        const SizedBox(height: 24),
        const Text(
          'Trip currency',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['THB', 'INR', 'USD', 'EUR', 'JPY', 'SGD']
              .map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: _currency == c,
                  onSelected: (_) => setState(() => _currency = c),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // Step 2 — who's travelling (count + each name, age, sex)
  Widget _stepTravellers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who\'s travelling?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        const Text(
          'Add everyone on the trip. Ages help tailor the plan (kid-friendly '
          'stops, pace and more).',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Travellers',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            _CountStepper(
              count: _travellers.length,
              min: 1,
              onChanged: _setTravellerCount,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _travellers.length; i++) ...[
          _TravellerForm(
            key: ValueKey(_travellers[i]),
            draft: _travellers[i],
            index: i,
            onChanged: () => setState(() {}),
            onRemove: _travellers.length > 1 && !_travellers[i].isMe
                ? () => _removeTraveller(i)
                : null,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _setTravellerCount(int next) {
    setState(() {
      if (next > _travellers.length) {
        while (_travellers.length < next) {
          _travellers.add(_TravellerDraft());
        }
      } else if (next < _travellers.length) {
        // Remove from the end, but never remove "me" (index 0).
        while (_travellers.length > next && _travellers.length > 1) {
          _travellers.removeLast().dispose();
        }
      }
    });
  }

  void _removeTraveller(int i) {
    setState(() => _travellers.removeAt(i).dispose());
  }

  // Step 3 — first city + hotel
  Widget _stepFirstCity() {
    return _CityForm(
      draft: _cities.first,
      title: 'Where are you staying first?',
      onChanged: () => setState(() {}),
      onResolve: () => _resolveHotel(_cities.first),
      onPickHotel: (o) => _pickHotel(_cities.first, o),
      showTransport: false,
    );
  }

  // Step 4 — departure (home) flight (stored as the journey for city 0)
  Widget _stepInboundFlight() {
    final c = _cities.first;
    _depDate ??= _end;
    final lastCity = _cities.last.cityCtrl.text.trim();
    String two(int n) => n.toString().padLeft(2, '0');
    final timeLabel = _depTime == null
        ? null
        : '${two(_depTime!.hour)}:${two(_depTime!.minute)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your flight home',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          lastCity.isEmpty
              ? 'When do you fly back home? Use local departure time.'
              : 'When do you fly back from $lastCity? Use local time.',
          style: const TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'Departure date',
          value: _depDate == null ? null : _fmt(_depDate!),
          onTap: _pickDepDate,
        ),
        const SizedBox(height: 12),
        _DateField(
          label: 'Departure time (local)',
          value: timeLabel,
          onTap: _pickDepTime,
        ),
        const SizedBox(height: 16),
        _ModePicker(
          selected: c.mode,
          onSelect: (m) => setState(() => c.mode = m),
        ),
        const SizedBox(height: 16),
        _TransportDetails(draft: c, onChanged: () => setState(() {})),
        if (c.mode == TransportMode.flight) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _lookingUpFlight ? null : _lookupDepTime,
              icon: _lookingUpFlight
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.schedule_rounded, size: 18),
              label: Text(
                _lookingUpFlight ? 'Looking up…' : 'Auto-fill time from flight',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Step 5 — additional cities
  Widget _stepExtraCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staying in more cities?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        const Text(
          'Add each city, its hotel, and how you travel there.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 16),
        for (var i = 1; i < _cities.length; i++) ...[
          PlainCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'City ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.destructive,
                      ),
                      onPressed: () =>
                          setState(() => _cities.removeAt(i).dispose()),
                    ),
                  ],
                ),
                _CityForm(
                  draft: _cities[i],
                  title: '',
                  onChanged: () => setState(() {}),
                  onResolve: () => _resolveHotel(_cities[i]),
                  onPickHotel: (o) => _pickHotel(_cities[i], o),
                  showTransport: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => setState(
            () => _cities.add(_CityDraft()..mode = TransportMode.flight),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add another city'),
        ),
      ],
    );
  }
}

// ----------------------- step sub-widgets -----------------------

class _Progress extends StatelessWidget {
  final int step;
  final int total;
  const _Progress({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: (step + 1) / total,
          minHeight: 6,
          backgroundColor: AppColors.muted,
          valueColor: const AlwaysStoppedAnimation(AppColors.ocean),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool canAdvance;
  final bool submitting;
  final bool isLast;
  final String lastLabel;
  final VoidCallback onNext;
  const _Footer({
    required this.canAdvance,
    required this.submitting,
    required this.isLast,
    required this.lastLabel,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: canAdvance ? onNext : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isLast ? lastLabel : 'Continue'),
        ),
      ),
    );
  }
}

class _GradientChoice extends StatelessWidget {
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;
  const _GradientChoice({
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.foreground : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_circle, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _CountStepper extends StatelessWidget {
  final int count;
  final int min;
  final ValueChanged<int> onChanged;
  const _CountStepper({
    required this.count,
    required this.onChanged,
    this.min = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            color: AppColors.ocean,
            onPressed: count > min ? () => onChanged(count - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            color: AppColors.ocean,
            onPressed: count < 20 ? () => onChanged(count + 1) : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _TravellerForm extends StatelessWidget {
  final _TravellerDraft draft;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;
  const _TravellerForm({
    super.key,
    required this.draft,
    required this.index,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: draft.isMe
                    ? AppColors.primary
                    : AppColors.ocean.withValues(alpha: 0.15),
                child: Icon(
                  draft.isMe ? Icons.person_rounded : Icons.person_outline,
                  size: 16,
                  color: draft.isMe ? Colors.white : AppColors.ocean,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                draft.isMe ? 'You' : 'Traveller ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.mutedForeground,
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: draft.nameCtrl,
            onChanged: (_) => onChanged(),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Full name',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: TextField(
                  controller: draft.ageCtrl,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        'Sex',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final s in const [
                          ('male', 'Male'),
                          ('female', 'Female'),
                          ('other', 'Other'),
                        ])
                          ChoiceChip(
                            label: Text(s.$2),
                            selected: draft.sex == s.$1,
                            onSelected: (_) {
                              draft.sex = draft.sex == s.$1 ? '' : s.$1;
                              onChanged();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppColors.ocean,
            ),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            Text(
              value ?? 'Select date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value == null
                    ? AppColors.mutedForeground
                    : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityForm extends StatelessWidget {
  final _CityDraft draft;
  final String title;
  final VoidCallback onChanged;
  final VoidCallback onResolve;
  final ValueChanged<HotelOption> onPickHotel;
  final bool showTransport;
  const _CityForm({
    required this.draft,
    required this.title,
    required this.onChanged,
    required this.onResolve,
    required this.onPickHotel,
    required this.showTransport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: draft.cityCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'City',
            hintText: 'Phuket',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: draft.hotelCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Hotel',
            hintText: 'Novotel',
            helperText:
                'Type a hotel or brand, then tap search for all matches',
            suffixIcon: draft.resolving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Search hotels',
                    icon: const Icon(
                      Icons.travel_explore_rounded,
                      color: AppColors.ocean,
                    ),
                    onPressed: onResolve,
                  ),
          ),
        ),
        if (draft.hotelAddress.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.place_rounded,
                size: 16,
                color: AppColors.sunset,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  draft.hotelAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (draft.hotelOptions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            '${draft.hotelOptions.length} matches — pick yours',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: draft.hotelOptions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, idx) {
                final o = draft.hotelOptions[idx];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.hotel_rounded,
                    size: 18,
                    color: AppColors.ocean,
                  ),
                  title: Text(
                    o.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: o.address.isEmpty
                      ? null
                      : Text(o.address, style: const TextStyle(fontSize: 11)),
                  onTap: () => onPickHotel(o),
                );
              },
            ),
          ),
        ],
        if (showTransport) ...[
          const SizedBox(height: 16),
          const Text(
            'How do you travel here?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _ModePicker(
            selected: draft.mode,
            onSelect: (m) {
              draft.mode = m;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          _TransportDetails(draft: draft, onChanged: onChanged),
        ],
      ],
    );
  }
}

class _ModePicker extends StatelessWidget {
  final TransportMode selected;
  final ValueChanged<TransportMode> onSelect;
  const _ModePicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TransportMode.values.map((m) {
        final active = m == selected;
        return GestureDetector(
          onTap: () => onSelect(m),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.ocean : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? AppColors.ocean : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m.icon,
                  size: 16,
                  color: active ? Colors.white : AppColors.foreground,
                ),
                const SizedBox(width: 6),
                Text(
                  m.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TransportDetails extends StatelessWidget {
  final _CityDraft draft;
  final VoidCallback onChanged;
  const _TransportDetails({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (draft.mode != TransportMode.flight) {
      return TextField(
        controller: draft.routeCtrl,
        onChanged: (_) => onChanged(),
        decoration: const InputDecoration(
          labelText: 'Details (optional)',
          hintText: 'e.g. Pickup at 9am',
        ),
      );
    }
    return Column(
      children: [
        TextField(
          controller: draft.flightNumberCtrl,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [UpperCaseTextFormatter()],
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Flight number',
            hintText: 'AI302',
            helperText: 'We\'ll track live status, delays & terminal changes',
            prefixIcon: Icon(Icons.flight_takeoff_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: draft.airline.isEmpty ? null : draft.airline,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Airline'),
          hint: const Text('Select airline'),
          items: kAirlines
              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
              .toList(),
          onChanged: (v) {
            draft.airline = v ?? '';
            onChanged();
          },
        ),
        if (draft.airline == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: draft.airlineOtherCtrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Airline name',
              hintText: 'Type your airline',
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: draft.routeCtrl,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Route (optional)',
            hintText: 'DEL → BKK',
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue value,
  ) {
    return value.copyWith(text: value.text.toUpperCase());
  }
}
