# Example for local testing
mkdir -p test-ig
cd test-ig

# Create a simple IG structure for testing
cat > ig.ini << 'EOF'
[IG]
ig = test-ig
template = fhir.base.template
status = active
version = 1.0.0
copyrightYear = 2024
releaseLabel = ci-build
publisher = Test Publisher
EOF

cat > sushi-config.yaml << 'EOF'
id: test-ig
name: TestIG
title: Test Implementation Guide
version: 1.0.0
fhirVersion: 4.0.1
copyrightYear: 2024
releaseLabel: ci-build
publisher:
  name: Test Publisher
EOF

mkdir -p input/fsh
cat > input/fsh/example.fsh << 'EOF'
Profile: TestPatient
Parent: Patient
Description: "A test patient profile"
* name 1..* MS
EOF

echo "Test setup created in test-ig/"
echo "Use: docker run --rm -v \$(pwd):/github/workspace ghcr.io/gefyra/ig-publisher:latest igpublisher -ig ig.ini"