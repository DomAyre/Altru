class AltruRecipient {
  final String name;

  AltruRecipient({this.name});

  bool operator ==(other) => other.name == this.name;

  @override
  int get hashCode => this.name.hashCode;
}

abstract class AltruDonationInterface {
  Future<List<AltruRecipient>> getRecipients(int count);
}
