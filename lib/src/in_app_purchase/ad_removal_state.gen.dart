import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Represents the state of an in-app purchase of ad removal such as
/// [AdRemovalPurchase.notStarted()] or [AdRemovalPurchase.active()].

part 'ad_removal_state.gen.freezed.dart';

@freezed
class AdRemovalPurchaseState with _$AdRemovalPurchaseState {
  /// The representation of this product on the stores.
  static const productId = 'remove_ads';

  factory AdRemovalPurchaseState.notStarted() = _NotStarted;

  /// This is `true` when the purchase is pending.
  factory AdRemovalPurchaseState.pending() = _Pending;

  /// This is `true` if the `remove_ad` product has been purchased and verified.
  /// Do not show ads if so.
  factory AdRemovalPurchaseState.active() = _Active;

  /// If there was an error with the purchase, this field will contain
  /// that error.
  factory AdRemovalPurchaseState.error(Object error) = _Error;
}
