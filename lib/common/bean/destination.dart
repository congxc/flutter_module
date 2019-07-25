import 'package:json_annotation/json_annotation.dart';

part 'destination.g.dart';

@JsonSerializable()
class ResponseBean {
  @JsonKey(name: 'status_code')
  int statusCode;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'data')
  List<Destination> data;

  ResponseBean(
    this.statusCode,
    this.status,
    this.data,
  );

  factory ResponseBean.fromJson(Map<String, dynamic> srcJson) =>
      _$ResponseBeanFromJson(srcJson);
}

@JsonSerializable()
class Destination {
  @JsonKey(name: 'longitude')
  String longitude;

  @JsonKey(name: 'right-to-left')
  int right_to_left;

  @JsonKey(name: 'nr_hotels')
  int nrHotels;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'country')
  String country;

  @JsonKey(name: 'city_name')
  String cityName;

  @JsonKey(name: 'label')
  String label;

  @JsonKey(name: 'region')
  String region;

  @JsonKey(name: 'latitude')
  String latitude;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'language')
  String language;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'country_name')
  String countryName;

  Destination(
    this.longitude,
    this.right_to_left,
    this.nrHotels,
    this.type,
    this.country,
    this.cityName,
    this.label,
    this.region,
    this.latitude,
    this.id,
    this.language,
    this.url,
    this.name,
    this.countryName,
  );

  factory Destination.fromJson(Map<String, dynamic> srcJson) =>
      _$DestinationFromJson(srcJson);

  @override
  String toString() {
    return 'Destination{longitude: $longitude, type: $type, country: $country, '
        'cityName: $cityName, region: $region, latitude: $latitude, id: $id, '
        'language: $language, url: $url, name: $name, countryName: $countryName}';
  }
}
