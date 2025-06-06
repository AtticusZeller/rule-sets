

# Rule-sets for sing-box

```json
  "route": {
    "rules": [
      {
        "inbound": "tun-in",
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "rule_set": "proxy-rule",
        "outbound": "proxy"
      },
      {
        "protocol": "ssh",
        "outbound": "direct"
      },
      {
        "rule_set": "direct-rule",
        "outbound": "direct"
      },
      {
        "rule_set": "geoip-cn",
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "proxy-rule",
        "format": "binary",
        "url": "https://raw.gh.atticux.me/AtticusZeller/rule-sets/main/binary/proxy.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "direct-rule",
        "format": "binary",
        "url": "https://raw.gh.atticux.me/AtticusZeller/rule-sets/main/binary/direct.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://raw.gh.atticux.me/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
        "download_detour": "direct"
      }
    ],
```
