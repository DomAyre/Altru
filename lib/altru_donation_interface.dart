class AltruRecipient {
  final int id;
  final String name;

  AltruRecipient({this.id, this.name});

  bool operator ==(other) => other.name == this.name && other.id == this.id;

  @override
  int get hashCode => this.name.hashCode;
}

abstract class AltruDonationInterface {
  Future<List<AltruRecipient>> getRecipients(int count);
}
