FROM eclipse-temurin:21-jdk-noble

# Minimal tools for CI + Ruby and Jekyll dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates unzip git xz-utils \
      ruby ruby-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

# Node.js LTS for SUSHI - multi-arch binary installation. Takes the newest
# release of the major line on every build, so the nightly rebuilds pick up
# Node security fixes without anyone bumping a patch version by hand. The
# tarball is checked against the release's published SHA-256 sums.
ARG NODE_MAJOR=24
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) NODE_ARCH='x64' ;; \
        arm64) NODE_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac; \
    NODE_DIST="https://nodejs.org/dist/latest-v${NODE_MAJOR}.x"; \
    curl -fsSL "$NODE_DIST/SHASUMS256.txt" -o SHASUMS256.txt; \
    NODE_FILE=$(grep -oE "node-v[0-9.]+-linux-${NODE_ARCH}\.tar\.xz$" SHASUMS256.txt); \
    curl -fsSL "$NODE_DIST/$NODE_FILE" -o "$NODE_FILE"; \
    grep " ${NODE_FILE}\$" SHASUMS256.txt | sha256sum -c -; \
    tar -xJf "$NODE_FILE" -C /usr/local --strip-components=1; \
    rm "$NODE_FILE" SHASUMS256.txt; \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    npm i -g fsh-sushi

# Install Jekyll and dependencies
RUN gem install jekyll bundler --no-document

# IG Publisher
RUN set -eux; \
    mkdir -p /opt/ig; \
    PUBLISHER_URL="https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"; \
    # -f: fail on HTTP errors, -L: follow redirects
    curl -fL "$PUBLISHER_URL" -o /opt/ig/publisher.jar; \
    # sanity check: 
    test $(stat -c%s /opt/ig/publisher.jar) -gt 1000000; \
    printf '#!/usr/bin/env bash\nexec java -Xmx4g -jar /opt/ig/publisher.jar "$@"\n' > /usr/local/bin/igpublisher; \
    chmod +x /usr/local/bin/igpublisher

WORKDIR /github/workspace