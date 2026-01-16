// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'julog_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JulogFile {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JulogFile);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JulogFile()';
}


}

/// @nodoc
class $JulogFileCopyWith<$Res>  {
$JulogFileCopyWith(JulogFile _, $Res Function(JulogFile) __);
}


/// Adds pattern-matching-related methods to [JulogFile].
extension JulogFilePatterns on JulogFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( JulogFileNone value)?  none,TResult Function( JulogFileLoaded value)?  loaded,TResult Function( JulogFileLoading value)?  loading,TResult Function( JulogFileClosed value)?  closed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case JulogFileNone() when none != null:
return none(_that);case JulogFileLoaded() when loaded != null:
return loaded(_that);case JulogFileLoading() when loading != null:
return loading(_that);case JulogFileClosed() when closed != null:
return closed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( JulogFileNone value)  none,required TResult Function( JulogFileLoaded value)  loaded,required TResult Function( JulogFileLoading value)  loading,required TResult Function( JulogFileClosed value)  closed,}){
final _that = this;
switch (_that) {
case JulogFileNone():
return none(_that);case JulogFileLoaded():
return loaded(_that);case JulogFileLoading():
return loading(_that);case JulogFileClosed():
return closed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( JulogFileNone value)?  none,TResult? Function( JulogFileLoaded value)?  loaded,TResult? Function( JulogFileLoading value)?  loading,TResult? Function( JulogFileClosed value)?  closed,}){
final _that = this;
switch (_that) {
case JulogFileNone() when none != null:
return none(_that);case JulogFileLoaded() when loaded != null:
return loaded(_that);case JulogFileLoading() when loading != null:
return loading(_that);case JulogFileClosed() when closed != null:
return closed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( Jldb jldb)?  loaded,TResult Function()?  loading,TResult Function()?  closed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case JulogFileNone() when none != null:
return none();case JulogFileLoaded() when loaded != null:
return loaded(_that.jldb);case JulogFileLoading() when loading != null:
return loading();case JulogFileClosed() when closed != null:
return closed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( Jldb jldb)  loaded,required TResult Function()  loading,required TResult Function()  closed,}) {final _that = this;
switch (_that) {
case JulogFileNone():
return none();case JulogFileLoaded():
return loaded(_that.jldb);case JulogFileLoading():
return loading();case JulogFileClosed():
return closed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( Jldb jldb)?  loaded,TResult? Function()?  loading,TResult? Function()?  closed,}) {final _that = this;
switch (_that) {
case JulogFileNone() when none != null:
return none();case JulogFileLoaded() when loaded != null:
return loaded(_that.jldb);case JulogFileLoading() when loading != null:
return loading();case JulogFileClosed() when closed != null:
return closed();case _:
  return null;

}
}

}

/// @nodoc


class JulogFileNone implements JulogFile {
  const JulogFileNone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JulogFileNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JulogFile.none()';
}


}




/// @nodoc


class JulogFileLoaded implements JulogFile {
  const JulogFileLoaded({required this.jldb});
  

 final  Jldb jldb;

/// Create a copy of JulogFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JulogFileLoadedCopyWith<JulogFileLoaded> get copyWith => _$JulogFileLoadedCopyWithImpl<JulogFileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JulogFileLoaded&&(identical(other.jldb, jldb) || other.jldb == jldb));
}


@override
int get hashCode => Object.hash(runtimeType,jldb);

@override
String toString() {
  return 'JulogFile.loaded(jldb: $jldb)';
}


}

/// @nodoc
abstract mixin class $JulogFileLoadedCopyWith<$Res> implements $JulogFileCopyWith<$Res> {
  factory $JulogFileLoadedCopyWith(JulogFileLoaded value, $Res Function(JulogFileLoaded) _then) = _$JulogFileLoadedCopyWithImpl;
@useResult
$Res call({
 Jldb jldb
});




}
/// @nodoc
class _$JulogFileLoadedCopyWithImpl<$Res>
    implements $JulogFileLoadedCopyWith<$Res> {
  _$JulogFileLoadedCopyWithImpl(this._self, this._then);

  final JulogFileLoaded _self;
  final $Res Function(JulogFileLoaded) _then;

/// Create a copy of JulogFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? jldb = null,}) {
  return _then(JulogFileLoaded(
jldb: null == jldb ? _self.jldb : jldb // ignore: cast_nullable_to_non_nullable
as Jldb,
  ));
}


}

/// @nodoc


class JulogFileLoading implements JulogFile {
  const JulogFileLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JulogFileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JulogFile.loading()';
}


}




/// @nodoc


class JulogFileClosed implements JulogFile {
  const JulogFileClosed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JulogFileClosed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JulogFile.closed()';
}


}




// dart format on
