// Copyright 2020 The yjpark. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues, Offset;

import 'package:meta/meta.dart' show required;

import 'types.dart';

/// The position of the map "camera", the view point from which the world is shown in the map view.
///
/// Aggregates the camera's [target] geographical location, its [zoom] level,
/// [tilt] angle, and [bearing].
class CameraPosition {
  /// Creates a immutable representation of the [KakaoMap] camera.
  ///
  /// [AssertionError] is thrown if [bearing], [target], [tilt], or [zoom] are
  /// null.
  const CameraPosition({
    // this.bearing = 0.0,
    @required this.target,
    // this.tilt = 0.0,
    this.zoom = 0.0,
  })  :
        // assert(bearing != null),
        assert(target != null),
        // assert(tilt != null),
        assert(zoom != null);

  /// The camera's bearing in degrees, measured clockwise from north.
  ///
  /// A bearing of 0.0, the default, means the camera points north.
  /// A bearing of 90.0 means the camera points east.
  // final double bearing;

  /// The geographical location that the camera is pointing at.
  final MapPoint target;

  /// The angle, in degrees, of the camera angle from the nadir.
  ///
  /// A tilt of 0.0, the default and minimum supported value, means the camera
  /// is directly facing the Earth.
  ///
  /// The maximum tilt value depends on the current zoom level. Values beyond
  /// the supported range are allowed, but on applying them to a map they will
  /// be silently clamped to the supported range.
  // final double tilt;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  /// Serializes [CameraPosition].
  ///
  /// Mainly for internal use when calling [CameraUpdate.newCameraPosition].
  dynamic toMap() => <String, dynamic>{
        // 'bearing': bearing,
        'target': target.toJson(),
        // 'tilt': tilt,
        'zoom': zoom,
      };

  /// Deserializes [CameraPosition] from a map.
  ///
  /// Mainly for internal use.
  static CameraPosition fromMap(dynamic json) {
    if (json == null) {
      return null;
    }
    return CameraPosition(
      // bearing: json['bearing'],
      target: MapPoint.fromJson(json['target']),
      // tilt: json['tilt'],
      zoom: json['zoom'],
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraPosition typedOther = other;
    return
        // bearing == typedOther.bearing &&
        target == typedOther.target &&
            // tilt == typedOther.tilt &&
            zoom == typedOther.zoom;
  }

  @override
  // int get hashCode => hashValues(bearing, target, tilt, zoom);
  int get hashCode => hashValues(target, zoom);

  @override
  String toString() =>
      // 'CameraPosition(bearing: $bearing, target: $target, tilt: $tilt, zoom: $zoom)';
      'CameraPosition(target: $target, zoom: $zoom)';
}

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
class CameraUpdate {
  CameraUpdate._(this._json);

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return CameraUpdate._(
      <dynamic>['newCameraPosition', cameraPosition.toMap()],
    );
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static CameraUpdate newMapPoint(MapPoint mapPoint) {
    return CameraUpdate._(<dynamic>['newMapPoint', mapPoint.toJson()]);
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [padding] insets the bounding box from the
  /// map view's edges. The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newMapPointBounds(MapPointBounds bounds, double padding) {
    return CameraUpdate._(<dynamic>[
      'newMapPointBounds',
      bounds.toJson(),
      padding,
    ]);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static CameraUpdate newMapPointZoom(MapPoint mapPoint, double zoom) {
    return CameraUpdate._(
      <dynamic>['newMapPointZoom', mapPoint.toJson(), zoom],
    );
  }

  /// Returns a camera update that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static CameraUpdate scrollBy(double dx, double dy) {
    return CameraUpdate._(
      <dynamic>['scrollBy', dx, dy],
    );
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static CameraUpdate zoomBy(double amount, [Offset focus]) {
    if (focus == null) {
      return CameraUpdate._(<dynamic>['zoomBy', amount]);
    } else {
      return CameraUpdate._(<dynamic>[
        'zoomBy',
        amount,
        <double>[focus.dx, focus.dy],
      ]);
    }
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    return CameraUpdate._(<dynamic>['zoomIn']);
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    return CameraUpdate._(<dynamic>['zoomOut']);
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    return CameraUpdate._(<dynamic>['zoomTo', zoom]);
  }

  final dynamic _json;

  /// Converts this object to something serializable in JSON.
  dynamic toJson() => _json;
}
