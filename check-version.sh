#!/bin/bash
set -e

echo "🔍 IG Publisher Version Check"
echo "=============================="

# Current local version
if git describe --tags --abbrev=0 >/dev/null 2>&1; then
    CURRENT_TAG=$(git describe --tags --abbrev=0)
    CURRENT_VERSION=$(echo "$CURRENT_TAG" | sed 's/^v//' | sed 's/-ig.*//')
    echo "📦 Current Docker version: $CURRENT_VERSION (Tag: $CURRENT_TAG)"
else
    echo "📦 Current Docker version: none (no tags found)"
    CURRENT_VERSION="0.0.0"
fi

# Latest IG Publisher version
echo "🌐 Checking latest IG Publisher version..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/HL7/fhir-ig-publisher/releases/latest)
LATEST_VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name' | sed 's/^v//')
RELEASE_DATE=$(echo "$LATEST_RELEASE" | jq -r '.published_at')

echo "🚀 Latest IG Publisher: $LATEST_VERSION (Released: $RELEASE_DATE)"

# Comparison
if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
    echo ""
    echo "🔥 UPDATE AVAILABLE!"
    echo "   Current: $CURRENT_VERSION"
    echo "   Latest:  $LATEST_VERSION"
    echo ""
    echo "🛠️  Options:"
    echo "   1. Run auto-release workflow:"
    echo "      gh workflow run auto-release.yml"
    echo ""
    echo "   2. Manual tag:"
    echo "      git tag v${LATEST_VERSION}-ig$(date +%Y%m%d)"
    echo "      git push origin --tags"
else
    echo ""
    echo "✅ UP TO DATE!"
    echo "   Your Docker image is current with the latest IG Publisher."
fi

echo ""
echo "🔗 Links:"
echo "   IG Publisher Releases: https://github.com/HL7/fhir-ig-publisher/releases"
echo "   Auto-Release Workflow: https://github.com/$(git config --get remote.origin.url | sed 's/.*github\.com[:/]//' | sed 's/\.git$//')/actions/workflows/auto-release.yml"