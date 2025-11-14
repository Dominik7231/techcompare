class iPad {
  final String name;
  final String image;
  final String chip;
  final String display;
  final List<int> ramOptions; // GB
  final List<int> storageOptions; // GB
  final int price;
  final String releaseYear;
  
  // Enhanced specifications
  final String cpuDetails;
  final String gpuDetails;
  final String neuralEngine;
  final String displayTech;
  final int? refreshRate;
  final int? peakBrightness;
  final int? batteryHours;
  final String? ports;
  final String? formFactor; // iPad, iPad Air, iPad Pro, iPad mini
  final String? colors;
  final bool? has5G; // Cellular support
  final String? camera; // Camera specs
  final double? weight; // Weight in grams
  final String? dimensions; // Dimensions in mm
  final bool? hasApplePencil; // Apple Pencil support
  final String? applePencilVersion; // Apple Pencil version (1st gen, 2nd gen)
  final bool? hasMagicKeyboard; // Magic Keyboard support

  iPad({
    required this.name,
    required this.image,
    required this.chip,
    required this.display,
    required this.ramOptions,
    required this.storageOptions,
    required this.price,
    required this.releaseYear,
    required this.cpuDetails,
    required this.gpuDetails,
    required this.neuralEngine,
    required this.displayTech,
    this.refreshRate,
    this.peakBrightness,
    this.batteryHours,
    this.ports,
    this.formFactor,
    this.colors,
    this.has5G,
    this.camera,
    this.weight,
    this.dimensions,
    this.hasApplePencil,
    this.applePencilVersion,
    this.hasMagicKeyboard,
  });
  
  // Helper getter for the first (base) storage option
  int get storage => storageOptions.first;
}

