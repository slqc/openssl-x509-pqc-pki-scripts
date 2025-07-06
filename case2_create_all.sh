#!/bin/bash

PREFIX=case2
ALGO=Dilithium-3
CA_CN="            case2-ca"
SJ_CN="      case2-subject1"

rm -f $PREFIX-ca-privkey.der
rm -f $PREFIX-ca-pubkey.der
rm -f $PREFIX-privkey.der
rm -f $PREFIX-pubkey.der
rm -f $PREFIX-ca.csr
rm -f $PREFIX-ca.der
rm -f $PREFIX.csr
rm -f $PREFIX.crt
rm -f $PREFIX.der

if [[ " $* " == *" clean "* ]]; then

  echo "Deleted case2"
  exit 1

fi

# CA keypair
# botan keygen --algo=ML-DSA --params='ML-DSA-6x5' --output=case2-ca-privkey.pem

botan keygen --algo=Dilithium-3 --output=$PREFIX-ca-privkey.pem
botan gen_self_signed $PREFIX-ca-privkey.pem "CN=${CA_CN}" --ca --days=365 --output=$PREFIX-ca.crt

# Subject keypair & CSR
botan keygen --algo=$ALGO --output=$PREFIX-privkey.pem
botan gen_pkcs10 $PREFIX-privkey.pem "CN=${SJ_CN}" --output=$PREFIX.csr

# Issue cert
# botan cert_gen --ca-key $PREFIX-ca-privkey.pem --ca-cert $PREFIX-ca.crt --days 365 --csr $PREFIX.csr --output $PREFIX.crt
botan sign_cert --duration=365 $PREFIX-ca.crt $PREFIX-ca-privkey.pem $PREFIX.csr --output=$PREFIX.crt





# generate CA keys
openssl genpkey -algorithm $C1_ALGO -out $C1-ca-privkey.der -outform DER
openssl pkey -in ./$C1-ca-privkey.der -pubout -out $C1-ca-pubkey.der -outform DER

# generate subject keys
openssl genpkey -algorithm $C1_ALGO -out $C1-privkey.der -outform DER
openssl pkey -in ./$C1-privkey.der -pubout -out $C1-pubkey.der -outform DER

# create self signed CA csr:
openssl req -new -key $C1-ca-privkey.der -out $C1-ca.csr -config $C1-ca.cnf

# self sign CA 
openssl x509 -req -in $C1-ca.csr -signkey $C1-ca-privkey.der -out $C1-ca.der -outform DER -days 365

# create subject csr from config file
openssl req -new -key $C1-privkey.der -out $C1.csr -config $C1.cnf

# sign csr with CA key 
# openssl x509 -req -in $C1.csr -CA $C1-ca.der -CAkey $C1-ca-privkey.der -extensions v3_req \
-extfile <(echo -e "[v3_req]\nsubjectKeyIdentifier = none\nauthorityKeyIdentifier = none") -CAcreateserial -out $C1.crt -days 365

openssl x509 -req -in $C1.csr -CA $C1-ca.der -CAkey $C1-ca-privkey.der -extensions v3_req \
-extfile <(echo -e "[v3_req]\nsubjectKeyIdentifier = none\nauthorityKeyIdentifier = none") -CAcreateserial -out $C1.der -outform DER -days 365

echo '## Certificate size in bytes'
stat -c %s ./$C1.der

echo '## Public key size in bytes'
stat -c %s ./$C1-pubkey.der

echo '## Private key size in bytes'
stat -c %s ./$C1-privkey.der

echo '## Certificate in openssl ASN.1:'
openssl asn1parse -in $C1.crt