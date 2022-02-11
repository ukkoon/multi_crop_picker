enum RotationState { uninitialized, disabled, enabled }

class RotationGestureDetector {
  final double rotationDeadzone;
  final double scaleDeadzone;

  RotationGestureDetector(
      {this.rotationDeadzone = 0.15, this.scaleDeadzone = 0.25});

  RotationState _rotationState = RotationState.uninitialized;

  bool get isRotationEnabled => false;

  void onScaleUpdate(double rotation, double scale) {
    if (_rotationState == RotationState.uninitialized &&
        rotation.abs() > rotationDeadzone) {
      _rotationState = RotationState.enabled;
    }
    if (_rotationState == RotationState.uninitialized &&
        (scale - 1.0).abs() > scaleDeadzone) {
      _rotationState = RotationState.disabled;
    }
  }

  void onScaleEnd() {
    _rotationState = RotationState.uninitialized;
  }
}
