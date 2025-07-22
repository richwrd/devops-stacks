#!/bin/sh

# Verifica se o serviço está vivo via socket TCP direto na porta 9002
exec 3<>/dev/tcp/localhost/9002
if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi
