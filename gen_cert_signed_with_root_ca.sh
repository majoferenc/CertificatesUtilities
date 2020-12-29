#!/bin/sh

if [ "$#" -ne 1 ]
then
  echo "Usage: Must supply a domain"
  exit 1
fi

DOMAIN=$1

cd ~/certs

echo "#### Creating CA-Signed Certificate..."
openssl genrsa -out $DOMAIN.key 2048

echo "#### Creating Certificate Sign Request CSR..."
openssl req -new -key $DOMAIN.key -out $DOMAIN.csr

cat > $DOMAIN.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
EOF

echo "#### Creating certificate signed by our CA..."
openssl x509 -req -in $DOMAIN.csr -CA ../myCA.pem -CAkey ../myCA.key -CAcreateserial -out $DOMAIN.crt -days 825 -sha256 -extfile $DOMAIN.ext
