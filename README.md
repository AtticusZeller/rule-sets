

# Rule-sets for sing-box

`bash main.sh` builds the `proxy`, `direct`, and `clean` aggregates. To rebuild
only the clean-IP group, run `bash main.sh clean`. The checked-in `sing-box`
binary, `jq`, and `wget` are required. A failed download or compile stops the
build before replacing that group's published outputs. Builds merge the current
list plus optional hand-maintained `source/<group>/<group>.json` additions.

`clean-list.txt` combines Google, Apple, Netflix, Hugging Face, Google Scholar,
the non-China academic category, Anthropic, and OpenAI. Its outputs are
`source/merged_clean.json` and `binary/clean.srs`. The name describes destinations
that should use an independently checked exit; the rule-set does not test or
guarantee exit-IP reputation.

Consumers can register `binary/clean.srs` as `clean-rule` using
`https://raw.githubusercontent.com/AtticusZeller/rule-sets/main/binary/clean.srs`.
Publish that artifact before deploying a configuration that references the URL.
Route `clean-rule` before `proxy-rule` when they use different outbounds. The
client configuration will use a verified `trojan-clean` exit; the server keeps
`warp-out` and its earlier direct-domain exceptions.

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
