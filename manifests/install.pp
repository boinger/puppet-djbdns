class djbdns::install (
    $pkg_url = 'http://cr.yp.to/djbdns/djbdns-1.05.tar.gz',
    $build_dir = '/usr/local/src',
  ){
  
  Package  { ensure => "installed", require => [Yumrepo['epel']], }

  if $operatingsystemmajrelease > 5 { $utillinux = 'util-linux-ng' }
    else { $utillinux = 'util-linux' }

  $prereq_pkgs = [
    "make",
    "$utillinux",
    ]

  package { $prereq_pkgs: }

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
      path    => "${build_dir}/$pkg_name/conf-cc",
      source  => "puppet:///modules/djbdns/conf-cc",
      require => Exec['get djbdns'];
  }

  exec {
    'get djbdns':
      cwd     => "${build_dir}",
      command => "/usr/bin/wget -q ${pkg_url} && tar xpfz ${pkg_tarball_name} && rm ${build_dir}/${pkg_tarball_name}",
      creates => "${build_dir}/${pkg_name}";

    'install djbdns':
      cwd     => "${build_dir}/${pkg_name}",
      command => "make && make setup check",
      creates => '/usr/local/bin/tinydns',
      require => [
        Exec['get djbdns'],
        File['djbdns conf-cc'],
        Class['daemontools::install'],
        Class['ucspi-tcp::install'],
        ];
  }

  ## End manual installation
}