# HL7 FHIR IG Publisher Action

This repository creates a Docker image and GitHub Action for the HL7 FHIR Implementation Guide Publisher with all necessary dependencies. Perfect for CI/CD pipelines and automated IG builds.

## 🛠️ Included Tools

- **HL7 FHIR IG Publisher** (latest version)
- **SUSHI** (FSH to FHIR converter)
- **Node.js 20**
- **Java 21** (Eclipse Temurin)
- **Git, curl, unzip** for CI/CD workflows

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



## 🚀 Automated Releases

### 🔄 Auto-Release on New IG Publisher Versions
The repository automatically monitors new IG Publisher releases and creates corresponding Docker images:

- **Daily Check** at 06:00 UTC
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

## 🚀 Automatische Releases

### 🔄 Auto-Release bei neuen IG Publisher Versionen
Das Repository überwacht automatisch neue IG Publisher Releases und erstellt entsprechende Docker Images:

- **Tägliche Überprüfung** um 06:00 UTC
- **Automatisches Release** bei neuer IG Publisher Version
- **Tag-Format:** `v{ig-publisher-version}-ig{datum}`
- **Beispiel:** `v1.6.24-ig20240929`

### �️ Backup Monitoring
Wöchentlicher Status-Check (Montags) als Backup:
- **Überwacht** ob das Auto-Release-System funktioniert
- **Erstellt Issues** nur wenn Auto-Release fehlschlägt
- **Redundanz** für kritische Release-Failures

### 🛠️ Manuelle Releases
Neue Releases können auch manuell erstellt werden:

```bash
# Manueller Tag für spezifische Version
git tag v1.0.0-custom
git push origin v1.0.0-custom

# Oder Auto-Release Workflow manuell ausführen
gh workflow run auto-release.yml -f force_release=true
```

**Release-Prozess:**
1. Build des Docker Images für AMD64 und ARM64
2. Push zum GitHub Container Registry  
3. Automatische Release Notes mit Versionsinfos
4. Tool-Versionen werden aus dem Image extrahiert

## Java Memory

Das Image ist standardmäßig mit 4GB Heap-Speicher konfiguriert (`-Xmx4g`). Falls mehr Speicher benötigt wird:

```bash
docker run --rm -v $(pwd):/github/workspace ghcr.io/USERNAME/ig-publisher-docker:latest java -Xmx8g -jar /opt/ig/publisher.jar [options]
```

## Development

### Lokaler Test

```bash
# Image bauen
docker build -t ig-publisher-test .

# Testen
docker run --rm -v $(pwd):/github/workspace ig-publisher-test igpublisher --help
```

### Multi-Platform Build

```bash
docker buildx create --name multiarch --use
docker buildx build --platform linux/amd64,linux/arm64 -t ig-publisher --push .
```