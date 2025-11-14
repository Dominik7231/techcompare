class Laptop {
  final String name;
  final String brand; // Dell, HP, Lenovo, ASUS, etc.
  final String image;
  final String processor; // CPU
  final String display;
  final List<int> ramOptions; // RAM options in GB
  final List<int> storageOptions; // Storage options in GB
  final double price;
  final String? releaseYear;
  final String? gpu; // GPU
  final String? displayTech; // Display technology
  final int? refreshRate; // Refresh rate in Hz
  final int? peakBrightness; // Peak brightness in nits
  final int? batteryHours; // Battery life in hours
  final String? ports; // Ports description
  final double? weight; // Weight in kg
  final String? dimensions; // Dimensions
  final String? os; // Operating system
  final bool? hasTouchscreen; // Touchscreen support
  final String? keyboard; // Keyboard details
  final String? trackpad; // Trackpad details
  final String? webcam; // Webcam details
  final String? audio; // Audio system

  Laptop({
    required this.name,
    required this.brand,
    required this.image,
    required this.processor,
    required this.display,
    required this.ramOptions,
    required this.storageOptions,
    required this.price,
    this.releaseYear,
    this.gpu,
    this.displayTech,
    this.refreshRate,
    this.peakBrightness,
    this.batteryHours,
    this.ports,
    this.weight,
    this.dimensions,
    this.os,
    this.hasTouchscreen,
    this.keyboard,
    this.trackpad,
    this.webcam,
    this.audio,
  });
  
  // Helper getter for the first (base) storage option
  int get storage => storageOptions.first;
  
  // Helper getter for the first (base) RAM option
  int get ram => ramOptions.first;
}

