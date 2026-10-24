#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "$0")"

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

groups=("$@")
if ((${#groups[@]} == 0)); then
    groups=(proxy direct clean)
fi
for group in "${groups[@]}"; do
    case "$group" in
        proxy|direct|clean) ;;
        *) echo "Unknown rule group: $group" >&2; exit 1 ;;
    esac
done

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
mkdir -p binary

for group in "${groups[@]}"; do
    echo "Building $group rules..."
    mkdir -p "$work_dir/$group" "source/$group"
    # Retain the group's hand-maintained additions, but never merge stale downloads.
    if [[ -f "source/$group/$group.json" ]]; then
        cp "source/$group/$group.json" "$work_dir/$group/"
    fi
    while IFS= read -r url || [[ -n "$url" ]]; do
        [[ -z "$url" || "$url" == \#* ]] && continue
        filename=$(basename "$url")
        wget -q "$url" -O "$work_dir/$filename"
        json_name="$work_dir/$group/${filename%.srs}.json"
        ./sing-box rule-set decompile "$work_dir/$filename" -o "$json_name"
        ./sing-box rule-set upgrade "$json_name" -w
        ./sing-box rule-set format "$json_name" -w
    done <"$group-list.txt"

    ./sing-box rule-set merge "$work_dir/merged_$group.json" -C "$work_dir/$group"
    ./sing-box rule-set compile "$work_dir/merged_$group.json" -o "$work_dir/$group.srs"
    # Publish this group's outputs only after every download and build succeeded.
    cp "$work_dir/$group/"*.json "source/$group/"
    cp "$work_dir/merged_$group.json" "source/merged_$group.json"
    cp "$work_dir/$group.srs" "binary/$group.srs"
done

echo "Done! Final rule sets are in binary/."
