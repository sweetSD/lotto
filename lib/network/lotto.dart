
import 'package:json_annotation/json_annotation.dart';

part 'lotto.g.dart';

// 로또 추첨 결과 class입니다.
@JsonSerializable()
class Lotto {
  @JsonKey(name: 'returnValue')
  final String result;

  @JsonKey(name: 'drwNo')
  final num drawNumber;

  @JsonKey(name: 'drwNoDate')
  final DateTime drawAt;

  @JsonKey(name: 'totSellamnt')
  final num totalSellAmount;

  @JsonKey(name: 'firstAccumamnt')
  final num winnerTotalAmount;

  @JsonKey(name: 'firstWinamnt')
  final num winnerAmount;

  @JsonKey(name: 'firstPrzwnerCo')
  final num winnerCount;

  @JsonKey(name: 'drwtNo1')
  final num drawNo1;

  @JsonKey(name: 'drwtNo2')
  final num drawNo2;

  @JsonKey(name: 'drwtNo3')
  final num drawNo3;

  @JsonKey(name: 'drwtNo4')
  final num drawNo4;

  @JsonKey(name: 'drwtNo5')
  final num drawNo5;

  @JsonKey(name: 'drwtNo6')
  final num drawNo6;

  @JsonKey(name: 'bnusNo')
  final num drawBonus;

  Lotto(this.result, this.drawNumber, this.drawAt, this.totalSellAmount, this.winnerTotalAmount, this.winnerAmount, this.winnerCount, this.drawNo1, this.drawNo2, this.drawNo3, this.drawNo4, this.drawNo5, this.drawNo6, this.drawBonus);

  List<int> get numbers => [drawNo1, drawNo2, drawNo3, drawNo4, drawNo5, drawNo6];

  List<int> get numbersWithBonus => [drawNo1, drawNo2, drawNo3, drawNo4, drawNo5, drawNo6, drawBonus];
  
  factory Lotto.fromJson(Map<String, dynamic> json) => _$LottoFromJson(json);

  Map<String, dynamic> toJson() => _$LottoToJson(this);
}

class LottoPick {
  final int result;
  final List<int> pickNumbers;

  const LottoPick(this.result, this.pickNumbers);
}

class LottoQRResult {
  final Lotto lotto;
  final int prize;
  final List<LottoPick> picks;

  const LottoQRResult(this.lotto, this.prize, this.picks);
}