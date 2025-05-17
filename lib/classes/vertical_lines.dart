import 'package:flutter/material.dart';
import '../themes/colours.dart';

class VerticalUKWHOLine{
  String comment;
  double decimal_age;
  Color? lineColor;
  Color? labelColor;

  VerticalUKWHOLine({required this.comment, required this.decimal_age, this.lineColor, this.labelColor});
}

List<VerticalUKWHOLine> ukWHOVerticalLinesBaseData = [
  VerticalUKWHOLine(
    decimal_age: 0.0383,
    comment: "Transition from UK90 to WHO",
    lineColor: transitionLineColour,
    labelColor: transitionLineColour,
  ),
  VerticalUKWHOLine(
    decimal_age: 2.0,
    comment: "Measure length until 2 yrs of age. Measure height from 2 yrs of age. A child's height is always slightly less than their length.",
    lineColor: transitionLineColour,
    labelColor: transitionLineColour,
  ),
];

List<VerticalUKWHOLine> boyPubertalCutoffs = [
  VerticalUKWHOLine(
      decimal_age: 9.0,
      comment: "Puberty starting before 9 y is precocious.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  ),
  VerticalUKWHOLine(
      decimal_age: 14.0,
      comment: "Puberty is delayed if no signs are present by 14 years.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  ),
  VerticalUKWHOLine(
      decimal_age: 17.0,
      comment: "Puberty completing after 17y is delayed.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  )
];

List<VerticalUKWHOLine> girlPubertalCutoffs = [
  VerticalUKWHOLine(
      decimal_age: 8.0,
      comment: "Puberty starting before 98 y is precocious.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  ),
  VerticalUKWHOLine(
      decimal_age: 13.0,
      comment: "Puberty is delayed if no signs are present by 13 years.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  ),
  VerticalUKWHOLine(
      decimal_age: 16.0,
      comment: "Puberty completing after 16y is delayed.",
      lineColor: transitionLineColour,
      labelColor: transitionLineColour
  )
];