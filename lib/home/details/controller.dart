import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:nft_sea/models/nftModel.dart';
import 'package:nft_sea/services/walletconnect.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
// import 'package:nft_sea/utils/constants/wallet_constants.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
// import 'package:convert/convert.dart'; // Import the 'convert' package for hex encoding

import 'package:web3dart/web3dart.dart';
// enum WalletStatus {
//   initializing,
//   initialized,
//   notInstalled,
//   successful,
//   authenticating,
//   userdenied,
//   connectError,
//   receivedSignature
// }

class NftDetailsViewController extends GetxController {
  late NFT nft;
  bool isMessageSigned = false;

  SessionData? sessionData;
  final ImagePicker picker = ImagePicker();
// Pick an image.
  // late SignClient wcClient;
  // final ChainMetadata _chainMetadata = WalletConstants.sepoliaTestnetMetaData;
  final TextEditingController addressController = TextEditingController(
      text: "c7f086dbd0af7ff720fbc0e94e010863816a930b0dd28b3d145d14793cad5acd");

  final TextEditingController nameController = TextEditingController(text: "");
  final RxString greeting = ''.obs;
  RxBool isLoading = false.obs;
  XFile? imageFile;
  String? connectedAddress;
  dynamic abiJson;

  String? contractAddress =
      "0xB25dc9680Ac17D12F03E7b654c956aCD679f76Bd"; //deployed contract address
  DeployedContract? contract;
  ContractEvent? evnt;

  Web3Client? client;

  Uri? uri;
  double? balance = 0;
  EthereumAddress? manager;
  String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/hoA0bBbfP3K24FIS1RnOCLOK7ZFPCyy5";
  List<NFT> nfts = [];

  ScrollController? scrollController;

  @override
  void onInit() async {
    scrollController = ScrollController();
    //)
    this.nft = Get.arguments;
    // rpcUrl = "${dotenv.env['ALCHEMY_URL']}";
    print("l;;;;;;;;;;;;;;;;;;;;;;");

    print(rpcUrl);
    client = Web3Client(rpcUrl, Client());

    await initData();
    _getActiveSession();
    super.onInit();
  }

  Future initData() async {
    try {
      final abiString = await rootBundle.loadString("assets/NFTsea.json");

      abiJson = jsonDecode(abiString);

      contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abiJson["abi"]), 'NFTSS'),
        EthereumAddress.fromHex(contractAddress!),
      );
    } catch (err) {
      Get.snackbar("eeeeeeeeeerrrr", err.toString());
    }
  }

  displ() {
    BigInt weiPerEther = BigInt.from(1000000000000000000); // 1 ETH in Wei

// Function to convert any double Ether value to Wei

    // Ensure accuracy by multiplying with a BigInt with 18 decimal places
    final scaledEtherAmount = BigInt.from(0.001 * 1000000000000000000);

    print(scaledEtherAmount);
  }

  createNFT(String uri) async {
    final gasPrice =
        EtherAmount.inWei(BigInt.from(50000000000)); // adjust as needed
    // final gasLimit = 21924; // adjust as needed
    try {
      final ethFunction = contract!.function("createNFT");
      EthPrivateKey credentials = EthPrivateKey.fromHex(
          "c7f086dbd0af7ff720fbc0e94e010863816a930b0dd28b3d145d14793cad5acd");

      final result = await client!.sendTransaction(
        credentials,
        Transaction.callContract(
          // gasPrice: gasPrice,
          // maxGas: gasLimit,
          contract: this.contract!,

          function: ethFunction,
          parameters: [
            uri,
            BigInt.from(0.001 * 1000000000000000000)
          ], // Adjust parameters accordingly
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );

      print(result.toString());
      Get.snackbar("deployed", result.toString());

      // Handle the result as needed
    } catch (err) {
      Get.snackbar("Error", err.toString());
      print(err);
    }
  }

  Future<BigInt> getEstimatedGasLimit(Credentials credentials) async {
    return await client!.estimateGas(
      sender: credentials.address,
    );
  }

  Future<Map<String, dynamic>?> getMetadataFromIPFS(String metadataCID) async {
    try {
      final Uri uri = Uri.parse('https://ipfs.io/ipfs/$metadataCID');

      final http.Response response = await http.get(uri);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return jsonResponse;
      } else {
        // If the request was not successful, print the error
        print(
            'Error fetching metadata from IPFS. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching metadata from IPFS: $error');
      return null;
    }
  }

  double convertWeiToEther(BigInt wei) {
    EtherAmount etherAmount = EtherAmount.inWei(wei);
    return etherAmount.getValueInUnit(EtherUnit.ether);
  }

  _getActiveSession() {
    sessionData = Get.find<WalletServices>().getActiveSession();
    update();
    // sessionData = Get.find<WalletServices>().getActiveSession();
  }

  EthereumAddress? connectedAccountAddress() {
    if (sessionData != null) {
      return EthereumAddress.fromHex(NamespaceUtils.getAccount(
        sessionData!.namespaces.values.first.accounts.first,
      ));
    } else {
      return null;
    }
  }

  contrinue() {
    if (this.sessionData?.namespaces.isEmpty ?? true) {
      _connectMetamask();
    } else {
      print("SSSSSSSSSSSSSSSSSss");
      _signMessage();
    }
  }

  _connectMetamask() async {
    await Get.find<WalletServices>()
        .connectMetamask(WalletConstants.mainChainMetaData);
    _getActiveSession();
  }

  _signMessage() async {
    await Get.find<WalletServices>().personalSignin(
        sessionData: this.sessionData!,
        metadata: WalletConstants()
            .getSepoliaTestnetMetaData(method: "personal_sign"),
        contractAddress: EthereumAddress.fromHex(contractAddress!));

    this.isMessageSigned = true;
    update();
  }
}
