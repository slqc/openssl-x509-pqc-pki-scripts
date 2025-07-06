#!/bin/bash

PREFIX=case3
ALGO=mldsa65

# delete old files to prevent confusion if commands fail
rm -f $PREFIX-ca-privkey.der
rm -f $PREFIX-ca-pubkey.der
rm -f $PREFIX-im-privkey.der
rm -f $PREFIX-im-pubkey.der
rm -f $PREFIX-privkey.der
rm -f $PREFIX-pubkey.der

if [[ " $* " == *" clean "* ]]; then

  echo "Deleted case3"
  exit 1

fi

# generate CA keys
openssl genpkey -algorithm $ALGO -out $PREFIX-ca-privkey.der -outform DER
openssl pkey -in ./$PREFIX-ca-privkey.der -pubout -out $PREFIX-ca-pubkey.der -outform DER

# generate intermediate keys
openssl genpkey -algorithm $ALGO -out $PREFIX-im-privkey.der -outform DER
openssl pkey -in ./$PREFIX-im-privkey.der -pubout -out $PREFIX-im-pubkey.der -outform DER

# generate subject keys
openssl genpkey -algorithm $ALGO -out $PREFIX-privkey.der -outform DER
openssl pkey -in ./$PREFIX-privkey.der -pubout -out $PREFIX-pubkey.der -outform DER

