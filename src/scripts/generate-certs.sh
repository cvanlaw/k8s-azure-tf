#!/bin/bash

full_path=$(realpath $0)
scripts_directory=$(dirname $full_path)
repo_root=$(dirname $scripts_directory)
cert_directory="$repo_root/certificates"
cd $cert_directory
command -v cfssl >/dev/null 2>&1 || { echo >&2 "cfssl required but it's not installed.  Aborting."; exit 1; }

[ ! -d $cert_directory ] && { echo "Directory $cert_directory DOES NOT exists. Aborting."; exit 1; }


echo "Init CA..."
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

echo "Generate admin cert..."
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

echo "Generate kube-controller-manager cert..."
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

echo "Generate kube-proxy cert..."
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

echo "Generate kube-scheduler cert..."
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

echo "Generate service account cert..."
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
