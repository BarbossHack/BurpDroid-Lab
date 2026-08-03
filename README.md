# BurpDroid Lab

Route all Android (phone or emulator) traffic through Burp Suite.

## Prerequisites

- podman/docker
- adb

## With Namespace (emulator only)

```text
Android
  ↓
veth-burp (namespace)
  ↓ (nftables DNAT 80/443)
Burp Suite (host:8084)
  ↓
Internet
```

1. Configure the Burp Suite proxy to listen on port `8084` on `All interfaces`, and enable `Support invisible proxying` in `Request handling`
2. Run `./ns-setup.sh` to setup the namespace
3. Open one or more shell in this namespace: `sudo ip netns exec burpns sudo -u "$USER" bash`
4. Run the emulator from this new shell: `emulator -avd Pixel_9a` (list available avds: `emulator -list-avds`)
5. From an other namespace shell, run `adb push burp.der /storage/emulated/Downloads/` and then import it into the Android `CA certificates` settings

## With OpenVPN

```text
Android
  ↓ (OpenVPN)
tun0 (container)
  ↓ (iptables DNAT 80/443)
Burp Suite (host:8084)
  ↓
Internet
```

1. Configure the Burp Suite proxy to listen on port `8084` on `All interfaces`, and enable `Support invisible proxying` in `Request handling`
2. Run `./ovpn-server.sh`
3. Connect your phone to your PC, or start your emulator
4. Run `./ovpn-client.sh`
5. Import `/storage/emulated/0/Downloads/burp.der` into the Android `CA certificates` settings
6. Open the OpenVPN app and import `Downloads/client.ovpn` profile
7. Connect the `client` VPN profile
8. Enable `Block connection without VPN` and `Always-on VPN` for OpenVPN in the Android settings

You should see all your Android traffic in Burp Suite (for apps that do not use certificate pinning).
