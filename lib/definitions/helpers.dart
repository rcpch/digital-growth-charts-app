String getMeasurementMethodLabel(String? measurementMethod){

  if (measurementMethod == 'height') {
    return "Height";
  }
  else if (measurementMethod == 'weight') {
    return "Weight";
  }
  else if (measurementMethod == 'ofc') {
    return "Head Circumference";
  }
  else if (measurementMethod == 'bmi') {
    return "BMI";
  } else {
    return "";
  }
}

String getMeasurementMethodUnits(String? measurementMethod) {
  if (measurementMethod == 'height') {
    return "cm";
  }
  else if (measurementMethod == 'weight') {
    return "kg";
  }
  else if (measurementMethod == 'ofc') {
    return "cm";
  }
  else if (measurementMethod == 'bmi') {
    return "kg/m²";
  } else {
    return "";
  }
}