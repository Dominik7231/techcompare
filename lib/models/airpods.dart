class AirPods {
  final String name;
  final String image;
  final String chip;
  final int batteryLife; // Hours
  final double price;
  final List<String> colors;
  final String? releaseYear;
  final String? noiseCancellation; // Active Noise Cancellation
  final String? spatialAudio; // Spatial Audio support
  final int? weight; // Weight in grams
  final String? dimensions; // Dimensions in mm
  final String? chargingCase; // Charging case type
  final bool? hasWirelessCharging; // Wireless charging support
  final String? bluetooth; // Bluetooth version
  final int? driverSize; // Driver size in mm
  final String? microphone; // Microphone details
  final int? chargingTime; // Charging time in minutes
  final int? caseBatteryLife; // Case battery life in hours
  final bool? hasFindMy; // Find My support
  final String? waterResistance; // IP rating
  final String? audioCodec; // Audio codec support

  AirPods({
    required this.name,
    required this.image,
    required this.chip,
    required this.batteryLife,
    required this.price,
    required this.colors,
    this.releaseYear,
    this.noiseCancellation,
    this.spatialAudio,
    this.weight,
    this.dimensions,
    this.chargingCase,
    this.hasWirelessCharging,
    this.bluetooth,
    this.driverSize,
    this.microphone,
    this.chargingTime,
    this.caseBatteryLife,
    this.hasFindMy,
    this.waterResistance,
    this.audioCodec,
  });
}

