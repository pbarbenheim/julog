// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jugendlicher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Jugendlicher {

 String get id; String get name; Gender get gender; String? get pass; DateTime get birthDate; DateTime get memberSince; DateTime? get exitDate; int? get exitReason; Jugendlicher? get replacedBy;
/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JugendlicherCopyWith<Jugendlicher> get copyWith => _$JugendlicherCopyWithImpl<Jugendlicher>(this as Jugendlicher, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Jugendlicher&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pass, pass) || other.pass == pass)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&(identical(other.exitDate, exitDate) || other.exitDate == exitDate)&&(identical(other.exitReason, exitReason) || other.exitReason == exitReason)&&(identical(other.replacedBy, replacedBy) || other.replacedBy == replacedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,gender,pass,birthDate,memberSince,exitDate,exitReason,replacedBy);

@override
String toString() {
  return 'Jugendlicher(id: $id, name: $name, gender: $gender, pass: $pass, birthDate: $birthDate, memberSince: $memberSince, exitDate: $exitDate, exitReason: $exitReason, replacedBy: $replacedBy)';
}


}

/// @nodoc
abstract mixin class $JugendlicherCopyWith<$Res>  {
  factory $JugendlicherCopyWith(Jugendlicher value, $Res Function(Jugendlicher) _then) = _$JugendlicherCopyWithImpl;
@useResult
$Res call({
 String id, String name, Gender gender, String? pass, DateTime birthDate, DateTime memberSince, DateTime? exitDate, int? exitReason, Jugendlicher? replacedBy
});


$JugendlicherCopyWith<$Res>? get replacedBy;

}
/// @nodoc
class _$JugendlicherCopyWithImpl<$Res>
    implements $JugendlicherCopyWith<$Res> {
  _$JugendlicherCopyWithImpl(this._self, this._then);

  final Jugendlicher _self;
  final $Res Function(Jugendlicher) _then;

/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? gender = null,Object? pass = freezed,Object? birthDate = null,Object? memberSince = null,Object? exitDate = freezed,Object? exitReason = freezed,Object? replacedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,pass: freezed == pass ? _self.pass : pass // ignore: cast_nullable_to_non_nullable
as String?,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,memberSince: null == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime,exitDate: freezed == exitDate ? _self.exitDate : exitDate // ignore: cast_nullable_to_non_nullable
as DateTime?,exitReason: freezed == exitReason ? _self.exitReason : exitReason // ignore: cast_nullable_to_non_nullable
as int?,replacedBy: freezed == replacedBy ? _self.replacedBy : replacedBy // ignore: cast_nullable_to_non_nullable
as Jugendlicher?,
  ));
}
/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JugendlicherCopyWith<$Res>? get replacedBy {
    if (_self.replacedBy == null) {
    return null;
  }

  return $JugendlicherCopyWith<$Res>(_self.replacedBy!, (value) {
    return _then(_self.copyWith(replacedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Jugendlicher].
extension JugendlicherPatterns on Jugendlicher {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Jugendlicher value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Jugendlicher() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Jugendlicher value)  $default,){
final _that = this;
switch (_that) {
case _Jugendlicher():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Jugendlicher value)?  $default,){
final _that = this;
switch (_that) {
case _Jugendlicher() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Gender gender,  String? pass,  DateTime birthDate,  DateTime memberSince,  DateTime? exitDate,  int? exitReason,  Jugendlicher? replacedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Jugendlicher() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.pass,_that.birthDate,_that.memberSince,_that.exitDate,_that.exitReason,_that.replacedBy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Gender gender,  String? pass,  DateTime birthDate,  DateTime memberSince,  DateTime? exitDate,  int? exitReason,  Jugendlicher? replacedBy)  $default,) {final _that = this;
switch (_that) {
case _Jugendlicher():
return $default(_that.id,_that.name,_that.gender,_that.pass,_that.birthDate,_that.memberSince,_that.exitDate,_that.exitReason,_that.replacedBy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Gender gender,  String? pass,  DateTime birthDate,  DateTime memberSince,  DateTime? exitDate,  int? exitReason,  Jugendlicher? replacedBy)?  $default,) {final _that = this;
switch (_that) {
case _Jugendlicher() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.pass,_that.birthDate,_that.memberSince,_that.exitDate,_that.exitReason,_that.replacedBy);case _:
  return null;

}
}

}

/// @nodoc


class _Jugendlicher extends Jugendlicher {
  const _Jugendlicher({required this.id, required this.name, required this.gender, this.pass, required this.birthDate, required this.memberSince, this.exitDate, this.exitReason, this.replacedBy}): super._();
  

@override final  String id;
@override final  String name;
@override final  Gender gender;
@override final  String? pass;
@override final  DateTime birthDate;
@override final  DateTime memberSince;
@override final  DateTime? exitDate;
@override final  int? exitReason;
@override final  Jugendlicher? replacedBy;

/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JugendlicherCopyWith<_Jugendlicher> get copyWith => __$JugendlicherCopyWithImpl<_Jugendlicher>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Jugendlicher&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pass, pass) || other.pass == pass)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&(identical(other.exitDate, exitDate) || other.exitDate == exitDate)&&(identical(other.exitReason, exitReason) || other.exitReason == exitReason)&&(identical(other.replacedBy, replacedBy) || other.replacedBy == replacedBy));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,gender,pass,birthDate,memberSince,exitDate,exitReason,replacedBy);

@override
String toString() {
  return 'Jugendlicher(id: $id, name: $name, gender: $gender, pass: $pass, birthDate: $birthDate, memberSince: $memberSince, exitDate: $exitDate, exitReason: $exitReason, replacedBy: $replacedBy)';
}


}

/// @nodoc
abstract mixin class _$JugendlicherCopyWith<$Res> implements $JugendlicherCopyWith<$Res> {
  factory _$JugendlicherCopyWith(_Jugendlicher value, $Res Function(_Jugendlicher) _then) = __$JugendlicherCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Gender gender, String? pass, DateTime birthDate, DateTime memberSince, DateTime? exitDate, int? exitReason, Jugendlicher? replacedBy
});


@override $JugendlicherCopyWith<$Res>? get replacedBy;

}
/// @nodoc
class __$JugendlicherCopyWithImpl<$Res>
    implements _$JugendlicherCopyWith<$Res> {
  __$JugendlicherCopyWithImpl(this._self, this._then);

  final _Jugendlicher _self;
  final $Res Function(_Jugendlicher) _then;

/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? gender = null,Object? pass = freezed,Object? birthDate = null,Object? memberSince = null,Object? exitDate = freezed,Object? exitReason = freezed,Object? replacedBy = freezed,}) {
  return _then(_Jugendlicher(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,pass: freezed == pass ? _self.pass : pass // ignore: cast_nullable_to_non_nullable
as String?,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,memberSince: null == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime,exitDate: freezed == exitDate ? _self.exitDate : exitDate // ignore: cast_nullable_to_non_nullable
as DateTime?,exitReason: freezed == exitReason ? _self.exitReason : exitReason // ignore: cast_nullable_to_non_nullable
as int?,replacedBy: freezed == replacedBy ? _self.replacedBy : replacedBy // ignore: cast_nullable_to_non_nullable
as Jugendlicher?,
  ));
}

/// Create a copy of Jugendlicher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JugendlicherCopyWith<$Res>? get replacedBy {
    if (_self.replacedBy == null) {
    return null;
  }

  return $JugendlicherCopyWith<$Res>(_self.replacedBy!, (value) {
    return _then(_self.copyWith(replacedBy: value));
  });
}
}

// dart format on
