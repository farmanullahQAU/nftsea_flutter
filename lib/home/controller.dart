import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nft_sea/models/nftModel.dart';
import 'package:http_parser/http_parser.dart';
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

  @override
  void onInit() async {
    // rpcUrl = "${dotenv.env['ALCHEMY_URL']}";
    print("l;;;;;;;;;;;;;;;;;;;;;;");

    print(rpcUrl);
    client = Web3Client(rpcUrl, Client());

    await initData();
    getMarketNfts();
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

  Future getMarketNfts() async {
    print("SSSSSSSSSSSSSSSSSsss");
    try {
      final ethFunction = contract!.function("totalNFTs");
      final result = await client?.call(
        contract: contract!,
        function: ethFunction,
        params: [],
      );

      if (result != null) {
        for (var element in result[0]) {
          final map = element.asMap();
          print("data is here");
          print(map);
          nfts.add(NFT.fromMap(map));

          update();
        }
      }
    } catch (error) {
      Get.snackbar("Error", error.toString());
    }
  }

  getImage() async {
    imageFile = await picker.pickImage(source: ImageSource.gallery);
    update();
  }

  uploadToPinata() async {
    await getImage();
    Map<String, dynamic> metadata = {
      'name': "The Art",
      'description': 'This is an another example NFT',
      // Add other metadata fields
    };

    // Upload image
    String? image = await _uploadImageToIPFS();
    if (image != null) {
      print('Image uploaded with CID: $image');

      // Update metadata with the image CID
      metadata['image'] = image;

      // Upload metadata
      String? metadataCID = await _uploadMetadataToIPFS(metadata);
      if (metadataCID != null) {
        print('Metadata uploaded with CID: $metadataCID');

        createNFT(metadataCID);
      }
    }
  }

  Future<String?> _uploadImageToIPFS() async {
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
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();

      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      // Return the IPFS hash
      return jsonResponse['IpfsHash'];
    } catch (error) {
      print('Error uploading to Pinata: $error');
    }
    return null;
  }

  // Future<String?> _uploadMetadataToIPFS(Map<String, dynamic> metadata) async {
  //   print("callllled");
  //   print(metadata);
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS'),
  //   );

  //   // Add Pinata API key and secret to the headers
  //   request.headers.addAll({
  //     'pinata_api_key': "d30d41c4331b10e1b042",
  //     'pinata_secret_api_key':
  //         "d39931ed27c5bf956cb46c0e2e0dd292f8ea0dadf2e0b1cafa03def9a1f031e5",
  //   });

  //   // Attach the metadata as a JSON file with the field name "file"
  //   request.files.add(
  //     http.MultipartFile.fromString(
  //       'file',
  //       jsonEncode(metadata),
  //       filename: 'metadata.json',
  //       contentType: MediaType('application', 'json'),
  //     ),
  //   );

  //   try {
  //     var response = await request.send();

  //     // Read the response
  //     var responseBody = await response.stream.bytesToString();

  //     // Parse the JSON response
  //     Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
  //     print(jsonResponse);
  //     // Return the IPFS hash for the metadata
  //     return jsonResponse['IpfsHash'];
  //   } catch (error) {
  //     print('Error uploading metadata to Pinata: $error');
  //     return null;
  //   }
  // }

  Future<String?> _uploadMetadataToIPFS(Map<String, dynamic> metadata) async {
    print("callllled");
    print(metadata);

    final Uri uri = Uri.parse('https://api.pinata.cloud/pinning/pinJSONToIPFS');

    try {
      final http.Response response = await http.post(
        uri,
        headers: {
          'pinata_api_key': "d30d41c4331b10e1b042",
          'pinata_secret_api_key':
              "d39931ed27c5bf956cb46c0e2e0dd292f8ea0dadf2e0b1cafa03def9a1f031e5",
          'Content-Type': 'application/json', // Ensure the content type is JSON
        },
        body: jsonEncode(metadata),
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        // Return the IPFS hash for the metadata
        return jsonResponse['IpfsHash'];
      } else {
        // If the request was not successful, print the error
        print(
            'Error uploading metadata to Pinata. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error uploading metadata to Pinata: $error');
      return null;
    }
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
}
