import 'dart:convert';

import 'package:convert/convert.dart'; // Import the 'convert' package for hex encoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

enum WalletStatus {
  initializing,
  connected,
  notInstalled,
  successful,
  authenticating,
  userdenied,
  connectError,
  receivedSignature
}

class WalletServices extends GetxService {
  WalletStatus? currentState;

  SignClient? wcClient;
  final ChainMetadata _chainMetadata =
      WalletConstants().getSepoliaTestnetMetaData();

  SessionData? sessionData;

  Web3Client? client;
  Uri? uri;
  @override
  void onInit() {
    initWallet();
    super.onInit();
  }
  // Future<bool> onDisplayUri(Uri? uri) async {
  //   final link =
  //       formatNativeUrl(WalletConstants.deepLinkMetamask, uri.toString());
  //   var url = link.toString();
  //   if (!await canLaunchUrlString(url)) {
  //     return false;
  //   }
  //   return await launchUrlString(url);
  // }

  Future<void> disconnectWallet({required String topic}) async {
    await wcClient?.disconnect(
        topic: topic, reason: Errors.getSdkError(Errors.USER_DISCONNECTED));
  }

  WalletStatus? state;

  initWallet() async {
    wcClient = await SignClient.createInstance(
      relayUrl: _chainMetadata.relayUrl,
      projectId: _chainMetadata.projectId,
      metadata: PairingMetadata(
        name: "MetaMask",
        description: "MetaMask login",
        url: _chainMetadata.walletConnectUrl,
        icons: ["https://wagmi.sh/icon.png"],
        // redirect: Redirect(universal: _chainMetadata.redirectUrl)
      ),
    );

    getActiveSession();
  }

  SessionData? getActiveSession() {
    final data = wcClient?.getActiveSessions();
    if (data!.isNotEmpty) {
      wcClient?.getActiveSessions();
      return data.values.first;

      // return    NamespaceUtils.getAccount(
      //     sessionData!.namespaces.values.first.accounts.first,
      //   );
    }
    return null;
  }

  connectMetamask(ChainMetadata metadata) async {
    try {
      ConnectResponse? resp = await wcClient?.connect(requiredNamespaces: {
        metadata.type: RequiredNamespace(
          chains: [metadata.chainId], // Ethereum chain
          methods: [metadata.method], // Requestable Methods
          events: metadata.events, // Requestable Events
        )
      });

      uri = resp?.uri;

      if (uri != null) {
        // bool canLaunch = await onDisplayUri(uri);

        await launchUrl(uri!);

        sessionData = await resp?.session.future;

        if (resp!.session.isCompleted) {
          // _connectedAddress = NamespaceUtils.getAccount(
          //   sessionData!.namespaces.values.first.accounts.first,
          // );

          // enterToLottery();

          wcClient?.onSessionDelete.subscribe((args) {
            print(args);
            print("dddddddddddddddddddddddddddddddddddddd");
          });
        }
      }
    } catch (err) {
      debugPrint("Catch wallet connect error $err");
    }
  }

