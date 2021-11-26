class HiveBoxName {
  static const products = "products";
  static const timestamps = "timestamps";

  static const boxesThatShouldBeDeletedWhenSigningOut = [
    products,
    timestamps,
  ];
}
