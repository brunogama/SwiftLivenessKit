#!/bin/bash

# Certificate extraction script for liveness vendors
VENDORS=(
    "api.vendor-a.com"
    "api.vendor-b.com"
    "liveness.vendor-c.io"
)

mkdir -p ../Certificates

for vendor in "${VENDORS[@]}"; do
    echo "Extracting certificate for $vendor..."
    
    # Extract certificate
    openssl s_client -connect "${vendor}:443" -servername "$vendor" < /dev/null 2>/dev/null | \
        openssl x509 -outform DER > "../Certificates/${vendor}.cer" || echo "Failed to extract $vendor"
    
    # Get certificate info
    if [ -f "../Certificates/${vendor}.cer" ]; then
        echo "Certificate info for $vendor:"
        openssl x509 -in "../Certificates/${vendor}.cer" -inform DER -text -noout | \
            grep -E "(Subject:|Issuer:|Not After)" || true
        echo "---"
    fi
done

echo "Certificates extracted to Resources/Certificates/"