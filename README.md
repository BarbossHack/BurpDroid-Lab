# BurpDroid Lab

Route all Android (phone or emulator) traffic through Burp Suite via OpenVPN.

```text
Android
  ↓ (OpenVPN)
tun0 (container)
  ↓ (iptables DNAT 80/443)
Burp Suite (host:8084)
  ↓
Internet
```

## Prerequisites

- podman
- adb

## Usage

1. Configure the Burp Suite proxy to listen on port `8084` on `All interfaces`, and enable `Support invisible proxying` in `Request handling`
2. Run `./server.sh`
3. Connect your phone to your PC, or start your emulator
4. Run `./client.sh`
5. Import `Downloads/burp.der` into the Android `CA certificates` settings
6. Open the OpenVPN app and import `Downloads/client.ovpn` profile
7. Connect the `client` VPN profile
8. Enable `Block connection without VPN` and `Always-on VPN` for OpenVPN in the Android settings

You should see all your Android traffic in Burp Suite (for apps that do not use certificate pinning).
