#!/bin/bash

#openssl asn1parse -in case1.der -inform DER
#    4:d=1  hl=4 l=2180 cons: SEQUENCE          
# 2201:d=1  hl=4 l=3310 prim: BIT STRING 

#dd if=case1.der of=case1-tbs.bin bs=1 skip=4 count=2180
#dd if=case1.der of=case1-sig.bin bs=1 skip=2201 count=3310

openssl dgst -sha3-512 -verify case1-ca-pubkey.der -signature case1-sig.bin case1-tbs.bin