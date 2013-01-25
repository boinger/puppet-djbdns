class djbdns::install (
    $pkg_url = 'http://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
  ){

  if $pkg_url =~ /^.*\/([^\/]*)$/ { $pkg_tarball_name = $1 }
  if $pkg_tarball_name =~ /^(.*)\.tar\.gz$/ { $pkg_name = $1 }

  ## Sure, we'd like an rpm.  But there isn't one in the main distro's repo.
  ## If you have an rpm (or deb, I guess) of djbdns, just uncomment this
  ## and comment out the manual installation below.

  ## Simple package installation:
  #  package{'djbdns':
  #    ensure => installed,
  #  }

  ## Manual installation of djbdns

  file {
    "djbdns conf-cc":
      mode    => 644,
      owner   => root,
      group   => root,
      path    => "/usr/local/src/$pkg_name/conf-cc",
      source  => "puppet:///modules/djbdns/conf-cc",
      require => Exec['get djbdns'];
  }

  exec {
    'get djbdns':
      cwd     => '/usr/local/src',
      command => "/usr/bin/wget -q ${pkg_url} && tar xpfz ${pkg_tarball_name} && rm /package/${pkg_tarball_name}",
      creates => "/usr/local/src/${pkg_name}";

    'install djbdns':
      cwd     => "/usr/local/src/${pkg_name}",
      command => "make && make setup check",
      creates => '/usr/local/bin/tcpserver',
      require => [
        Exec['get djbdns'],
        File['djbdns conf-cc'],
        Class['daemontools::install'],
        Class['ucspi-tcp::install'],
        ];
  }

  ## End manual installation
}