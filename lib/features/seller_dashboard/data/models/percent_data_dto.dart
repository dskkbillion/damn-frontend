import 'package:equatable/equatable.dart';

class PercentDataDto extends Equatable {
  final int heatPercent;
  final int recoverPercent;
  final int completePercent;
  final int goodPercent;

  const PercentDataDto({
    required this.heatPercent,
    required this.recoverPercent,
    required this.completePercent,
    required this.goodPercent,
  });

  factory PercentDataDto.fromJson(Map<String, dynamic> json) {
    return PercentDataDto(
      heatPercent: json['heatPercent'] as int,
      recoverPercent: json['recoverPercent'] as int,
      completePercent: json['completePercent'] as int,
      goodPercent: json['goodPercent'] as int,
    );
  }

  // We don't usually need toJson in DTOs if they are only used for receiving data

  @override
  List<Object?> get props => [
        heatPercent,
        recoverPercent,
        completePercent,
        goodPercent,
      ];
} 