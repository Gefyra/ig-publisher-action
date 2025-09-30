FROM eclipse-temurin:21-jdk-jammy

# Minimal tools for CI + Ruby and Jekyll dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates unzip git xz-utils \
      ruby ruby-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

# Node 20 for SUSHI - Multi-arch binary installation
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) NODE_ARCH='x64' ;; \
        arm64) NODE_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac; \
    NODE_VERSION=20.17.0; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" -o node.tar.xz \
 && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
 && rm node.tar.xz \
 && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
 && npm i -g fsh-sushi

# Install Jekyll and dependencies
RUN gem install jekyll bundler --no-document

# IG Publisher
RUN mkdir -p /opt/ig \
 && curl -L "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar" \
    -o /opt/ig/publisher.jar \
 && printf '#!/usr/bin/env bash\nexec java -Xmx4g -jar /opt/ig/publisher.jar "$@"\n' > /usr/local/bin/igpublisher \
 && chmod +x /usr/local/bin/igpublisher

WORKDIR /github/workspace