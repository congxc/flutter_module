// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseBean _$ResponseBeanFromJson(Map<String, dynamic> json) {
  return ResponseBean(
    json['status_code'] as int,
    json['status'] as String,
    (json['data'] as List)
        ?.map((e) =>
            e == null ? null : Destination.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ResponseBeanToJson(ResponseBean instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'status': instance.status,
      'data': instance.data,
    };

Destination _$DestinationFromJson(Map<String, dynamic> json) {
  return Destination(
    json['longitude'] as String,
    json['right-to-left'] as int,
    json['nr_hotels'] as int,
    json['type'] as String,
    json['country'] as String,
    json['city_name'] as String,
    json['label'] as String,
    json['region'] as String,
    json['latitude'] as String,
    json['id'] as String,
    json['language'] as String,
    json['url'] as String,
    json['name'] as String,
    json['country_name'] as String,
  );
}

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'longitude': instance.longitude,
      'right-to-left': instance.right_to_left,
      'nr_hotels': instance.nrHotels,
      'type': instance.type,
      'country': instance.country,
      'city_name': instance.cityName,
      'label': instance.label,
      'region': instance.region,
      'latitude': instance.latitude,
      'id': instance.id,
      'language': instance.language,
      'url': instance.url,
      'name': instance.name,
      'country_name': instance.countryName,
    };
