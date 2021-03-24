class ChargeTypeConstants {
  static const String FLAT = "FLAT";
  static const String PERCENTAGE = "PERCENTAGE";
}

class ChargeNameConstants {
  static const String DELIVERY = "DELIVERY";
  static const String TAX = "TAX";
  static const String PACKING = "PACKING";
  static const String EXTRA = "EXTRA";
}

class EsOrderChargesModel {
  String chargeType;
  String chargeName;
  int chargeValue;
  String chargeState;

  EsOrderChargesModel({
    this.chargeState,
    this.chargeName,
    this.chargeType,
    this.chargeValue,
  });

  EsOrderChargesModel.fromJson(Map<String, dynamic> json) {
    chargeValue = json["charge_value"];
    chargeName = json["charge_name"];
    chargeType = json["charge_type"];
    chargeState = json["charge_state"];
  }

  String get dChargeName {
    switch (this.chargeName) {
      case ChargeNameConstants.DELIVERY:
        return "Delivery Charge";

      case ChargeNameConstants.TAX:
        return "Service Charge";

      case ChargeNameConstants.PACKING:
        return "Packing Charge";

      case ChargeNameConstants.EXTRA:
        return "Other Charges";
      default:
        return "";
    }
  }

  String get dChargeValue {
    if (this.chargeType == ChargeTypeConstants.PERCENTAGE) {
      return this.chargeValue.toString();
    }
    return (this.chargeValue / 100).toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['charge_value'] = this.chargeValue;
    data['charge_name'] = this.chargeName;
    data['charge_type'] = this.chargeType;
    data['charge_state'] = this.chargeState;
    return data;
  }
}
