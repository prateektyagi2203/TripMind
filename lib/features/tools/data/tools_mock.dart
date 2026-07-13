import 'package:flutter/material.dart';

/// Mock data backing the Tools screens (CabHub, Nearby, ATMs, Weather, Safety).
/// These mirror the Lovable source mock values; real integrations are out of
/// scope for this milestone.

class CabOption {
  final String name;
  final String eta;
  final String price;
  final Color color;
  const CabOption(this.name, this.eta, this.price, this.color);
}

const cabOptions = <CabOption>[
  CabOption('Grab', '3 min away', '฿180', Color(0xFF10B981)),
  CabOption('Bolt', '5 min away', '฿165', Color(0xFF3B82F6)),
  CabOption('inDrive', '7 min away', '฿150', Color(0xFFF59E0B)),
];

class NearbyPlace {
  final String name;
  final String emoji;
  final double rating;
  final String category;
  final String note;
  final String distance;
  const NearbyPlace(
    this.name,
    this.emoji,
    this.rating,
    this.category,
    this.note,
    this.distance,
  );
}

const nearbyCategories = <String>[
  '✨ All',
  '🏖️ Beaches',
  '🛍️ Malls',
  '🌳 Parks',
  '🦁 Zoos',
  '🛕 Temples',
  '🏛️ Museums',
  '🍜 Food',
];

const nearbyPlaces = <NearbyPlace>[
  NearbyPlace(
    'Wat Arun (Temple of Dawn)',
    '🛕',
    4.7,
    'Temples',
    'Best at sunset · Entry ฿100',
    '0.5 km',
  ),
  NearbyPlace(
    'Grand Palace',
    '🏛️',
    4.6,
    'Museums',
    'Dress code: cover shoulders & knees',
    '1.2 km',
  ),
  NearbyPlace(
    'Lumpini Park',
    '🌳',
    4.5,
    'Parks',
    'Monitor lizards, paddleboats, jogging',
    '2.1 km',
  ),
  NearbyPlace(
    'ICONSIAM',
    '🛍️',
    4.6,
    'Malls',
    'SOOKSIAM floating market on G floor',
    '1.8 km',
  ),
  NearbyPlace(
    'Chatuchak Weekend Market',
    '🛍️',
    4.4,
    'Malls',
    'Sat–Sun · Go early to beat heat',
    '6.4 km',
  ),
  NearbyPlace(
    'Safari World',
    '🦁',
    4.3,
    'Zoos',
    'Full-day · Combo ticket ฿1,800',
    '22 km',
  ),
  NearbyPlace(
    'Yaowarat (Chinatown)',
    '🍜',
    4.7,
    'Food',
    'Comes alive after 6pm',
    '1.5 km',
  ),
  NearbyPlace(
    'Bang Saen Beach',
    '🏖️',
    4.2,
    'Beaches',
    '~1.5 hr drive · Seafood shacks',
    '78 km',
  ),
  NearbyPlace(
    'Benjakitti Forest Park',
    '🌳',
    4.7,
    'Parks',
    'Great for sunset photos',
    '3.0 km',
  ),
];

class AtmInfo {
  final String name;
  final String bank;
  final String note;
  const AtmInfo(this.name, this.bank, this.note);
}

const atms = <AtmInfo>[
  AtmInfo(
    'Bangkok Bank ATM',
    'Bangkok Bank · No fee for partners',
    '24/7 · Inside 7-Eleven',
  ),
  AtmInfo(
    'Kasikorn Bank ATM',
    'K-Bank · ฿220 foreign card fee',
    'Lobby of Riva Arun Hotel',
  ),
  AtmInfo(
    'SCB Easy ATM',
    'Siam Commercial Bank',
    'Accepts Visa, Mastercard, UnionPay',
  ),
  AtmInfo('Krungsri ATM', 'Bank of Ayudhya', 'Drive-thru available'),
  AtmInfo('AEON ATM', 'Lowest withdrawal fee (฿150)', 'Best for foreign cards'),
  AtmInfo('TMB ATM', 'TMBThanachart', ''),
];

class ForecastDay {
  final String day;
  final IconData icon;
  final String temps;
  const ForecastDay(this.day, this.icon, this.temps);
}

const forecast = <ForecastDay>[
  ForecastDay('Mon', Icons.wb_sunny_rounded, '33° / 26°'),
  ForecastDay('Tue', Icons.grain_rounded, '30° / 25°'),
  ForecastDay('Wed', Icons.wb_sunny_rounded, '32° / 26°'),
  ForecastDay('Thu', Icons.grain_rounded, '29° / 25°'),
  ForecastDay('Fri', Icons.wb_sunny_rounded, '33° / 27°'),
];

class SafetyPlace {
  final String name;
  final String distance;
  final IconData icon;
  const SafetyPlace(this.name, this.distance, this.icon);
}

const safetyPlaces = <SafetyPlace>[
  SafetyPlace('Bangkok Hospital', '1.2 km', Icons.local_hospital_rounded),
  SafetyPlace('Indian Embassy', '4.5 km', Icons.account_balance_rounded),
  SafetyPlace('Tourist Police', '0.8 km', Icons.shield_rounded),
];
