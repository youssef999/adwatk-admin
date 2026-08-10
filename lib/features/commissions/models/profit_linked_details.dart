import '../../requests/models/accepted_offer_model.dart';
import '../../requests/models/shipment_offer_model.dart';
import '../../shipping_stores/models/shippiment_store_model.dart';
import 'payment_transaction_model.dart';

class ProfitLinkedDetails {
  const ProfitLinkedDetails({
    this.order,
    this.payment,
    this.shipmentOffer,
    this.shipmentCompany,
  });

  final AcceptedOfferModel? order;
  final PaymentTransactionModel? payment;
  final ShipmentOfferModel? shipmentOffer;
  final ShippimentStoreModel? shipmentCompany;

  bool get hasAny =>
      order != null ||
      payment != null ||
      shipmentOffer != null ||
      shipmentCompany != null;
}
