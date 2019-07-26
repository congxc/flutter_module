// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotelResponseBean _$HotelResponseBeanFromJson(Map<String, dynamic> json) {
  return HotelResponseBean(
    json['status_code'] as int,
    json['status'] as String,
    (json['data'] as List)
        ?.map((e) =>
            e == null ? null : HotelBean.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$HotelResponseBeanToJson(HotelResponseBean instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'status': instance.status,
      'data': instance.data,
    };

HotelBean _$HotelBeanFromJson(Map<String, dynamic> json) {
  return HotelBean(
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['hotel_url'] as String,
    json['deep_link_url'] as String,
    json['hotel_id'] as int,
    json['cc_required'] as bool,
    json['default_language'] as String,
    (json['price'] as num)?.toDouble(),
    json['checkin_time'] == null
        ? null
        : Checkin_time.fromJson(json['checkin_time'] as Map<String, dynamic>),
    json['cvc_required'] as bool,
    json['hotel_currency_code'] as String,
    json['photo'] as String,
    (json['hotel_amenities'] as List)?.map((e) => e as String)?.toList(),
    json['country'] as String,
    json['address'] as String,
    (json['rooms'] as List)
        ?.map(
            (e) => e == null ? null : Rooms.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['review_nr'] as int,
    (json['review_score'] as num)?.toDouble(),
    json['postcode'] as String,
    json['review_score_word'] as String,
    json['hotel_name'] as String,
    json['stars'] as String,
  );
}

Map<String, dynamic> _$HotelBeanToJson(HotelBean instance) => <String, dynamic>{
      'location': instance.location,
      'hotel_url': instance.hotelUrl,
      'deep_link_url': instance.deepLinkUrl,
      'hotel_id': instance.hotelId,
      'cc_required': instance.ccRequired,
      'default_language': instance.defaultLanguage,
      'price': instance.price,
      'checkin_time': instance.checkinTime,
      'cvc_required': instance.cvcRequired,
      'hotel_currency_code': instance.hotelCurrencyCode,
      'photo': instance.photo,
      'hotel_amenities': instance.hotelAmenities,
      'country': instance.country,
      'address': instance.address,
      'rooms': instance.rooms,
      'review_nr': instance.reviewNr,
      'review_score': instance.reviewScore,
      'postcode': instance.postcode,
      'review_score_word': instance.reviewScoreWord,
      'hotel_name': instance.hotelName,
      'stars': instance.stars,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    json['latitude'] as String,
    json['longitude'] as String,
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Checkin_time _$Checkin_timeFromJson(Map<String, dynamic> json) {
  return Checkin_time(
    json['until'] as String,
    json['from'] as String,
  );
}

Map<String, dynamic> _$Checkin_timeToJson(Checkin_time instance) =>
    <String, dynamic>{
      'until': instance.until,
      'from': instance.from,
    };

Rooms _$RoomsFromJson(Map<String, dynamic> json) {
  return Rooms(
    (json['room_amenities'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$RoomsToJson(Rooms instance) => <String, dynamic>{
      'room_amenities': instance.roomAmenities,
    };
