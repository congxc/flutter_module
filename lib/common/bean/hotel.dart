import 'package:json_annotation/json_annotation.dart';

part 'hotel.g.dart';

@JsonSerializable()
class HotelResponseBean {
  @JsonKey(name: 'status_code')
  int statusCode;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'data')
  List<HotelBean> data;

  HotelResponseBean(
    this.statusCode,
    this.status,
    this.data,
  );

  factory HotelResponseBean.fromJson(Map<String, dynamic> srcJson) =>
      _$HotelResponseBeanFromJson(srcJson);
}

@JsonSerializable()
class HotelBean {
  @JsonKey(name: 'location')
  Location location;

  @JsonKey(name: 'hotel_url')
  String hotelUrl;

  @JsonKey(name: 'deep_link_url')
  String deepLinkUrl;

  @JsonKey(name: 'hotel_id')
  int hotelId;

  @JsonKey(name: 'cc_required')
  bool ccRequired;

  @JsonKey(name: 'default_language')
  String defaultLanguage;

  @JsonKey(name: 'price')
  double price;

  @JsonKey(name: 'checkin_time')
  Checkin_time checkinTime;

  @JsonKey(name: 'cvc_required')
  bool cvcRequired;

  @JsonKey(name: 'hotel_currency_code')
  String hotelCurrencyCode;

  @JsonKey(name: 'photo')
  String photo;

  @JsonKey(name: 'hotel_amenities')
  List<String> hotelAmenities;

  @JsonKey(name: 'country')
  String country;

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'rooms')
  List<Rooms> rooms;

  @JsonKey(name: 'review_nr')
  int reviewNr;

  @JsonKey(name: 'review_score')
  double reviewScore;

  @JsonKey(name: 'postcode')
  String postcode;

  @JsonKey(name: 'review_score_word')
  String reviewScoreWord;

  @JsonKey(name: 'hotel_name')
  String hotelName;

  @JsonKey(name: 'stars')
  String stars;

  HotelBean(
    this.location,
    this.hotelUrl,
    this.deepLinkUrl,
    this.hotelId,
    this.ccRequired,
    this.defaultLanguage,
    this.price,
    this.checkinTime,
    this.cvcRequired,
    this.hotelCurrencyCode,
    this.photo,
    this.hotelAmenities,
    this.country,
    this.address,
    this.rooms,
    this.reviewNr,
    this.reviewScore,
    this.postcode,
    this.reviewScoreWord,
    this.hotelName,
    this.stars,
  );

  factory HotelBean.fromJson(Map<String, dynamic> srcJson) =>
      _$HotelBeanFromJson(srcJson);
}

@JsonSerializable()
class Location {
  @JsonKey(name: 'latitude')
  String latitude;

  @JsonKey(name: 'longitude')
  String longitude;

  Location(
    this.latitude,
    this.longitude,
  );

  factory Location.fromJson(Map<String, dynamic> srcJson) =>
      _$LocationFromJson(srcJson);
}

@JsonSerializable()
class Checkin_time {
  @JsonKey(name: 'until')
  String until;

  @JsonKey(name: 'from')
  String from;

  Checkin_time(
    this.until,
    this.from,
  );

  factory Checkin_time.fromJson(Map<String, dynamic> srcJson) =>
      _$Checkin_timeFromJson(srcJson);
}

@JsonSerializable()
class Rooms {
  @JsonKey(name: 'room_amenities')
  List<String> roomAmenities;

  Rooms(
    this.roomAmenities,
  );

  factory Rooms.fromJson(Map<String, dynamic> srcJson) =>
      _$RoomsFromJson(srcJson);
}
