abstract class QuantityStrategy {
  int calculateQuantity(int baseQuantity);
}

class AddQuantityStrategy implements QuantityStrategy {
  @override
  int calculateQuantity(int baseQuantity) {
    return baseQuantity; // Adds quantity as-is
  }
}

class SubtractQuantityStrategy implements QuantityStrategy {
  @override
  int calculateQuantity(int baseQuantity) {
    return -baseQuantity; // Subtracts quantity
  }
}
