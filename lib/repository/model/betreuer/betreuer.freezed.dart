// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'betreuer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Betreuer {

 String get id; String get name; Gender get gender;
/// Create a copy of Betreuer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BetreuerCopyWith<Betreuer> get copyWith => _$BetreuerCopyWithImpl<Betreuer>(this as Betreuer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Betreuer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,gender);

@override
String toString() {
  return 'Betreuer(id: $id, name: $name, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $BetreuerCopyWith<$Res>  {
  factory $BetreuerCopyWith(Betreuer value, $Res Function(Betreuer) _then) = _$BetreuerCopyWithImpl;
@useResult
$Res call({
 String id, String name, Gender gender
});




}
/// @nodoc
class _$BetreuerCopyWithImpl<$Res>
    implements $BetreuerCopyWith<$Res> {
  _$BetreuerCopyWithImpl(this._self, this._then);

  final Betreuer _self;
  final $Res Function(Betreuer) _then;

/// Create a copy of Betreuer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? gender = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}

}


/// Adds pattern-matching-related methods to [Betreuer].
extension BetreuerPatterns on Betreuer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Betreuer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Betreuer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Betreuer value)  $default,){
final _that = this;
switch (_that) {
case _Betreuer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Betreuer value)?  $default,){
final _that = this;
switch (_that) {
case _Betreuer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Gender gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Betreuer() when $default != null:
return $default(_that.id,_that.name,_that.gender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Gender gender)  $default,) {final _that = this;
switch (_that) {
case _Betreuer():
return $default(_that.id,_that.name,_that.gender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Gender gender)?  $default,) {final _that = this;
switch (_that) {
case _Betreuer() when $default != null:
return $default(_that.id,_that.name,_that.gender);case _:
  return null;

}
}

}

/// @nodoc


class _Betreuer implements Betreuer {
  const _Betreuer({required this.id, required this.name, required this.gender});
  

@override final  String id;
@override final  String name;
@override final  Gender gender;

/// Create a copy of Betreuer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BetreuerCopyWith<_Betreuer> get copyWith => __$BetreuerCopyWithImpl<_Betreuer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Betreuer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,gender);

@override
String toString() {
  return 'Betreuer(id: $id, name: $name, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$BetreuerCopyWith<$Res> implements $BetreuerCopyWith<$Res> {
  factory _$BetreuerCopyWith(_Betreuer value, $Res Function(_Betreuer) _then) = __$BetreuerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Gender gender
});




}
/// @nodoc
class __$BetreuerCopyWithImpl<$Res>
    implements _$BetreuerCopyWith<$Res> {
  __$BetreuerCopyWithImpl(this._self, this._then);

  final _Betreuer _self;
  final $Res Function(_Betreuer) _then;

/// Create a copy of Betreuer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? gender = null,}) {
  return _then(_Betreuer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,
  ));
}


}

// dart format on
