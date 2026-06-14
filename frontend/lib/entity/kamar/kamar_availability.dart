import 'dart:convert';

import 'package:sona/entity/kamar/kamar.dart';

class KamarAvailability {
  final int idKamar;
  final String namaKamar;
  final double harga;
  final int kapasitas;
  final bool statusAvailable;
  final String availabilityLabel;
  final Kamar? detailKamar;

  KamarAvailability({
    required this.idKamar,
    required this.namaKamar,
    required this.harga,
    required this.kapasitas,
    required this.statusAvailable,
    required this.availabilityLabel,
    required this.detailKamar,
  });

  factory KamarAvailability.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        json['status_available'] ??
        json['statusAvailable'] ??
        json['available'];

    return KamarAvailability(
      idKamar: _toInt(json['id_kamar'] ?? json['idKamar'] ?? json['id']),
      namaKamar:
          (json['nama_kamar'] ?? json['namaKamar'] ?? json['room_name'] ?? '')
              .toString()
              .trim(),
      harga: _parseDouble(json['harga'] ?? json['price']),
      kapasitas: _toInt(json['kapasitas'] ?? json['capacity']),
      statusAvailable: _toBool(rawStatus),
      availabilityLabel:
          (json['availability_label'] ??
                  json['availabilityLabel'] ??
                  (_toBool(rawStatus) ? 'Available' : 'Unavailable'))
              .toString()
              .trim(),
      detailKamar: _parseDetailKamar(
        json['detail_kamar'] ?? json['detailKamar'] ?? json['detail'],
      ),
    );
  }

  static Kamar? _parseDetailKamar(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return Kamar.fromJson(value);
    }

    if (value is Map) {
      return Kamar.fromJson(Map<String, dynamic>.from(value));
    }

    if (value is String) {
      final raw = value.trim();
      if (raw.isEmpty) return null;

      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return Kamar.fromJson(decoded);
        }
        if (decoded is Map) {
          return Kamar.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    final str = value?.toString().toLowerCase().trim();
    return str == 'true' || str == '1' || str == 'yes' || str == 'available';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  } //Izin nambah yaa verr
}
