class Phone {
  final String name;
  final String brand; // Brand: iPhone or Samsung
  final String image;
  final String chip;
  final String display;
  final String camera;
  final List<int> storageOptions;
  final int battery;
  final double price;
  final List<String> colors;
  final String? releaseYear;
  final String? ipProtection;
  final int? ram; // RAM in GB
  final int? weight; // Weight in grams
  final String? dimensions; // Dimensions in mm
  final bool has5G; // 5G support
  final String? frontCamera; // Front camera
  
  // Enhanced specifications
  final String? cpuDetails; // CPU details (cores, frequency)
  final String? gpuDetails; // GPU details
  final String? neuralEngine; // Neural Engine info
  final String? displayTech; // Display technology details
  final int? refreshRate; // Display refresh rate in Hz
  final int? peakBrightness; // Peak brightness in nits
  final bool? hasProMotion; // ProMotion support
  final bool? hasAlwaysOn; // Always-On display
  final bool? hasDynamicIsland; // Dynamic Island
  final String? mainCameraDetails; // Main camera specs
  final String? ultraWideCameraDetails; // Ultra Wide camera specs
  final String? telephotoDetails; // Telephoto camera specs
  final String? videoCapabilities; // Video recording capabilities
  final int? videoPlaybackHours; // Video playback battery life in hours
  final int? chargingWattage; // Charging wattage
  final bool? hasWirelessCharging; // Wireless charging support
  final String? port; // Port type (Lightning, USB-C)
  final String? usbVersion; // USB version (2.0, 3.0, etc.)
  final String? wifi; // Wi-Fi version
  final String? bluetooth; // Bluetooth version
  final bool? hasActionButton; // Action button
  final String? material; // Frame material (Aluminum, Titanium, etc.)
  final String? processTech; // Manufacturing process (nm)

  Phone({
    required this.name,
    required this.brand,
    required this.image,
    required this.chip,
    required this.display,
    required this.camera,
    required this.storageOptions,
    required this.battery,
    required this.price,
    required this.colors,
    this.releaseYear,
    this.ipProtection,
    this.ram,
    this.weight,
    this.dimensions,
    this.has5G = true,
    this.frontCamera,
    this.cpuDetails,
    this.gpuDetails,
    this.neuralEngine,
    this.displayTech,
    this.refreshRate,
    this.peakBrightness,
    this.hasProMotion,
    this.hasAlwaysOn,
    this.hasDynamicIsland,
    this.mainCameraDetails,
    this.ultraWideCameraDetails,
    this.telephotoDetails,
    this.videoCapabilities,
    this.videoPlaybackHours,
    this.chargingWattage,
    this.hasWirelessCharging,
    this.port,
    this.usbVersion,
    this.wifi,
    this.bluetooth,
    this.hasActionButton,
    this.material,
    this.processTech,
  });
  
  // Helper getter for the first (base) storage option
  int get storage => storageOptions.first;
}