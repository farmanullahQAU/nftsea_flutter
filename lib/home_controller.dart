import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:nft_sea/models/user_model.dart';
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
  // late SignClient wcClient;
  // final ChainMetadata _chainMetadata = WalletConstants.sepoliaTestnetMetaData;
  final TextEditingController addressController = TextEditingController(
      text: "c7f086dbd0af7ff720fbc0e94e010863816a930b0dd28b3d145d14793cad5acd");

  final TextEditingController nameController = TextEditingController(text: "");
  final RxString greeting = ''.obs;
  RxBool isLoading = false.obs;
  dynamic abiJson;

  String? contractAddress =
      "0x609a78F41974ccFf53C2B6b23B6eB4A0B8613f6E"; //deployed contract address
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
        ContractAbi.fromJson(jsonEncode(abiJson), 'NFTSS'),
        EthereumAddress.fromHex(contractAddress!),
      );
      print("Abit string eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      print(contract?.address);
      //  listenToAddPlayerEvent();

      evnt = contract?.event("Added");

      listenToPickWinnerEvent();

      // await getTotalPlayers();
    } catch (err) {
      print("LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");
      Get.snackbar("Error", err.toString());
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
    final gasLimit = 21924; // adjust as needed
    try {
      final ethFunction = contract!.function("createNFT");
      EthPrivateKey credentials = EthPrivateKey.fromHex(
          "c7f086dbd0af7ff720fbc0e94e010863816a930b0dd28b3d145d14793cad5acd");

      final result = await client!.sendTransaction(
        credentials,
        Transaction.callContract(
          gasPrice: gasPrice,
          maxGas: gasLimit,
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

  createNFT2() async {
    try {
      final ethFunction = contract!.function("createNFT");

      final result = await client?.call(
        contract: contract!,
        function: ethFunction,
        params: [
          "test uri",
          BigInt.from(0.001 * 1000000000000000000),
        ],
      );
      print(result);
      // Handle the result as needed
    } catch (err) {
      Get.snackbar("Error", err.toString());
      print(err);
    }
  }

  getAll() async {
    try {
      final ethFunction = contract!.function("getAllNftOfOwner");
      print(this.contract?.address);
      final result = await client?.call(
        contract: contract!,
        function: ethFunction,
        params: [],
      );
      print("ssssssssssssssssssssssssssssssssss");
      print(result);
      // Check if the result is not null and has items
      if (result != null && result.isNotEmpty) {
        print("lllllllllllllllllllllllll");
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

  listenToPickWinnerEvent() {
    client
        ?.events(FilterOptions.events(
          contract: contract!,
          event: evnt!,
        ))
        .take(1)
        .listen((event) {
      print("EEEEEEEEEEEEEEEEEEEE");

      print(event);
      final decoded = evnt?.decodeResults(event.topics!, event.data!);

      final map = decoded![0].asMap();
      print("SSSSSssssssssssssssssssssss");
      print(map);
    });
  }

  Future<String> contractFunction(String functionName, List<dynamic> args,
      String key, EtherAmount? contribution) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(key);
    final ethFunction = contract!.function(functionName);

    // final maxGas=await getEstimatedGasLimit(credentials);

    final result = await client!.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract!,
          function: ethFunction,
          parameters: args,
          value: contribution,
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    update();
    return result;
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

  enterLottery() async {
    isLoading.value = true;

    try {
      final value = EtherAmount.inWei(BigInt.from(1e15));
      await contractFunction(
          "enter", [nameController.text], addressController.text, value);

      Get.snackbar("Success", "You have been added to the lottery");
    } catch (error) {
      Get.snackbar("Error", error.toString());
    }

    isLoading.value = false;
    update();
  }
/*
  Future<bool> initialize() async {
    bool isInitialize = false;
    try {
      wcClient = await SignClient.createInstance(
        relayUrl: _chainMetadata.relayUrl,
        projectId: _chainMetadata.projectId,
        metadata: PairingMetadata(
            name: "MetaMask",
            description: "MetaMask login",
            url: _chainMetadata.walletConnectUrl,
            icons: ["https://wagmi.sh/icon.png"],
            redirect: Redirect(universal: _chainMetadata.redirectUrl)),
      );
      isInitialize = true;
    } catch (err) {
      debugPrint("Catch wallet initialize error $err");
    }
    return isInitialize;
  }

  Future<ConnectResponse?> connect() async {
    try {
      ConnectResponse? resp = await wcClient.connect(requiredNamespaces: {
        _chainMetadata.type: RequiredNamespace(
          chains: [_chainMetadata.chainId], // Ethereum chain
          methods: [_chainMetadata.method], // Requestable Methods
          events: _chainMetadata.events, // Requestable Events
        )
      });

      return resp;
    } catch (err) {
      debugPrint("Catch wallet connect error $err");
    }
    return null;
  }

  Future<SessionData?> authorize(
      ConnectResponse resp, String unSignedMessage) async {
    SessionData? sessionData;
    try {
      sessionData = await resp.session.future;

      print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSsss");
    } catch (err) {
      debugPrint("Catch wallet authorize error $err");
    }
    return sessionData;
  }

  Future<String?> sendMessageForSigned(ConnectResponse resp,
      String walletAddress, String topic, String unSignedMessage) async {
    print("TTTTTTTTTTTTTTTTTTTTTTTTTTTttoooooooooooooo");
    print(topic);

    // Construct the transaction data for entering the lottery
    // final transactionData = Transaction.callContract(

    //   from: EthereumAddress.fromHex(walletAddress),

    //   contract: contract!,
    //   function: contract!.function('enter'),

    //   parameters: [ "Asif"],

    // );
    String? signature;

    try {
      final transactionData = Transaction.callContract(
          from: EthereumAddress.fromHex(walletAddress),
          contract: this.contract!,
          function: contract!
              .function('enter'), // Adjust based on your contract's function
          parameters: [
            "Aslif "
          ], // Adjust based on your contract's function parameters

          value: EtherAmount.inWei(BigInt.from(1e15)));
      print("Trrrrrrrrrrrrrraaaaaaaaaaaaaaaaaaaaaaaannnnnnnnnnnnnnnn");
      print(transactionData);
      String paramJson = '0x${hex.encode(transactionData.data!)}';
      Uri? uri = resp.uri;
      if (uri != null) {
        // Now that you have a session, you can request signatures
        final res = await this.wcClient.request(
              topic: topic,
              chainId: _chainMetadata.chainId,
              request: SessionRequestParams(
                method: 'eth_sendTransaction',
                params: [
                  // unSignedMessage,walletAddress
                  // transactionData.data,

                  {
                    'from': transactionData.from?.hex,
                    'to': EthereumAddress.fromHex(contractAddress!).hex,
                    'value':
                        '0x${transactionData.value?.getInWei.toRadixString(16)}', // Convert to hex string
                    'gas': '53552', // Adjust gas as needed
                    // 'gasPrice': '20000000000', // Adjust gas price as needed
                    'data': paramJson
                  },
                ],
              ),
            );

        print(
            "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRr");
        print(resp.toString());
        signature = res.toString();
      }
    } catch (err) {
      debugPrint(
          "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEeee");
      debugPrint("Catch SendMessageForSigned error $err");
    }
    return signature;
  }

  Future<bool> onDisplayUri(Uri? uri) async {
    final link =
        formatNativeUrl(WalletConstants.deepLinkMetamask, uri.toString());
    var url = link.toString();
    if (!await canLaunchUrlString(url)) {
      return false;
    }
    return await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  Future<void> disconnectWallet({required String topic}) async {
    await wcClient.disconnect(
        topic: topic, reason: Errors.getSdkError(Errors.USER_DISCONNECTED));
  }

  WalletStatus? state;

  void metamaskAuth() async {
    state = WalletStatus.initializing;
    bool isInitialize = await initialize();

    if (isInitialize) {
      state = WalletStatus.initialized;

      ConnectResponse? resp = await connect();

      if (resp != null) {
        Uri? uri = resp.uri;

        if (uri != null) {
          bool canLaunch = await onDisplayUri(uri);

          if (!canLaunch) {
            state = WalletStatus.notInstalled;
          } else {
            SessionData? sessionData = await authorize(
                resp, "this is the unsizgned mesagevvvvvvvvvvvvvvvvvvvvv");

            if (sessionData != null) {
              state = WalletStatus.successful;

              if (resp.session.isCompleted) {
                final String walletAddress = NamespaceUtils.getAccount(
                  sessionData.namespaces.values.first.accounts.first,
                );

                debugPrint(
                    "WALLET ADDRESSsssssssssssssssssssssssssssss - $walletAddress");

                bool canLaunch = await onDisplayUri(uri);

                if (!canLaunch) {
                  state = WalletStatus.notInstalled;
                } else {
                  final signatureFromWallet = await sendMessageForSigned(
                    resp,
                    walletAddress,
                    sessionData.topic,
                    this.contractAddress!,
                  );

                  if (signatureFromWallet != null &&
                      signatureFromWallet != "") {
                    // _state.value = WalletReceivedSignatureState(
                    //   signatureFromWallet: signatureFromWallet,
                    //   signatureFromBk: signatureFromBackend,
                    //   walletAddress: walletAddress,
                    //   message: AppConstants.authenticatingPleaseWait,
                    // );

                    print("lllllllllllllllllllllllllllllllllllllllllllll");
                    print(signatureFromWallet);

                    state = WalletStatus.receivedSignature;
                  } else {
                    state = WalletStatus.userdenied;
                  }

                  disconnectWallet(topic: sessionData.topic);
                }
              }
            } else {
              state = WalletStatus.userdenied;
            }
          }
        }
      }
    } else {
      state = WalletStatus.connectError;
    }

    update();
  }
}

class ChainMetadata {
  final String chainId;
  final String name;
  final String type;
  final String method;
  final List<String> events;
  final String relayUrl;
  final String projectId;
  final String redirectUrl;
  final String walletConnectUrl;

  const ChainMetadata({
    required this.chainId,
    required this.name,
    required this.type,
    required this.method,
    required this.events,
    required this.relayUrl,
    required this.projectId,
    required this.redirectUrl,
    required this.walletConnectUrl,
  });

  */
}
