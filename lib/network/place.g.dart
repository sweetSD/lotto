// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return Place(
    json['address_name'] as String,
    json['category_group_code'] as String,
    json['category_group_name'] as String,
    json['category_name'] as String,
    json['distance'] as String,
    json['id'] as String,
    json['phone'] as String,
    json['place_name'] as String,
    json['place_url'] as String,
    json['road_address_name'] as String,
    double.tryParse(json['x'] as String),
    double.tryParse(json['y'] as String),
  );
}

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'address_name': instance.addressName,
      'category_group_code': instance.categoryGroupCode,
      'category_group_name': instance.categoryGroupName,
      'category_name': instance.categoryName,
      'distance': instance.distance,
      'id': instance.id,
      'phone': instance.phone,
      'place_name': instance.placeName,
      'place_url': instance.placeUrl,
      'road_address_name': instance.roadAddressName,
      'x': instance.x,
      'y': instance.y,
    };
