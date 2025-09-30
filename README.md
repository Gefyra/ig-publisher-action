# HL7 FHIR IG Publisher Action

[![Docker Build](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release.yml/badge.svg)](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release.yml)
[![Extended Build](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release-with-snapshot-support.yml/badge.svg)](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release-with-snapshot-support.yml)
[![Test Docker Build](https://github.com/Gefyra/ig-publisher-action/actions/workflows/test.yml/badge.svg)](https://github.com/Gefyra/ig-publisher-action/actions/workflows/test.yml)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-ig--publisher-blue?logo=docker&logoColor=white)](https://github.com/Gefyra/ig-publisher-action/pkgs/container/ig-publisher)
[![GitHub Release](https://img.shields.io/github/v/release/Gefyra/ig-publisher-action?logo=github&label=Latest%20Release)](https://github.com/Gefyra/ig-publisher-action/releases/latest)
[![License](https://img.shields.io/github/license/Gefyra/ig-publisher-action?logo=opensource&label=License)](LICENSE)
[![FHIR](https://img.shields.io/badge/FHIR-R4%2FR5-red?logo=hl7&logoColor=white)](https://hl7.org/fhir/)
[![Java](https://img.shields.io/badge/Java-21-orange?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Multi-Platform](https://img.shields.io/badge/Platform-AMD64%20%7C%20ARM64-lightgrey?logo=docker&logoColor=white)](https://github.com/Gefyra/ig-publisher-action/pkgs/container/ig-publisher)

A comprehensive GitHub Action for building FHIR Implementation Guides with the HL7 FHIR IG Publisher, SUSHI, and optional FHIR Package Tool support.

## 📦 Two Variants Available

### 🔹 Standard Version
- **HL7 FHIR IG Publisher** (latest)
- **SUSHI** for FSH → FHIR conversion  
- **Java 21** (Eclipse Temurin)
- **Node.js 20**
- **Docker Image:** `ghcr.io/gefyra/ig-publisher:latest`

### 🔹 With Snapshot Support Version  
- Everything from Standard version
- **+ FHIR Package Tool** for package management and snapshot generation
- **Docker Image:** `ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest`
- **Built on top of:** Standard version (for efficient layer reuse)

## 🔄 GitHub Actions Integration

### Method 1: Standard Version (Default)

For basic IG building with IG Publisher and SUSHI:

```yaml
name: Build IG
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Standard version (default)
      - name: Run IG Publisher
        uses: Gefyra/ig-publisher-action@main
        with:
          command: igpublisher
          args: -ig ig.ini

      # Build with SUSHI first  
      - name: Run SUSHI
        uses: Gefyra/ig-publisher-action@main
        with:
          command: sushi
          args: .
```

### Method 2: With Snapshot Support

For workflows that need package management, use the `variant` parameter:

```yaml
name: Build IG with Package Management
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # With snapshot support variant
      - name: Download FHIR Packages
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: fhir-pkg-tool
          args: -p hl7.fhir.r4.core@4.0.1 -p hl7.fhir.us.core@6.1.0 -o ./packages

      - name: Run SUSHI  
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: sushi
          args: .

      - name: Run IG Publisher
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: igpublisher
          args: -ig ig.ini
```

### Method 3: Container Jobs

For workflows with multiple steps:

```yaml
jobs:
  build-standard:
    runs-on: ubuntu-latest
    container: ghcr.io/gefyra/ig-publisher:latest
    steps:
      - uses: actions/checkout@v4
      - run: sushi .
      - run: igpublisher -ig ig.ini

  build-with-snapshot-support:
    runs-on: ubuntu-latest
    container: ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest
    steps:
      - uses: actions/checkout@v4
      - run: fhir-pkg-tool -p hl7.fhir.r4.core@4.0.1 -o ./packages
      - run: sushi .
      - run: igpublisher -ig ig.ini
```

## 📚 GitHub Actions Best Practices

### Complete Workflow with Artifact Publishing

```yaml
name: Build and Publish IG
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Download Dependencies
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: fhir-pkg-tool
          args: --sushi-deps-file sushi-config.yaml -o ./packages

      - name: Run SUSHI
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: sushi
          args: .

      - name: Build IG
        uses: Gefyra/ig-publisher-action@main
        with:
          variant: with-snapshot-support
          command: igpublisher
          args: -ig ig.ini -tx https://tx.fhir.org

      - name: Upload Build Results
        uses: actions/upload-artifact@v4
        with:
          name: fhir-ig
          path: output/

      - name: Deploy to GitHub Pages
        if: github.ref == 'refs/heads/main'
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./output
```

### Matrix Build for Both Variants

```yaml
strategy:
  matrix:
    include:
      - variant: standard
        image: ghcr.io/gefyra/ig-publisher:latest
      - variant: with-snapshot-support  
        image: ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest

steps:
  - name: Build with ${{ matrix.variant }} variant
    uses: Gefyra/ig-publisher-action@main
    with:
      variant: ${{ matrix.variant }}
      command: igpublisher
      args: -ig ig.ini
```

## 🐳 Docker Usage

### Standard Version

```bash
# Pull latest standard version
docker pull ghcr.io/gefyra/ig-publisher:latest

# Build Implementation Guide
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher:latest \
  igpublisher -ig ig.ini

# Run SUSHI
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher:latest \
  sushi .
```

### With Snapshot Support Version

```bash
# Pull latest with snapshot support version  
docker pull ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest

# Use FHIR Package Tool
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  fhir-pkg-tool -p hl7.fhir.r4.core@4.0.1 -o ./packages

# Download packages from sushi-config.yaml
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  fhir-pkg-tool --sushi-deps-file sushi-config.yaml --force-snapshot -o ./packages

# Build IG (same as standard)
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  igpublisher -ig ig.ini
```

## 🚀 FHIR Package Tool Features (With Snapshot Support Version Only)

The **With Snapshot Support Version** includes the powerful FHIR Package Tool with these capabilities:

- **📦 Multiple Package Support**: Download and process multiple FHIR packages simultaneously
- **🔄 Dependency Resolution**: Automatic recursive dependency resolution from package manifests  
- **📋 Sushi Integration**: Direct integration with `sushi-config.yaml` files for dependency extraction
- **🔧 Snapshot Generation**: Automatic StructureDefinition snapshot generation with force rebuild options
- **🌐 Multi-Version Support**: Support for FHIR R4, R4B, R5 with automatic context detection
- **📁 Local Profiles**: Process local StructureDefinition files with snapshot generation
- **🎯 Flexible Output**: Organized output structure with package-specific folders

### FHIR Package Tool Examples

```bash
# Download specific packages with snapshots
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  fhir-pkg-tool -p hl7.fhir.us.core@6.1.0 -p hl7.fhir.r4.core@4.0.1 --force-snapshot -o ./packages

# Process dependencies from sushi-config.yaml
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  fhir-pkg-tool --sushi-deps-file sushi-config.yaml --force-snapshot -o ./packages

# Process local profiles
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  fhir-pkg-tool -p hl7.fhir.r4.core@4.0.1 --profiles-dir ./input/resources --force-snapshot -o ./packages
```

## 🚀 Automated Releases

### 🔄 Auto-Release System
Both variants automatically monitor for new versions and create corresponding Docker images:

- **Standard:** Daily check at 00:00 UTC for new IG Publisher versions
- **With Snapshot Support:** Daily check at 01:00 UTC for new IG Publisher + FHIR Package Tool versions  
- **Automatic Release:** On new tool versions
- **Tag Format:** 
  - Standard: `v{ig-publisher-version}-ig{date}`  
  - With Snapshot Support: `v{ig-publisher-version}-snapshot-support-{date}`

### 🛡️ Backup Monitoring
Weekly status check (Mondays) as backup:
- **Monitors** if the auto-release system is working
- **Creates Issues** only when auto-release fails
- **Redundancy** for critical release failures

### 🛠️ Manual Releases
New releases can also be created manually:

```bash
# Manual workflow trigger with force release
gh workflow run auto-release.yml -f force_release=true
gh workflow run auto-release-with-snapshot-support.yml -f force_release=true
```

## ⚙️ Configuration

### Java Memory Configuration

Both images are configured with optimized memory settings:

```bash
# Standard version (4GB for IG Publisher)
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher:latest \
  java -Xmx8g -jar /opt/ig/publisher.jar [options]

# Extended version (4GB for IG Publisher, 2GB for Package Tool)  
docker run --rm -v $(pwd):/github/workspace \
  ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest \
  java -Xmx4g -jar /opt/fhir-pkg-tool/fhir-pkg-tool.jar [options]
```

### Available Tags

#### Standard Version
- `ghcr.io/gefyra/ig-publisher:latest` - Always the newest IG Publisher version
- `ghcr.io/gefyra/ig-publisher:v{version}-ig{date}` - Specific IG Publisher versions

#### With Snapshot Support Version  
- `ghcr.io/gefyra/ig-publisher-with-snapshot-support:latest` - Always the newest versions
- `ghcr.io/gefyra/ig-publisher-with-snapshot-support:v{version}-snapshot-support-{date}` - Specific versions

## 🔧 Development

### Local Testing

```bash
# Build standard image
docker build -t ig-publisher-test .

# Build with snapshot support image  
docker build -f Dockerfile.with-snapshot-support -t ig-publisher-with-snapshot-support-test .

# Test standard
docker run --rm -v $(pwd):/github/workspace ig-publisher-test igpublisher --help

# Test with snapshot support
docker run --rm -v $(pwd):/github/workspace ig-publisher-with-snapshot-support-test fhir-pkg-tool --help
```

### Multi-Platform Build

```bash
docker buildx create --name multiarch --use

# Standard
docker buildx build --platform linux/amd64,linux/arm64 -t ig-publisher --push .

# With snapshot support  
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile.with-snapshot-support -t ig-publisher-with-snapshot-support --push .
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.