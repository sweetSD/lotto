// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lotto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lotto _$LottoFromJson(Map<String, dynamic> json) {
  return Lotto(
      json['returnValue'] as String,
      json['drwNo'] as num,
      json['drwNoDate'] == null
          ? null
          : DateTime.parse(json['drwNoDate'] as String),
      json['totSellamnt'] as num,
      json['firstAccumamnt'] as num,
      json['firstWinamnt'] as num,
      json['firstPrzwnerCo'] as num,
      json['drwtNo1'] as num,
      json['drwtNo2'] as num,
      json['drwtNo3'] as num,
      json['drwtNo4'] as num,
      json['drwtNo5'] as num,
      json['drwtNo6'] as num,
      json['bnusNo'] as num);
}

Map<String, dynamic> _$LottoToJson(Lotto instance) => <String, dynamic>{
      'returnValue': instance.result,
      'drwNo': instance.drawNumber,
      'drwNoDate': instance.drawAt?.toIso8601String(),
      'totSellamnt': instance.totalSellAmount,
      'firstAccumamnt': instance.winnerTotalAmount,
      'firstWinamnt': instance.winnerAmount,
      'firstPrzwnerCo': instance.winnerCount,
      'drwtNo1': instance.drawNo1,
      'drwtNo2': instance.drawNo2,
      'drwtNo3': instance.drawNo3,
      'drwtNo4': instance.drawNo4,
      'drwtNo5': instance.drawNo5,
      'drwtNo6': instance.drawNo6,
      'bnusNo': instance.drawBonus
    };
