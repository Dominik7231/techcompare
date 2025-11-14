import 'package:flutter/foundation.dart';
import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import '../models/airpods.dart';
import '../models/watch.dart';
import '../models/laptop.dart';
import '../models/tablet.dart';
import '../models/headphones.dart';
import '../data/phones_data.dart';
import '../data/macs_data.dart';
import '../data/ipads_data.dart';
import '../data/airpods_data.dart';
import '../data/watches_data.dart';
import '../data/laptops_data.dart';
import '../data/tablets_data.dart';
import '../data/headphones_data.dart';

class DataValidatorResult {
  final List<String> warnings;
  final int checkedCount;
  const DataValidatorResult({required this.warnings, required this.checkedCount});
}

class DataValidator {
  static DataValidatorResult validateAll() {
    final warnings = <String>[];
    int total = 0;

    void validatePhone(Phone p) {
      if (p.name.isEmpty) warnings.add('Phone name missing');
      if (p.brand.isEmpty) warnings.add('Phone \'${p.name}\' brand missing');
      if (p.price <= 0) warnings.add('Phone \'${p.name}\' price invalid');
      if (p.storageOptions.isEmpty) warnings.add('Phone \'${p.name}\' storageOptions empty');
    }

    void validateMac(Mac m) {
      if (m.name.isEmpty) warnings.add('Mac name missing');
      if (m.price <= 0) warnings.add('Mac \'${m.name}\' price invalid');
      if (m.storageOptions.isEmpty) warnings.add('Mac \'${m.name}\' storageOptions empty');
    }

    void validateiPad(iPad i) {
      if (i.name.isEmpty) warnings.add('iPad name missing');
      if (i.price <= 0) warnings.add('iPad \'${i.name}\' price invalid');
      if (i.storageOptions.isEmpty) warnings.add('iPad \'${i.name}\' storageOptions empty');
    }

    void validateAirPods(AirPods a) {
      if (a.name.isEmpty) warnings.add('AirPods name missing');
      if (a.price <= 0) warnings.add('AirPods \'${a.name}\' price invalid');
    }

    void validateWatch(Watch w) {
      if (w.name.isEmpty) warnings.add('Watch name missing');
      if (w.price <= 0) warnings.add('Watch \'${w.name}\' price invalid');
    }

    void validateLaptop(Laptop l) {
      if (l.name.isEmpty) warnings.add('Laptop name missing');
      if (l.price <= 0) warnings.add('Laptop \'${l.name}\' price invalid');
      if (l.storageOptions.isEmpty) warnings.add('Laptop \'${l.name}\' storageOptions empty');
    }

    void validateTablet(Tablet t) {
      if (t.name.isEmpty) warnings.add('Tablet name missing');
      if (t.price <= 0) warnings.add('Tablet \'${t.name}\' price invalid');
      if (t.storageOptions.isEmpty) warnings.add('Tablet \'${t.name}\' storageOptions empty');
    }

    void validateHeadphones(Headphones h) {
      if (h.name.isEmpty) warnings.add('Headphones name missing');
      if (h.price <= 0) warnings.add('Headphones \'${h.name}\' price invalid');
    }

    for (final p in allPhones) {
      total++; validatePhone(p);
    }
    for (final m in allMacs) {
      total++; validateMac(m);
    }
    for (final i in alliPads) {
      total++; validateiPad(i);
    }
    for (final a in allAirPods) {
      total++; validateAirPods(a);
    }
    for (final w in allWatches) {
      total++; validateWatch(w);
    }
    for (final l in allLaptops) {
      total++; validateLaptop(l);
    }
    for (final t in allTablets) {
      total++; validateTablet(t);
    }
    for (final h in allHeadphones) {
      total++; validateHeadphones(h);
    }

    if (warnings.isNotEmpty) {
      for (final w in warnings) {
        debugPrint('[DataValidator] $w');
      }
    } else {
      debugPrint('[DataValidator] All $total items validated successfully');
    }

    return DataValidatorResult(warnings: warnings, checkedCount: total);
  }
}

