# Flutter WebRTC Manual Connection Demo

###### This is a simple demo app demonstrating the WebRTC connection flow (in Flutter) for using the data channel.

---
## Tutorial
![Tutorial Picture](./Tutorial%20Picture.png)
</br>
1. Create an offer on Device A.
    - The offer will be automatically copied to the device's clipboard.
2. Paste the offer on Device B, which will then generate a corresponding answer.
    - The answer will be automatically copied to the device's clipboard.
3. Paste the answer from Device B into Device A.
4. If everything was done correctly, the connection should be established, and you can send "Hello World!" test messages back and forth. These will be logged in the console.

## Connection Flow
### Definitions:
#### ```RTCPeerConnection```:
The main connection object that handles the local and remote descriptions (SDP) and generates offers/answers.

#### ```RTCDataChannel```:
An object used for the main data exchange. It handles configuration and functionality related to data transmission.

#### ```RTCSessionDescription``` (SDP - Session Description Protocol):
A basic informational object for each side (Device A and Device B) that stores all the necessary data. For clarity, the offer, answer, local, and remote descriptions are all SDP or ```RTCSessionDescription``` objects.

### Flow
To connect two devices peer-to-peer:
1. Device A creates an offer, which Device B responds to with an answer.
2. The offer is essentially JSON-formatted SDP data and looks like this:
```
{
    "sdp":"v=0\r\no=- 2899943580468943990 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=extmap-allow-mixed\r\na=msid-semantic: WMS\r\nm=application 58869 UDP/DTLS/SCTP webrtc-datachannel\r\nc=IN IP4 89.166.207.19\r\na=candidate:3068005065 1 udp 2122260223 10.0.2.16 45293 typ host generation 0 network-id 5 network-cost 10\r\na=candidate:3068005065 1 udp 2122129151 10.0.2.16 47082 typ host generation 0 network-id 1 network-cost 900\r\na=candidate:3281287105 1 udp 2121932543 127.0.0.1 60342 typ host generation 0 network-id 3\r\na=candidate:3287934673 1 udp 2122187263 fec0::fbf5:36e:9bb6:559f 34129 typ host generation 0 network-id 6 network-cost 10\r\na=candidate:3287934673 1 udp 2122056191 fec0::fbf5:36e:9bb6:559f 33291 typ host generation 0 network-id 2 network-cost 900\r\na=candidate:3535299913 1 udp 2122005759 ::1 46891 typ host generation 0 network-id 4\r\na=candidate:1030765798 1 udp 1686052607 89.166.207.19 58869 typ srflx raddr 10.0.2.16 rport 45293 generation 0 network-id 5 network-cost 10\r\na=candidate:1030765798 1 udp 1685921535 89.166.207.19 58870 typ srflx raddr 10.0.2.16 rport 47082 generation 0 network-id 1 network-cost 900\r\na=candidate:1027515221 1 tcp 1517952767 127.0.0.1 47579 typ host tcptype passive generation 0 network-id 3\r\na=candidate:739422685 1 tcp 1518025983 ::1 47739 typ host tcptype passive generation 0 network-id 4\r\na=ice-ufrag:5dqg\r\na=ice-pwd:IWIBgRXAeG3U6NMYqQGT6m4X\r\na=ice-options:trickle renomination\r\na=fingerprint:sha-256 AD:9E:CE:12:73:86:75:AB:5F:70:CF:5F:2E:2C:B7:35:B8:09:DD:32:91:F7:40:0C:52:66:93:60:70:AD:5E:00\r\na=setup:actpass\r\na=mid:0\r\na=sctp-port:5000\r\na=max-message-size:262144\r\n",
    "type":"offer"
}
```

3. The offer is generated through an ```RTCPeerConnection``` Object (```createPeerConnection(config)```) with ```peerConnection.createOffer(constrains)```.
    - ```config``` defines the STUN servers, which are necessary since not all devices have a public IP address (at least that's what I read and heard online).
    - ```constrains``` define the type of data exchanged between Device A and Device B, and possibly other details.
4. The offer from Device A is also set as its local description.
5. Once the offer is sent to Device B:
    - Device B creates an answer (again, JSON-formatted SDP data).
    - The offer is set as the remote description on Device B.
    - The answer is set as the local description on Device B and sent back to Device A.
6. Device A sets the received answer as its remote description.

Congratulations! 🎉
Your connection should now be established. Using the ```RTCDataChannel``` object (created during the process by Device A), you can send text data back and forth between the devices with nearly zero latency.

## Requirements
### Android:
In order to use webRTC in in Android, you have to set some permissions inside the ```AndroidManifest.xml``` file.
```
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```
For me these were the only permissions I need to use the data Channel. If you want to use the audio or video you have to set other permissions as well.
### IOS:
I don't know the exact permissions which have to be set in some ```.plist``` file, but there should be quite similar to the ones from android and easy to find online or in the ```flutter_webrtc``` package documentation.