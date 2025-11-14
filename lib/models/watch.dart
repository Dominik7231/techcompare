class Watch {
  final String name;
  final String brand; // Apple, Samsung, etc.
  final String image;
  final String chip;
  final String display;
  final int batteryLife; // Hours
  final double price;
  final List<String> colors;
  final String? releaseYear;
  final String? caseSize; // Case size (mm)
  final String? caseMaterial; // Case material
  final String? bandMaterial; // Band material
  final String? waterResistance; // Water resistance rating
  final bool? hasGPS; // GPS support
  final bool? hasCellular; // Cellular support
  final bool? hasECG; // ECG support
  final bool? hasBloodOxygen; // Blood oxygen monitoring
  final bool? hasTemperature; // Temperature sensor
  final bool? hasAlwaysOnDisplay; // Always-On display
  final int? storage; // Storage in GB
  final String? connectivity; // Connectivity options
  final String? sensors; // Health sensors
  final int? weight; // Weight in grams
  final String? dimensions; // Dimensions

  Watch({
    required this.name,
    required this.brand,
    required this.image,
    required this.chip,
    required this.display,
    required this.batteryLife,
    required this.price,
    required this.colors,
    this.releaseYear,
    this.caseSize,
    this.caseMaterial,
    this.bandMaterial,
    this.waterResistance,
    this.hasGPS,
    this.hasCellular,
    this.hasECG,
    this.hasBloodOxygen,
    this.hasTemperature,
    this.hasAlwaysOnDisplay,
    this.storage,
    this.connectivity,
    this.sensors,
    this.weight,
    this.dimensions,
  });
}

