class Tablet {
  final String name;
  final String brand; // Samsung, Lenovo, Xiaomi, etc.
  final String image;
  final String chip;
  final String display;
  final List<int> storageOptions; // Storage options in GB
  final int battery; // Battery in mAh
  final double price;
  final List<String> colors;
  final String? releaseYear;
  final int? ram; // RAM in GB
  final String? camera; // Camera details
  final String? frontCamera; // Front camera
  final int? weight; // Weight in grams
  final String? dimensions; // Dimensions
  final String? displayTech; // Display technology
  final int? refreshRate; // Refresh rate in Hz
  final int? peakBrightness; // Peak brightness in nits
  final bool? has5G; // 5G support
  final String? connectivity; // Connectivity options
  final String? ports; // Ports description
  final String? os; // Operating system
  final bool? hasStylus; // Stylus support
  final String? stylus; // Stylus details
  final int? chargingWattage; // Charging wattage
  final bool? hasWirelessCharging; // Wireless charging support

  Tablet({
    required this.name,
    required this.brand,
    required this.image,
    required this.chip,
    required this.display,
    required this.storageOptions,
    required this.battery,
    required this.price,
    required this.colors,
    this.releaseYear,
    this.ram,
    this.camera,
    this.frontCamera,
    this.weight,
    this.dimensions,
    this.displayTech,
    this.refreshRate,
    this.peakBrightness,
    this.has5G,
    this.connectivity,
    this.ports,
    this.os,
    this.hasStylus,
    this.stylus,
    this.chargingWattage,
    this.hasWirelessCharging,
  });
  
  // Helper getter for the first (base) storage option
  int get storage => storageOptions.first;
}

