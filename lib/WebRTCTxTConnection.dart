import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCTxTConnection {
  late RTCPeerConnection peerConnection;
  late RTCDataChannel dataChannel;
  late RTCSessionDescription sdp; // Local Description (offer/answer)

  /// Constraints for the local description (offer/answer)
  /// Used when in createOffer() and createAnswer() methods
  final _OFLocalDescriptionConstrains = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  /// Creates a new RTCPeerConnection (peerConnection)
  /// Creates a new RTCDataChannel (dataChannel)
  /// Creates a LOCAL description (offer) which is later copied to the clipboard
  Future<void> offerConnection() async {
    // RTCPeerConnection
    peerConnection = await _createPeerConnection();

    // RTCDataChannel
    await createRTCDataChannel();

    // Local RTCSessionDescription (offer)
    RTCSessionDescription offer =
        await peerConnection.createOffer(_OFLocalDescriptionConstrains);
    await peerConnection.setLocalDescription(offer);
    _sdpChanged(); // Copies offer (local Description) to the clipboard

    print("Created offer");
  }

  /// Creates a new RTCPeerConnection (peerConnection)
  /// Sets the REMOTE description (offer)
  /// Creates a new LOCAL description (answer) which is later copied to the clipboard
  Future<void> answerConnection(RTCSessionDescription offer) async {
    // RTCPeerConnection
    peerConnection = await _createPeerConnection();

    // Sets the REMOTE description (offer)
    await peerConnection.setRemoteDescription(offer);

    // Creates a new LOCAL description (answer)
    final answer =
        await peerConnection.createAnswer(_OFLocalDescriptionConstrains);
    await peerConnection.setLocalDescription(answer);
    _sdpChanged();

    print("Created Answer");
  }

  /// Sets the REMOTE description (answer)
  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    // Sets the REMOTE description (answer)
    await peerConnection.setRemoteDescription(answer);

    print("Answer Accepted");
  }

  /// Creates a new RTCPeerConnection
  Future<RTCPeerConnection> _createPeerConnection() async {
    // RTC PeerConnection configuration
    Map<String, dynamic> config = {
      'iceServers': [
        {
          'urls': "stun:stun.l.google.com:19302",
        }
      ]
    };

    final connection = await createPeerConnection(config);

    // Event Methods
    connection.onIceCandidate = (candidate) {
      print("New ICE candidate");
      _sdpChanged(); // IDK if this is really necessary
    };
    connection.onDataChannel = (channel) {
      print("Recived data channel");
      addRTCDataChannel(
          channel); // Adds the RTCDataChannel to the dataChannel class variable
    };
    connection.onIceConnectionState = (state) {
      print("ICE connection state: $state");
    };
    connection.onSignalingState = (state) {
      print("Signaling state: $state");
    };

    return connection;
  }

  /// Copies the local Description (SDP) (offer/answer) to the clipboard.
  void _sdpChanged() async {
    sdp = (await peerConnection.getLocalDescription())!;
    Clipboard.setData(ClipboardData(text: json.encode(sdp.toMap())));
    print("${sdp.type} SDP is coppied to the clipboard");
  }

  /// Creates a new RTCDataChannel
  Future<void> createRTCDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await peerConnection.createDataChannel(
        "textchat-chan", dataChannelDict);
    print("Created data channel");
    addRTCDataChannel(channel);
  }

  /// Sets the object RTCDataChannel to the dataChannel variable and defines some event methods
  void addRTCDataChannel(RTCDataChannel channel) {
    dataChannel = channel;
    dataChannel.onMessage = (data) {
      print("OTHER: " + data.text);
    };
    dataChannel.onDataChannelState = (state) {
      print("Data channel state: $state");
    };
  }

  /// Sends a message through the RTCDataChannel (dataChannel)
  Future<void> sendMessage(String message) async {
    await dataChannel.send(RTCDataChannelMessage(message));
    print("ME: " + message);
  }
}
