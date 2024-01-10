import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_sea/models/user_model.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
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

class HomeController extends GetxController {
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
  dynamic abiJson;

  String? contractAddress =
      "0xbc98C4292CaB675B2359B52C7F84c2ba3b7E375D"; //deployed contract address
  DeployedContract? contract;
  ContractEvent? evnt;

  Web3Client? client;

  Uri? uri;
  double? balance = 0;
  EthereumAddress? manager;
  String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/hoA0bBbfP3K24FIS1RnOCLOK7ZFPCyy5";
  List<Player> players = [];

  @override
  void onInit() async {
    // rpcUrl = "${dotenv.env['ALCHEMY_URL']}";
    print("l;;;;;;;;;;;;;;;;;;;;;;");

    print(rpcUrl);
    client = Web3Client(rpcUrl, Client());

    await initData();
    // initialize();

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

  createNFT() async {
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
          gasPrice: gasPrice,
          // maxGas: gasLimit,
          contract: this.contract!,

          function: ethFunction,
          parameters: [
            "this is the text uri2",
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

  getAll() async {
    try {
      final ethFunction = contract!.function("getAllNftOfOwner");
      final result = await client?.call(
        contract: contract!,
        function: ethFunction,
        params: [],
      );
      // Check if the result is not null and has items
      if (result != null && result.isNotEmpty) {
        print(result);
        // Print the entire result for debugging
        print(result);

        // Access elements individually (assuming NFT has 'creator' property)
        for (var nftData in result) {
          print("Creator: ${nftData['creator']}");
          // Access other properties as needed
        }
      } else {
        print("No NFTs found.");
      }

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

  Future getTotalPlayers() async {
    try {
      final result = await client?.call(
          contract: contract!,
          function: contract!.function("getTotalMapping"),
          params: []);

      players.clear();

      if (result != null) {
        for (var element in result[0]) {
          final map = element.asMap();
          players.add(Player.fromMap(map));

          update();
        }
      }
    } catch (error) {
      Get.snackbar("Error", error.toString());
    }
  }

  getImage() async {
    imageFile = await picker.pickImage(source: ImageSource.gallery);
  }

  Future uploadtoIPFS() async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.pinata.cloud/pinning/pinFileToIPFS'),
    );

    // Add API key and secret to the headers
    request.headers.addAll({
      'pinata_api_key': "d30d41c4331b10e1b042",
      'pinata_secret_api_key':
          "d39931ed27c5bf956cb46c0e2e0dd292f8ea0dadf2e0b1cafa03def9a1f031e5",
    });

    // Attach the image file to the request with the field name "file"
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile!.path,
      ),
    );

    try {
      // Send the request
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();

      // Parse the JSON response
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      print("Response......................");
      print(responseBody);
      // Return the IPFS hash
      return jsonResponse['IpfsHash'];
    } catch (error) {
      print('Error uploading to Pinata: $error');
      return null;
    }
  }
}
