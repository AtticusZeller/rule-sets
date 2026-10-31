

# Rule-sets for sing-box

`bash main.sh` builds the `proxy`, `direct`, and `clean` aggregates. To rebuild
only the clean-IP group, run `bash main.sh clean`. The checked-in `sing-box`
binary, `jq`, and `wget` are required. A failed download or compile stops the
build before replacing that group's published outputs. Builds merge the current
list plus optional hand-maintained `source/<group>/<group>.json` additions.

`clean-list.txt` combines Anthropic, OpenAI, Google and Apple. The hand-maintained
`source/clean/clean.json` adds `challenges.cloudflare.com`, `dash.cloudflare.com`,
and Arena (`arena.ai`, plus legacy `lmarena.ai`).
Google and Apple are whole-provider groups, including YouTube and ordinary
provider downloads. Microsoft/OneDrive, Netflix, Hugging Face and GitHub are not
added as clean groups. The ISP allowance is 100 GB/month, so development/download
traffic is explicitly excluded even when a parent vendor group contains it.

An optional `<group>-exclude.json` is applied after the group's inputs are merged:
the result matches the included domains AND NOT the excluded domains.
`clean-exclude.json` excludes GitHub/Hugging Face, Google container/package
registries, Go/TensorFlow downloads, Google Cloud Storage and Kaggle domains.
The exclusion file lives outside `source/clean/` so it cannot be merged as another
positive rule. Run `bash main.sh clean` to rebuild the complete policy, including
exclusions. Its outputs are `source/merged_clean.json` and `binary/clean.srs`.
The name describes destinations selected for a checked exit; the rule-set does
not test or guarantee exit-IP reputation or regional access.

Consumers can register `binary/clean.srs` as `clean-rule` using
`https://raw.githubusercontent.com/AtticusZeller/rule-sets/main/binary/clean.srs`.
Publish that artifact before deploying a configuration that references the URL.
In `sing-box-config`, clients use this aggregate for DNS filtering: matching
AAAA queries receive an empty `NOERROR` response before proxy/direct DNS rules;
A queries keep the existing resolver selection. Client connection routing keeps
the normal proxy/direct policy. Selecting a VPS transport lets the server apply
`clean-rule -> isp-clean` before its original WARP rule. Google/Apple use Clean
except for excluded development/download domains. Netflix, Hugging Face and
academic groups retain their existing WARP policy; earlier direct exceptions
still win. The airport node and direct selection bypass the VPS policy. Existing
consumers refresh the rule-set on their configured interval, so publication does
not force an immediate live refresh.

The Cloudflare additions cover challenge validation and the dashboard, without
adding Workers/R2 or identifying every third-party website using Cloudflare's
CDN. Those websites must match the clean aggregate themselves to use the ISP
exit. Cleaner egress may reduce IP-related challenges but does not guarantee
challenge-free access; browser signals and website policies still apply. See the
[official troubleshooting guide](https://developers.cloudflare.com/cloudflare-challenges/troubleshooting/).

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
