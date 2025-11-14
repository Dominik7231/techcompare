class Mac {
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
  final String? formFactor;
  final String? colors;

  Mac({
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
  });
}
