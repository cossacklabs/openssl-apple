#!/usr/bin/env bash
#
# Update package spec files of Cossack Labs' OpenSSL.
#
#     scripts/update-specs.sh
#
# Run this after packaging OpenSSL with "scripts/create-packages.sh".
#
# Environment variables:
#
#     OUTPUT        output directory            (default: output)

set -eu

OUTPUT=${OUTPUT:-output}

die() {
    echo 2>&1 "$@"
    exit 1
}

if [[ ! -f "$OUTPUT/version" ]]
then
    die 'No package version. Run "scripts/create-packages.sh" first.'
fi

version="$(cat "$OUTPUT/version")"

# Carthage
for package in "$OUTPUT"/openssl-*.zip
do
    package="$(basename "$package")"
    spec="carthage/${package%%.zip}.json"
    if grep -q "\"$version\"" "$spec"
    then
        echo "OpenSSL $version is already present in $spec"
    else
        (
            head -1 "$spec" 2> /dev/null || echo "{"
            echo "    \"$version\": \"https://github.com/cossacklabs/openssl-apple/releases/download/v$version/$package\","
            tail +2 "$spec" 2> /dev/null || echo "}"
        ) > "$OUTPUT/tmp.spec"
        mv "$OUTPUT/tmp.spec" "$spec"
    fi
done
