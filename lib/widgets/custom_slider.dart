//dotstudios

import 'package:flutter/material.dart';
import 'package:dottunes/style/shapes/md3_slider_thumb.dart';
import 'package:dottunes/widgets/squiggly_slider_track_shape.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({
    super.key,
    required this.value,
    this.secondaryTrackValue,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.squiggleAmplitude = 0.0,
    this.squiggleWavelength = 0.0,
    this.squiggleSpeed = 1.0,
    required this.isSquiglySliderEnabled,
  });

  final double value;
  final double? secondaryTrackValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? secondaryActiveColor;
  final Color? thumbColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final MouseCursor? mouseCursor;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final FocusNode? focusNode;
  final bool autofocus;
  final double squiggleAmplitude;
  final double squiggleWavelength;
  final double squiggleSpeed;
  final bool isSquiglySliderEnabled;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController phaseController;

  @override
  void initState() {
    super.initState();
    if (widget.isSquiglySliderEnabled) {
      if (widget.squiggleSpeed == 0) {
        phaseController = AnimationController(
          vsync: this,
        );
        phaseController.value = 0.5;
      } else {
        phaseController = AnimationController(
          duration: Duration(
            milliseconds: (1000.0 / widget.squiggleSpeed.abs()).round(),
          ),
          vsync: this,
        )
          ..repeat(min: 0, max: 1)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
      }
    }
  }

  @override
  void dispose() {
    if (widget.isSquiglySliderEnabled) phaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        inactiveTrackColor: widget.isSquiglySliderEnabled
            ? null
            : Theme.of(context).colorScheme.secondaryContainer,
        trackHeight: widget.isSquiglySliderEnabled ? null : 8,
        thumbShape: widget.isSquiglySliderEnabled
            ? null
            : Material3SliderThumb(
                borderColor: Theme.of(context).colorScheme.surface,
              ),
        trackShape: widget.isSquiglySliderEnabled
            ? SquigglySliderTrackShape(
                squiggleAmplitude: widget.squiggleAmplitude,
                squiggleWavelength: widget.squiggleWavelength,
                squigglePhaseFactor: widget.squiggleSpeed < 0
                    ? 1 - phaseController.value
                    : phaseController.value,
              )
            : const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        key: widget.key,
        value: widget.value,
        secondaryTrackValue: widget.secondaryTrackValue,
        onChanged: widget.onChanged,
        onChangeStart: widget.onChangeStart,
        onChangeEnd: widget.onChangeEnd,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
        secondaryActiveColor: widget.secondaryActiveColor,
        thumbColor: widget.thumbColor,
        overlayColor: widget.overlayColor,
        mouseCursor: widget.mouseCursor,
        semanticFormatterCallback: widget.semanticFormatterCallback,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
      ),
    );
  }
}
