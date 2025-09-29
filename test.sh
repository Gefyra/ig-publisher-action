#!/bin/bash
set -e

echo "Testing IG Publisher Docker Image..."

# Build the image
echo "Building Docker image..."
docker build -t ig-publisher-test .

# Test basic commands
echo "Testing igpublisher command..."
docker run --rm ig-publisher-test igpublisher --help

echo "Testing SUSHI..."
docker run --rm ig-publisher-test sushi --help

echo "Testing Java version..."
docker run --rm ig-publisher-test java --version

echo "Testing Node version..."
docker run --rm ig-publisher-test node --version

echo "Testing npm version..."
docker run --rm ig-publisher-test npm --version

echo "All tests passed!"