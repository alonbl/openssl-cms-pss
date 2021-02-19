#!/bin/sh

die() {
	echo "FATAL: $1" >&2
	exit 1
}

doit() {
	local args="$1"
	rm -f 1.cms 2.cms
	echo "cms -sign 1.cms"
	openssl \
		cms \
		-sign \
		-signer test1.crt \
		-inkey test1.key \
		-binary \
		-nosmimecap \
		-keyid \
		-in data.txt \
		-out 1.cms \
		-outform DER \
		${args} \
		|| die "sign to 1.cms failed"
	echo "cms -verify 1.cms"
	openssl \
		cms \
		-verify \
		-binary \
		-in 1.cms \
		-inform DER \
		-content data.txt \
		-noverify \
		|| die "verify 1.cms failed"
	echo "cms -resign 1.cms to 2.cms"
	openssl \
		cms \
		-resign \
		-signer test2.crt \
		-inkey test2.key \
		-binary \
		-nosmimecap \
		-keyid \
		-in 1.cms \
		-inform DER \
		-out 2.cms \
		-outform DER \
		${args} \
		|| die "resign to 2.cms failed"
	echo "cms -verify 2.cms"
	openssl \
		cms \
		-verify \
		-binary \
		-in 2.cms \
		-inform DER \
		-content data.txt \
		-noverify \
		|| die "verify 2.cms failed"
}

openssl version

echo "==============="
echo "CMS without padding mode"
echo "==============="
( doit )
echo "==============="
echo "CMS with PKCS1 padding mode"
echo "==============="
( doit "-keyopt rsa_padding_mode:pkcs1" )
echo "==============="
echo "CMS with PSS"
echo "==============="
( doit "-keyopt rsa_padding_mode:pss" )
