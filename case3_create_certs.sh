#!/bin/bash

PREFIX=case3



# delete old files to prevent confusion if commands fail
rm -f $PREFIX-ca-csr.der
rm -f $PREFIX-ca.der
rm -f $PREFIX.csr.der
rm -f $PREFIX.crt
rm -f $PREFIX.der

if [[ " $* " == *" clean "* ]]; then

  echo "Deleted case1"
  exit 1

fi

# create self signed CA csr:
openssl req -new -key $PREFIX-ca-privkey.der -outform DER -out $PREFIX-ca-csr.der -config $PREFIX-ca.cnf

# self sign CA 
openssl x509 -req -in $PREFIX-ca-csr.der -signkey $PREFIX-ca-privkey.der -extensions v3_none -extfile exts.cnf -out $PREFIX-ca.der -outform DER -days 365


# create intermediate csr from config file
openssl req -new -key $PREFIX-im-privkey.der -outform DER -out $PREFIX-im-csr.der -config $PREFIX-im.cnf

# sign intermediate with CA key 

openssl x509 -req -in $PREFIX-im-csr.der -CA $PREFIX-ca.der -CAkey $PREFIX-ca-privkey.der -extensions v3_none -extfile exts.cnf -CAcreateserial -out $PREFIX-im.der -outform DER -days 365

# create subject csr from config file
openssl req -new -key $PREFIX-privkey.der -outform DER -out $PREFIX-csr.der -config $PREFIX.cnf

# sign csr with intermediate key 

openssl x509 -req -in $PREFIX-csr.der -CA $PREFIX-im.der -CAkey $PREFIX-im-privkey.der -extensions v3_none -extfile exts.cnf -CAcreateserial -out $PREFIX.der -outform DER -days 365

# create PKCS#7 'degenerate "certificates only" structure' (name given by OpenSSL manual)
openssl crl2pkcs7 -nocrl -certfile <(openssl x509 -inform DER -in $PREFIX-ca.der -outform PEM) \
                  -certfile <(openssl x509 -inform DER -in $PREFIX-im.der -outform PEM) \
                  -certfile <(openssl x509 -inform DER -in $PREFIX.der -outform PEM) \
                  -out $PREFIX-chain.p7b -outform DER

echo '## Certificate size in bytes'
stat -c %s ./$PREFIX.der

echo '## Public key size in bytes'
stat -c %s ./$PREFIX-pubkey.der

echo '## Private key size in bytes'
stat -c %s ./$PREFIX-privkey.der

echo '## Certificate in openssl ASN.1:'
openssl asn1parse -in $PREFIX.der -inform DER