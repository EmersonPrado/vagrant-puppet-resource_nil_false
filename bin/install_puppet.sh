#!/bin/bash

error () {
  local status="$1"
  shift
  printf '%s\n' "$@" >&2
  exit "$status"
}

distro_version () {
  case "$(cat /proc/version)" in
    *'Debian'*|*'Ubuntu'*)
      os_family=debian
      os_version=$(awk -F'[=."]+' '$1 == "VERSION_CODENAME" { print $2 }' /etc/os-release)
      ;;
    *'Red Hat'*)
      os_family=redhat
      os_version=$(sed 's/^[^[:digit:]]*\([[:digit:]]*\)\..*$/\1/' /etc/redhat-release)
      ;;
    *'SUSE'*)
      os_family=suse
      os_version=$(awk -F'[=."]+' '$1 == "VERSION" { print $2 }' /etc/os-release)
    ;;
    *) error 1 'Supported families: Debian, Red Hat and SUSE' ;;
  esac
}

check_installer () {
  wget --spider -q "$url"
  case "$?" in
    8) error 2 "${os_family} ${os_version} not compatible with Puppet ${target_version}" ;;
    [^0]) error 3 "Link to installer repo $url is broken" ;;
  esac
}

install_debian() {
  local installer="puppet${target_version}-release-${os_version}.deb"
  local url="https://apt.puppet.com/${dir}${installer}"
  rm -f puppet*-release-*.deb*
  check_installer
  # shellcheck disable=SC2046
  sudo apt -y purge $(
    dpkg -l 'puppet*' 2> /dev/null |
    awk '$1 ~ /^.i$/ { print $2 }'
  )
  wget -nv "$url"
  dpkg -i "$installer"
  apt-get update
  apt-get -y install puppet-agent
  rm -f "$installer"
}

install_redhat() {
  local pkg_manager
  local installer="puppet${target_version}-release-el-${os_version}.noarch.rpm"
  local url="https://yum.puppet.com/${dir}${installer}"
  check_installer
  if command -v dnf > /dev/null 2>&1 ; then
    pkg_manager=dnf
    repo_option=('--repo' "puppet${target_version}")
  else
    pkg_manager=yum
    repo_option=("--disablerepo='*'" "--enablerepo=puppet${target_version}")
  fi
  $pkg_manager -y erase 'puppet*'
  rpm -Uvh "$url"
  $pkg_manager -y "${repo_option[@]}" install puppet-agent
}

install_suse() {
  local installer="puppet${target_version}-release-sles-${os_version}.noarch.rpm"
  local url="https://yum.puppet.com/${dir}${installer}"
  zypper -n --gpg-auto-import-keys install wget
  check_installer
  # shellcheck disable=SC2046
  zypper remove -y $(rpm -qa | grep puppet)
  rpm -Uvh "$url"
  zypper -n --gpg-auto-import-keys install puppet-agent
}

distro_version
target_version=$1
# shellcheck disable=SC2154
printf 'Distro: %s\tOS version: %s\tPuppet version: %s\n' "$os_family" "$os_version" "$target_version"

case $target_version in
  5)    dir='eol-releases/' ;;
  6|7|8)  dir=''              ;;
  *)    error 2 'Puppet supported versions: 5, 6, 7 and 8' ;;
esac

installed="$(/opt/puppetlabs/bin/puppet -V 2> /dev/null | cut -d. -f 1)"

if ((installed != target_version)) ; then
  case $os_family in
    debian) install_debian ;;
    redhat) install_redhat ;;
    suse)   install_suse   ;;
  esac
fi
