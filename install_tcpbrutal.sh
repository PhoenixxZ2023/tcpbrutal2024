#!/usr/bin/env bash
#
# install_dkms.sh - tcp-brutal dkms module install script with menu
# Try `install_dkms.sh --help` for usage.
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Aperture Internet Laboratory
#

set -e

# Defina o nome e a versão do módulo
DKMS_MODULE_NAME="tcp_brutal"
DKMS_MODULE_VERSION="1.0"

# Função para exibir o menu
menu() {
  clear
  echo "-----------------------------------"
  echo " TCP-Brutal DKMS Module Installer "
  echo "-----------------------------------"
  echo "1. Instalar TCP-Brutal"
  echo "2. Remover TCP-Brutal"
  echo "3. Desativar TCP-Brutal"
  echo "4. Reiniciar Servidor"
  echo "5. Sair"
  echo "-----------------------------------"
  echo -n "Escolha uma opção: "
}

# Função para instalar TCP-Brutal
install_tcp_brutal() {
  echo "Iniciando a instalação do TCP-Brutal..."
  perform_install
  echo "Instalação concluída!"
  sleep 2
}

# Função para remover TCP-Brutal
remove_tcp_brutal() {
  echo "Removendo o TCP-Brutal..."
  dkms_remove_modules "$DKMS_MODULE_NAME"
  echo "Remoção concluída!"
  sleep 2
}

# Função para desativar TCP-Brutal
deactivate_tcp_brutal() {
  echo "Desativando o TCP-Brutal..."
  kmod_unload_if_loaded "$DKMS_MODULE_NAME"
  echo "TCP-Brutal desativado!"
  sleep 2
}

# Função para reiniciar o servidor
restart_server() {
  echo "Reiniciando o servidor..."
  sleep 2
  sudo reboot
}

# Funções originais do script
perform_install() {
    dkms_remove_modules "$DKMS_MODULE_NAME"
    dkms_build_and_install_modules "$DKMS_MODULE_NAME" "$DKMS_MODULE_VERSION"
    dkms_sign_modules "$KERNEL_MODULE_NAME"
    kmod_load_module "$KERNEL_MODULE_NAME"
}

dkms_remove_modules() {
    local module_name=$1

    if dkms status | grep -q "^${module_name}/"; then
        dkms remove --all --force "${module_name}"
    fi
}

dkms_build_and_install_modules() {
    local module_name=$1
    local module_version=$2
    dkms add "${module_name}/${module_version}"
    dkms build "${module_name}/${module_version}"
    dkms install --force "${module_name}/${module_version}"
}

dkms_sign_modules() {
    local module_name=$1
    if command -v kmodsign &>/dev/null; then
        kmodsign sha512 /etc/pki/kernel/signing_key.pem /etc/pki/kernel/signing_key.x509 "/lib/modules/$(uname -r)/extra/${module_name}.ko"
    fi
}

kmod_load_module() {
    local module_name=$1

    if ! lsmod | grep -q "^${module_name}"; then
        modprobe "${module_name}"
    fi
}

kmod_unload_if_loaded() {
    local module_name=$1

    if lsmod | grep -q "^${module_name}"; then
        modprobe -r "${module_name}"
    fi
}

# Loop principal do menu
while true; do
  menu
  read option
  case $option in
    1)
      install_tcp_brutal
      ;;
    2)
      remove_tcp_brutal
      ;;
    3)
      deactivate_tcp_brutal
      ;;
    4)
      restart_server
      ;;
    5)
      echo "Saindo..."
      exit 0
      ;;
    *)
      echo "Opção inválida! Tente novamente."
      sleep 2
      ;;
  esac
done
