// lib/game/models/circuit.dart
class Circuit {
  final String id;
  final String displayName;
  final String svgPath;
  final String maskPath; 

  const Circuit({
    required this.id,
    required this.displayName,
    required this.svgPath,
    required this.maskPath,
  });
}

const List<Circuit> allCircuits = [
  Circuit(id: 'abudhabi', displayName: 'Abudhabi', svgPath: 'assets/circuiti/abudhabi.svg', maskPath: 'assets/circuiti/abudhabi_mask.png'),
  Circuit(id: 'australia', displayName: 'Australia', svgPath: 'assets/circuiti/australia.svg', maskPath: 'assets/circuiti/australia_mask.png'),
  Circuit(id: 'austria', displayName: 'Austria', svgPath: 'assets/circuiti/austria.svg', maskPath: 'assets/circuiti/austria_mask.png'),
  Circuit(id: 'azerbaijan', displayName: 'Azerbaijan', svgPath: 'assets/circuiti/azerbaijan.svg', maskPath: 'assets/circuiti/azerbaijan_mask.png'),
  Circuit(id: 'bahrain', displayName: 'Bahrain', svgPath: 'assets/circuiti/bahrain.svg', maskPath: 'assets/circuiti/bahrain_mask.png'),
  Circuit(id: 'belgium', displayName: 'Belgium', svgPath: 'assets/circuiti/belgium.svg', maskPath: 'assets/circuiti/belgium_mask.png'),
  Circuit(id: 'brazil', displayName: 'Brazil', svgPath: 'assets/circuiti/brazil.svg', maskPath: 'assets/circuiti/brazil_mask.png'),
  Circuit(id: 'canada', displayName: 'Canada', svgPath: 'assets/circuiti/canada.svg', maskPath: 'assets/circuiti/canada_mask.png'),
  Circuit(id: 'greatbritain', displayName: 'Great Britain', svgPath: 'assets/circuiti/greatbritain.svg', maskPath: 'assets/circuiti/greatbritain_mask.png'),
  Circuit(id: 'hungary', displayName: 'Hungary', svgPath: 'assets/circuiti/hungary.svg', maskPath: 'assets/circuiti/hungary_mask.png'),
  Circuit(id: 'italyimola', displayName: 'Italy Imola', svgPath: 'assets/circuiti/italyimola.svg', maskPath: 'assets/circuiti/italyimola_mask.png'),
  Circuit(id: 'italymonza', displayName: 'Italy Monza', svgPath: 'assets/circuiti/italymonza.svg', maskPath: 'assets/circuiti/italymonza_mask.png'),
  Circuit(id: 'japan', displayName: 'Japan', svgPath: 'assets/circuiti/japan.svg', maskPath: 'assets/circuiti/japan_mask.png'),
  Circuit(id: 'mexico', displayName: 'Mexico', svgPath: 'assets/circuiti/mexico.svg', maskPath: 'assets/circuiti/mexico_mask.png'),
  Circuit(id: 'monaco', displayName: 'Monaco', svgPath: 'assets/circuiti/monaco.svg', maskPath: 'assets/circuiti/monaco_mask.png'),
  Circuit(id: 'netherlands', displayName: 'Netherlands', svgPath: 'assets/circuiti/netherlands.svg', maskPath: 'assets/circuiti/netherlands_mask.png'),
  Circuit(id: 'qatar', displayName: 'Qatar', svgPath: 'assets/circuiti/qatar.svg', maskPath: 'assets/circuiti/qatar_mask.png'),
  Circuit(id: 'saudiarabia', displayName: 'Saudi Arabia', svgPath: 'assets/circuiti/saudiarabia.svg', maskPath: 'assets/circuiti/saudiarabia_mask.png'),
  Circuit(id: 'shanghai', displayName: 'Shanghai', svgPath: 'assets/circuiti/shanghai.svg', maskPath: 'assets/circuiti/shanghai_mask.png'),
  Circuit(id: 'singapore', displayName: 'Singapore', svgPath: 'assets/circuiti/singapore.svg', maskPath: 'assets/circuiti/singapore_mask.png'),
  Circuit(id: 'spain', displayName: 'Spain', svgPath: 'assets/circuiti/spain.svg', maskPath: 'assets/circuiti/spain_mask.png'),
  Circuit(id: 'usacota', displayName: 'USA Cota', svgPath: 'assets/circuiti/usacota.svg', maskPath: 'assets/circuiti/usacota_mask.png'),
  Circuit(id: 'usamiami', displayName: 'USA Miami', svgPath: 'assets/circuiti/usamiami.svg', maskPath: 'assets/circuiti/usamiami_mask.png'),
  Circuit(id: 'usavegas', displayName: 'USA Vegas', svgPath: 'assets/circuiti/usavegas.svg', maskPath: 'assets/circuiti/usavegas_mask.png'),
];
