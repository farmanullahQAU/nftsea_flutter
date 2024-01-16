import 'package:web3dart/web3dart.dart';

class NFT {
  final EthereumAddress creator;
  final EthereumAddress? owner;
  final BigInt price;
  final String uri;
  bool isSold;

  NFT({
    required this.creator,
    required this.owner,
    required this.price,
    required this.uri,
    required this.isSold,
  });

  factory NFT.fromMap(dynamic map) {
    return NFT(
        creator: map[0] as EthereumAddress,
        owner: map[1] as EthereumAddress,
        price: map[2] as BigInt,
        uri: map[3] as String,
        isSold: map[4] as bool);
  }
}
