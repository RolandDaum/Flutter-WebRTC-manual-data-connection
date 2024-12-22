import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Map<String, dynamic> config = {
  'iceServers': [
    {
      'urls': "stun:stun.l.google.com:19302",
    }
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRtcViewModel {
  late RTCDataChannel dataChannel;
  late RTCPeerConnection peerConnection;
  late RTCSessionDescription sdp;

  Future<void> offerConnection() async {
    peerConnection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription offer =
        await peerConnection.createOffer(_offerAnswerConstraints);
    await peerConnection.setLocalDescription(offer);
    _sdpChanged();
    print("Created offer");
  }

  Future<void> answerConnection(RTCSessionDescription offer) async {
    peerConnection = await _createPeerConnection();
    await peerConnection.setRemoteDescription(offer);
    final answer = await peerConnection.createAnswer(_offerAnswerConstraints);
    await peerConnection.setLocalDescription(answer);
    _sdpChanged();
    print("Created Answer");
  }

  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    await peerConnection.setRemoteDescription(answer);
    print("Answer Accepted");
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(config);
    con.onIceCandidate = (candidate) {
      print("New ICE candidate");
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      print("Recived data channel");
      _addDataChannel(channel);
    };
    con.onIceConnectionState = (state) {
      print("ICE connection state: $state");
    };
    con.onSignalingState = (state) {
      print("Signaling state: $state");
    };
    return con;
  }

  void _sdpChanged() async {
    sdp = (await peerConnection.getLocalDescription())!;
    Clipboard.setData(ClipboardData(text: json.encode(sdp.toMap())));
    print("${sdp.type} SDP is coppied to the clipboard");
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await peerConnection.createDataChannel(
        "textchat-chan", dataChannelDict);
    print("Created data channel");
    _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    dataChannel = channel;
    dataChannel.onMessage = (data) {
      print("OTHER: " + data.text);
    };
    dataChannel.onDataChannelState = (state) {
      print("Data channel state: $state");
    };
  }

  Future<void> sendMessage(String message) async {
    await dataChannel.send(RTCDataChannelMessage(message));
    print("ME: " + message);
  }
}
