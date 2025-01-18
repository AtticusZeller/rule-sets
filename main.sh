#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq first:"
    echo "  For Ubuntu/Debian: sudo apt install jq"
    echo "  For MacOS: brew install jq"
    exit 1
fi


mkdir -p /tmp/rule-sets/{proxy,direct}
mkdir -p source/{proxy,direct} binary

echo "Downloading proxy rules..."
while IFS= read -r url; do
    filename=$(basename "$url")
    wget -q "$url" -O "/tmp/rule-sets/proxy/${filename}"
done <proxy-list.txt

echo "Downloading direct rules..."
while IFS= read -r url; do
    filename=$(basename "$url")
    wget -q "$url" -O "/tmp/rule-sets/direct/${filename}"
done <direct-list.txt


# 反编译所有代理规则为json
echo "Decompiling proxy rules..."
for file in /tmp/rule-sets/proxy/*.srs; do
    filename=$(basename "$file")
    json_name="source/proxy/${filename%.srs}.json"
    sing-box rule-set decompile "$file" -o "$json_name"
done

# 反编译所有直连规则为json
echo "Decompiling direct rules..."
for file in /tmp/rule-sets/direct/*.srs; do
    filename=$(basename "$file")
    json_name="source/direct/${filename%.srs}.json"
    sing-box rule-set decompile "$file" -o "$json_name"
done

echo "Upgrading proxy rules..."
for file in source/proxy/*.json; do
    filename=$(basename "$file")
    sing-box rule-set format "$file" -w
done

echo "Upgrading direct rules..."
for file in source/direct/*.json; do
    filename=$(basename "$file")
    sing-box rule-set format "$file" -w
done
# 使用目录方式合并规则
echo "Merging rules..."
sing-box rule-set merge source/merged_proxy.json -C source/proxy
sing-box rule-set merge source/merged_direct.json -C source/direct

echo "Updating version number..."
for file in source/merged_*.json; do
    # 创建临时文件
    temp_file="${file}.temp"
    jq '.version = 3' "$file" > "$temp_file" && mv "$temp_file" "$file"
done

# 编译最终的规则集
echo "Compiling final rule sets..."
sing-box rule-set compile source/merged_proxy.json -o binary/proxy.srs
sing-box rule-set compile source/merged_direct.json -o binary/direct.srs

# 清理临时文件
echo "Cleaning up..."
rm -rf /tmp/rule-sets

echo "Done! Final rule sets are in binary/proxy.srs and binary/direct.srs"
