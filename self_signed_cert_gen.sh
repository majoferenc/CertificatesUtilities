#!/bin/bash

CERT_CN=${CERT_CN}
KEY_PWD=${KEY_PWD}
KEY_ALIAS=${KEY_PWD}
KEYSTORE_PWD=${KEYSTORE_PWD}

if [ -z "${CERT_CN}" ]; then
    echo "#### Variable CERT_CN is not set"
    exit 1
fi

if [ -z "${KEY_PWD}" ]; then
    echo "#### Variable KEY_PWD is not set"
    exit 1
fi

if [ -z "${KEY_ALIAS}" ]; then
    echo "#### Variable KEY_ALIAS is not set"
    exit 1
fi

if [ -z "${KEYSTORE_PWD}" ]; then
    echo "#### Variable KEYSTORE_PWD is not set"
    exit 1
fi

echo "#### Generating PEM cert and private key..."
openssl req -new $([ "${KEY_PWD}" ] && echo "-passout pass:${KEY_PWD}" || echo "-nodes") -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -subj "/CN=${CERT_CN}"

echo "#### Generating PKCS12 keystore..."
openssl pkcs12 -name "${KEY_ALIAS}" -export -in cert.pem -inkey key.pem -certfile cert.pem -out keystore.p12 -passout pass:"${KEYSTORE_PWD}" $( [ "${KEY_PWD}" ] && echo "-passin pass:${KEY_PWD}")

echo "#### Generating JKS keystore..."
keytool -importkeystore -noprompt -srckeystore keystore.p12 -srcstoretype pkcs12 -destkeystore keystore.jks -deststoretype JKS -deststorepass "${KEYSTORE_PWD}"  -srcstorepass "${KEYSTORE_PWD}" -alias "${KEY_ALIAS}"
[ "${KEY_PWD}" ] && keytool -keypasswd -noprompt -new "${KEY_PWD}" -alias "${KEY_ALIAS}" -keystore keystore.jks -storepass "${KEYSTORE_PWD}"

echo "#### Base64 format of cert.pem..."
cat cert.pem | base64 | tr -d "\n"
echo "#### Base64 format of key.pem..."
cat key.pem | base64 | tr -d "\n"
