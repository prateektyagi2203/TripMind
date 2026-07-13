import 'dart:math';

/// Hand-written, human-sounding arrival greetings. Deliberately templated
/// (not AI-generated) — this fires from a background isolate with no
/// guaranteed network access, so it must be instant and free.
///
/// Written for Thailand's climate: heat, hydration, easing into the trip.
class GreetingTemplates {
  static final _rand = Random();

  /// Fired when the traveller lands / arrives in the destination country.
  static String countryArrival(String country) {
    final templates = <String>[
      "Welcome to $country! 🌴 It's properly hot out there — grab some water "
          "before anything else. A cold beer wouldn't hurt either.",
      "You've landed in $country! The heat sneaks up on you here — stay "
          "hydrated. Honestly, an ice-cold one at the airport bar is a "
          "completely acceptable way to start this trip.",
      "Touchdown in $country 🎉 Long flight behind you, tropical heat ahead. "
          "Drink water like it's your job today — maybe with a beer in hand.",
      "You made it to $country! The humidity hits different here — sip "
          "water often. No judgment if a cold beer sounds better than a nap "
          "right now.",
      "Welcome to $country, traveller! It's hot, you're probably jet-lagged, "
          "and there's a beer somewhere with your name on it. Hydrate first "
          "though, seriously.",
      "Sawasdee! 🙏 You've arrived in $country. Why don't you chill it with "
          "a beer while you get your bearings? Just remember the water too.",
    ];
    return templates[_rand.nextInt(templates.length)];
  }

  /// Fired when the traveller reaches their hotel.
  static String hotelArrival(String hotel, {String? nextTime, String? nextActivity}) {
    final hasPlan = (nextTime ?? '').isNotEmpty && (nextActivity ?? '').isNotEmpty;
    final planLine = hasPlan
        ? "You've got a full day tomorrow starting around $nextTime "
            "($nextActivity), so tonight's for resting up."
        : "You've got a full day tomorrow, so tonight's for resting up.";

    final templates = <String>[
      "You've reached $hotel! Get settled, take a long shower, and put your "
          "feet up — you've earned it. $planLine",
      "Home base for the next few days: $hotel. $planLine Don't stay up too "
          "late.",
      "Welcome to $hotel! Kick off your shoes and hydrate. $planLine",
      "You've made it to $hotel 🏨 Settle in and take it easy tonight. "
          "$planLine",
      "Checked in at $hotel! Order some water (or room service), unpack, "
          "and rest. $planLine",
      "You're at $hotel now. Time to unwind. $planLine",
    ];
    return templates[_rand.nextInt(templates.length)];
  }
}
