#!/usr/bin/env bash
set -e

help() {
  echo "============= development-environment-setup-script ============="
  echo
  echo "Options"
  echo "      --skip-install-docker:     Skip to install docker"
  echo "      --code-server-version:     Set code-server version"
  echo "      --code-server-password:    Set code-server Password"
  echo "      --code-server-tls-domain:  Set code-server TLS domain"
  echo
  echo "================================================================"
}

while [ $# -gt 0 ]; do
	case "$1" in
    --help)
      help
      exit 0
      shift
      ;;
    --skip-install-docker) 
      FLAG_SKIP_INSTALL_DOCKER=true          
      ;;
    --code-server-version)
      CODE_SERVER_VERSION=$2
      shift
      ;;
    --code-server-password) 
      CODE_SERVER_PASSWORD=$2
      shift
      ;;
    --code-server-tls-domain)
      CODE_SERVER_TLS_ENABLE=true
      CODE_SERVER_TLS_DOMAIN=$2
      shift
      ;;
		--*)
			echo "Illegal option $1"
      exit 2
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

DEFAULT_FLAG_SKIP_INSTALL_DOCKER=false
if [ -z $FLAG_SKIP_INSTALL_DOCKER ]; then
  read -p "skip-install-docker(true|default: false): " FLAG_SKIP_INSTALL_DOCKER
  if [ ! $FLAG_SKIP_INSTALL_DOCKER = 'true' ]; then
  	FLAG_SKIP_INSTALL_DOCKER=false
  fi
fi

if [ -z $CODE_SERVER_VERSION ]; then
  read -p "code-server-version: " CODE_SERVER_VERSION
fi

if [ -z $CODE_SERVER_PASSWORD ]; then
  read -p "code-server-password: " -s CODE_SERVER_PASSWORD; echo
fi

if [ -z $CODE_SERVER_TLS_ENABLE ]; then
  read -p "code-server-tls-enable(true|default: false): " CODE_SERVER_TLS_ENABLE
  if [ ! $CODE_SERVER_TLS_ENABLE  = 'true' ]; then
    CODE_SERVER_TLS_ENABLE=false
  fi
fi

if [ $CODE_SERVER_TLS_ENABLE = 'true' ] && [ -z $CODE_SERVER_TLS_DOMAIN ]; then
  read -p "code-server-tls-domain: " CODE_SERVER_TLS_DOMAIN
fi

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

ensure_installed_ansible() {
  if command_exists 'ansible'; then
    return
  fi

  echo "ansible isn't installed!"
  echo "Install ansible through apt"

  sudo apt update
  sudo apt install -y ansible
}

execute_ansible() {
  local cur_path=$( cd "$(dirname "$0")" ; pwd )
  local workspace_path=$( cd "$(dirname "$cur_path")" ; pwd )

  sh -c "cd $workspace_path && ansible-playbook -i hosts playbook.yml \
    --extra-vars skip_docker=$FLAG_SKIP_INSTALL_DOCKER \
    --extra-vars code_server_ver=$CODE_SERVER_VERSION \
    --extra-vars code_server_password=$CODE_SERVER_PASSWORD \
    --extra-vars code_server_tls_enable=$CODE_SERVER_TLS_ENABLE \
    --extra-vars code_server_tls_domain=$CODE_SERVER_TLS_DOMAIN"
}

setup() {
  ensure_installed_ansible
  execute_ansible
}

setup
