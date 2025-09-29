FROM eclipse-temurin:21-jdk-jammy

# Minimal tools for CI
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates unzip git \
    && rm -rf /var/lib/apt/lists/*

# Node 20 for SUSHI
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && npm i -g fsh-sushi

# IG Publisher
RUN mkdir -p /opt/ig \
 && curl -L "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar" \
    -o /opt/ig/publisher.jar \
 && printf '#!/usr/bin/env bash\nexec java -Xmx4g -jar /opt/ig/publisher.jar "$@"\n' > /usr/local/bin/igpublisher \
 && chmod +x /usr/local/bin/igpublisher

WORKDIR /github/workspace