  personalSignin(
      {required SessionData sessionData,
      required EthereumAddress contractAddress,
      required ChainMetadata metadata}) async {
    if (uri != null) {
      await launchUrl(uri!);
    }
    await wcClient?.request(
      topic: sessionData.topic,
      chainId: metadata.chainId,
      request: SessionRequestParams(
        method: metadata.method,

        // {
        //   "to": NamespaceUtils.getAccount(
        //     sessionData.namespaces.values.first.accounts.first,
        //   ),
        //   "from": contractAddress.hex
        //   //7/// "data":  '0x${hex.(transactionData.data!)}'
        // }

        params: [
          "this is the sign message",
          NamespaceUtils.getAccount(
            sessionData.namespaces.values.first.accounts.first,
          ),
        ],
      ),
    );
  }
/*
  switchNetwork(ConnectResponse resp) async {
    final AuthRequestResponse authReq = await wcClient!
        .requestAuth(
      params: AuthRequestParams(
        aud: 'http://walletconnect.com/login',
        domain: 'http://walletconnect.com',
        chainId: _chainMetadata.chainId,
        statement: 'Sign in with your wallet!',
      ),
      pairingTopic: resp.pairingTopic,
    )
        .catchError((err) {
      print("JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ");
      print(err);
      Get.snackbar("auth error ", err.toString());
    });

// Await the auth response using the provided completer
    final AuthResponse authResponse = await authReq.completer.future;
    if (authResponse.result != null) {
      print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRrrr");
      // Having a result means you have the signature and it is verified.

      // Retrieve the wallet address from a successful response
      final walletAddress =
          AddressUtils.getDidAddress(authResponse.result!.p.iss);
      print("sssssssssssssssssssssssssssssssssssssssss");
      print(walletAddress);

      wcClient!.registerEventHandler(
        chainId: _chainMetadata.chainId,
        event: 'accountsChanged',
      );
      wcClient!.onSessionEvent.subscribe((SessionEvent? session) {
        print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        print(session);
      });
    } else {
      // Otherwise, you might have gotten a WalletConnectError if there was un issue verifying the signature.
      final WalletConnectError? error = authResponse.error;
      // Of a JsonRpcError if something went wrong when signing with the wallet.
      final JsonRpcError? err = authResponse.jsonRpcError;
      print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEeeee");
      print(err);
      print(error);
    }

    // await wcClient?.request(
    //   topic: sessionData!.topic,
    //   chainId: _chainMetadata.chainId,
    //   request: const SessionRequestParams(
    //     method: 'wallet_switchEthereumChain',
    //     params: [
    //       // unSignedMessage,walletAddress
    //       // transactionData.data,
    //     ],
    //   ),
  }

  */

/*al connectResponse = await _web3app!.connect(
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:11155111'],
          // Not every method may be needed for your purposes
          methods: [
            // "personal_sign",
            "eth_sendTransaction",
            // "eth_accounts",
            // "eth_requestAccounts",
            // "eth_sendRawTransaction",
            // "eth_sign",
            // "eth_signTransaction",
            // "eth_signTypedData",
            // "eth_signTypedData_v3",
            // "eth_signTypedData_v4",
            // "wallet_switchEthereumChain",
            // "wallet_addEthereumChain",
            // "wallet_getPermissions",
            // "wallet_requestPermissions",
            // "wallet_registerOnboarding",
            // "wallet_watchAsset",
            // "wallet_scanQRCode",
          ],
          // Not every event may be needed for your purposes
          events: [
            // "chainChanged",
            // "accountsChanged",
            // "message",
            // "disconnect",
            // "connect",
          ],
        ),
      },
    ); */
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
}

class WalletConstants {
  static const mainChainMetaData = ChainMetadata(
    type: "eip155",
    chainId: 'eip155:1',
    name: 'Ethereum',
    method: "personal_sign",
    events: ["chainChanged", "accountsChanged"],
    relayUrl: "wss://relay.walletconnect.com",
    projectId: "68ccdce69aec001e3cd0b33aec530b81",
    redirectUrl: "metamask://com.example.metamask_login_blog",
    walletConnectUrl: "https://walletconnect.com",
  );

  static const deepLinkMetamask = "metamask://wc?uri=";

  ChainMetadata getSepoliaTestnetMetaData({
    String? chainId = 'eip155:11155111',
    String type = "eip155",
    String? method = "personal_sign",
  }) {
    return ChainMetadata(
      type: type,
      chainId:
          chainId!, // Assuming Sepolia testnet has chainId 42, replace it with the correct value if different
      name: 'Sepolia Testnet',
      method: method!,
      events: ["chainChanged", "accountsChanged"],
      relayUrl: "wss://relay.walletconnect.com",
      projectId: "68ccdce69aec001e3cd0b33aec530b81",
      redirectUrl: "metamask://com.example.metamask_login_blog",
      walletConnectUrl: "https://walletconnect.com",
    );
  }
}
