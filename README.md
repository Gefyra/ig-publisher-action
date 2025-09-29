# HL7 FHIR IG Publisher Action

[![Docker Build](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release.yml/badge.svg)](https://github.com/Gefyra/ig-publisher-action/actions/workflows/auto-release.yml)
[![Test Docker Build](https://github.com/Gefyra/ig-publisher-action/actions/workflows/test.yml/badge.svg)](https://github.com/Gefyra/ig-publisher-action/actions/workflows/test.yml)
[![Docker Image Size](https://img.shields.io/docker/image-size/ghcr.io/gefyra/ig-publisher-action/latest?logo=docker&label=Image%20Size)](https://github.com/Gefyra/ig-publisher-action/pkgs/container/ig-publisher-action)
[![Docker Pulls](https://img.shields.io/docker/pulls/ghcr.io/gefyra/ig-publisher-action?logo=docker&label=Pulls)](https://github.com/Gefyra/ig-publisher-action/pkgs/container/ig-publisher-action)
[![GitHub Release](https://img.shields.io/github/v/release/Gefyra/ig-publisher-action?logo=github&label=Latest%20Release)](https://github.com/Gefyra/ig-publisher-action/releases/latest)
[![License](https://img.shields.io/github/license/Gefyra/ig-publisher-action?logo=opensource&label=License)](LICENSE)
[![FHIR](https://img.shields.io/badge/FHIR-R4%2FR5-red?logo=hl7&logoColor=white)](https://hl7.org/fhir/)
[![Java](https://img.shields.io/badge/Java-21-orange?logo=openjdk&logoColor=white)](https://openjdk.org/)
[![Node.js](https://img.shields.io/badge/Node.js-20-green?logo=node.js&logoColor=white)](https://nodejs.org/)

This repository creates a Docker image and GitHub Action for the HL7 FHIR Implementation Guide Publisher with all necessary dependencies. Perfect for CI/CD pipelines and automated IG builds.

## 🛠️ Included Tools

- **HL7 FHIR IG Publisher** (latest version)
- **SUSHI** (FSH to FHIR converter)
- **Node.js 20**
- **Java 21** (Eclipse Temurin)
- **Git, curl, unzip** for CI/CD workflows

## 🔄 GitHub Actions Integration

This repository provides a ready-to-use GitHub Action for building FHIR Implementation Guides. Here are the recommended usage patterns:

### Method 1: GitHub Action (Recommended)

The cleanest way to use this in your workflows:

```yaml
name: Build IG
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run IG Publisher
        uses: Gefyra/ig-publisher-action@main
        with:
          command: igpublisher
          args: -ig ig.ini
      
      - name: Run SUSHI
        uses: Gefyra/ig-publisher-action@main
        with:
          command: sushi
          args: .
```

### Method 2: Container Job (Multiple Steps)

For workflows with multiple IG-related commands:

```yaml
name: Build IG
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/gefyra/ig-publisher-action:latest
    steps:
      - uses: actions/checkout@v4
      - run: sushi .
      - run: igpublisher -ig ig.ini
      - run: echo "All tools available directly!"
```

### Advanced Workflow with SUSHI

```yaml
name: FHIR IG Pipeline
on: [push, pull_request]

jobs:
  build-ig:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run SUSHI (FSH → FHIR)
        uses: Gefyra/ig-publisher-action@main
        with:
          command: sushi
          args: .
      
      - name: Build IG
        uses: Gefyra/ig-publisher-action@main
        with:
          command: igpublisher
          args: -ig ig.ini -tx https://tx.fhir.org
      
      - name: Upload IG Output
        uses: actions/upload-artifact@v4
        with:
          name: fhir-ig
          path: output/
```

### Matrix Build (Multiple Versions)

Test your IG against multiple IG Publisher versions:

```yaml
strategy:
  matrix:
    ig-version: ['latest', 'v1.6.24-ig20240929', 'v1.6.23-ig20240920']

steps:
  - name: Build with IG Publisher ${{ matrix.ig-version }}
    uses: Gefyra/ig-publisher-action@main
    with:
      command: igpublisher
      args: -ig ig.ini
```

### Publishing Results

Complete pipeline with GitHub Pages deployment:

```yaml
- name: Build IG
  uses: Gefyra/ig-publisher-action@main
  with:
    command: igpublisher
    args: -ig ig.ini

- name: Deploy to GitHub Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./output
```

## 📚 GitHub Actions Best Practices

### Method Comparison

| Method | Performance | Use Case | Best For |
|--------|-------------|----------|----------|
| **GitHub Action** | ⭐⭐⭐⭐ | Clean interface | Published actions |
| **Container Job** | ⭐⭐⭐ | Multiple steps | Complex workflows |

### Recommended Usage

```yaml
# ✅ Best Practice - Clean GitHub Action interface
- name: Build IG
  uses: Gefyra/ig-publisher-action@main
  with:
    command: igpublisher
    args: -ig ig.ini

# ✅ Good for multiple commands - Container job
jobs:
  build:
    container: ghcr.io/gefyra/ig-publisher-action:latest
    steps:
      - run: sushi .
      - run: igpublisher -ig ig.ini
```

### Error Handling

```yaml
- name: Build IG with error handling
  uses: Gefyra/ig-publisher-action@main
  with:
    command: igpublisher
    args: -ig ig.ini
  continue-on-error: false
```

### Version Pinning

```yaml
# Pin to specific version for reproducible builds
- name: Build with pinned version
  uses: Gefyra/ig-publisher-action@v1.6.24-ig20240929
  with:
    command: igpublisher
    args: -ig ig.ini
```

## 🚀 Docker Usage

For direct Docker usage without GitHub Actions:

### GitHub Container Registry

```bash
# Latest version
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:latest igpublisher [options]

# Specific version
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:v1.0.0 igpublisher [options]
```

### Local Build

```bash
docker build -t ig-publisher .
docker run --rm -v $(pwd):/github/workspace ig-publisher igpublisher [options]
```

### Examples

#### Build Implementation Guide

```bash
# Build IG from current directory
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:latest igpublisher -ig ig.ini

# With additional options
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:latest igpublisher -ig ig.ini -tx https://tx.fhir.org
```

#### Use SUSHI

```bash
# Run SUSHI directly
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:latest sushi .
```

## 🚀 Automated Releases

### 🔄 Auto-Release on New IG Publisher Versions
The repository automatically monitors new IG Publisher releases and creates corresponding Docker images:

- **Daily Check** at 00:00 UTC
- **Automatic Release** on new IG Publisher versions
- **Tag Format:** `v{ig-publisher-version}-ig{date}`
- **Example:** `v1.6.24-ig20240929`

### 🛡️ Backup Monitoring
Weekly status check (Mondays) as backup:
- **Monitors** if the auto-release system is working
- **Creates Issues** only when auto-release fails
- **Redundancy** for critical release failures

### 🛠️ Manual Releases
New releases can also be created manually:

```bash
# Manual tag for specific version
git tag v1.0.0-custom
git push origin v1.0.0-custom

# Or run auto-release workflow manually
gh workflow run auto-release.yml -f force_release=true
```

**Release Process:**
1. Build Docker image for AMD64 and ARM64
2. Push to GitHub Container Registry  
3. Automatic release notes with version info
4. Tool versions are extracted from the image

## ⚙️ Configuration

### Java Memory Configuration

The image is configured with 4GB heap memory by default (`-Xmx4g`). If more memory is needed:

```bash
docker run --rm -v $(pwd):/github/workspace ghcr.io/gefyra/ig-publisher-action:latest java -Xmx8g -jar /opt/ig/publisher.jar [options]
```

### Available Tags

- `latest` - Always the newest IG Publisher version
- `v{version}-ig{date}` - Specific IG Publisher versions
- `v{version}-custom` - Manual releases

## 🔧 Development

### Local Testing

```bash
# Build image
docker build -t ig-publisher-test .

# Test
docker run --rm -v $(pwd):/github/workspace ig-publisher-test igpublisher --help
```

### Multi-Platform Build

```bash
docker buildx create --name multiarch --use
docker buildx build --platform linux/amd64,linux/arm64 -t ig-publisher --push .
```