class Headphones {
  final String name;
  final String brand; // Sony, Bose, Sennheiser, etc.
  final String image;
  final String type; // Over-ear, On-ear, In-ear
  final int batteryLife; // Hours
  final double price;
  final List<String> colors;
  final String? releaseYear;
  final String? noiseCancellation; // Active Noise Cancellation
  final bool? hasWireless; // Wireless support
  final String? connectivity; // Bluetooth, wired, etc.
  final String? bluetooth; // Bluetooth version
  final int? driverSize; // Driver size in mm
  final String? frequencyResponse; // Frequency response
  final int? impedance; // Impedance in ohms
  final int? weight; // Weight in grams
  final String? dimensions; // Dimensions
  final bool? hasMicrophone; // Microphone support
  final String? microphone; // Microphone details
  final int? chargingTime; // Charging time in minutes
  final String? waterResistance; // IP rating
  final String? audioCodec; // Audio codec support
  final bool? hasQuickCharge; // Quick charge support
  final String? caseType; // Carrying case type

  Headphones({
    required this.name,
    required this.brand,
    required this.image,
    required this.type,
    required this.batteryLife,
    required this.price,
    required this.colors,
    this.releaseYear,
    this.noiseCancellation,
    this.hasWireless,
    this.connectivity,
    this.bluetooth,
    this.driverSize,
    this.frequencyResponse,
    this.impedance,
    this.weight,
    this.dimensions,
    this.hasMicrophone,
    this.microphone,
    this.chargingTime,
    this.waterResistance,
    this.audioCodec,
    this.hasQuickCharge,
    this.caseType,
  });
}

