
import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

// 로또 추첨 결과 class입니다.
@JsonSerializable()
class Place {
  @JsonKey(name: 'address_name')
  final String? addressName;

  @JsonKey(name: 'category_group_code')
  final String? categoryGroupCode;

  @JsonKey(name: 'category_group_name')
  final String? categoryGroupName;

  @JsonKey(name: 'category_name')
  final String? categoryName;

  @JsonKey(name: 'distance')
  final String? distance;

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'place_name')
  final String? placeName;

  @JsonKey(name: 'place_url')
  final String? placeUrl;

  @JsonKey(name: 'road_address_name')
  final String? roadAddressName;

  @JsonKey(name: 'x')
  final double? x;

  @JsonKey(name: 'y')
  final double? y;

  Place(this.addressName, this.categoryGroupCode, this.categoryGroupName, this.categoryName, this.distance, this.id, this.phone, this.placeName, this.placeUrl, this.roadAddressName, this.x, this.y);
  
  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}

class PlaceResponse {
  List<Place> places;
  bool? isEnd;

  PlaceResponse(this.places, this.isEnd);
}

class LottoStore {
  final num? index;
  final String name;
  final num? winCount;
  final String address;
  final num? storeId;

  LottoStore(this.index, this.name, this.winCount, this.address, this.storeId);
}