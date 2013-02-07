class tinydns::setup {

  Package  { ensure => "installed", require => [Yumrepo['epel']], }

  $base_pkgs = [
    "make",
    "util-linux-ng", ## like bsdutils
    ]

  package { $base_pkgs: }

  exec {
    "rebuild-tinydns-data":
      cwd         => "/etc/tinydns/root",
      command     => "/usr/bin/make",
      refreshonly => true,
      notify      => Daemontools::Service["dnscache"],
      require     => [
        Class["djbdns::install"],
        Exec["tinydns-setup"],
        Exec["dnscache-setup"],
        ];

    "tinydns-setup":
      command => "/usr/local/bin/tinydns-conf tinydns dnslog /etc/tinydns 127.0.0.1",
      creates => "/etc/tinydns",
      require => Class["djbdns::install"];

    "dnscache-setup":
      command => "/usr/local/bin/dnscache-conf dnscache dnslog /etc/dnscache $ipaddress",
      creates => "/etc/dnscache",
      require => Class["djbdns::install"];
  }

  user {
    "tinydns":
      ensure  => present,
      uid     => 40,
      comment => "Tinydns User",
      home    => "/dev/null",
      shell   => "/bin/false";

    "dnscache":
      ensure  => present,
      uid     => 41,
      comment => "Dnscache User",
      home    => "/dev/null",
      shell   => "/bin/false";

    "dnslog":
      ensure  => present,
      uid     => 42,
      comment => "Djbdns Log User",
      home    => "/dev/null",
      shell   => "/bin/false";
  }

  file {
    "/etc/tinydns/log/run":
      owner   => "root",
      group   => "root",
      mode    => "0755",
      source  => "puppet:///modules/djbdns/tinydns-log",
      notify  => Daemontools::Service["tinydns-log"],
      require => [
        Exec["tinydns-setup"],
        Package['util-linux-ng'],
        Class["daemontools::install"],
        ];

    "/etc/dnscache/log/run":
      owner   => "root",
      group   => "root",
      mode    => "0755",
      source  => "puppet:///modules/djbdns/dnscache-log",
      notify  => Daemontools::Service["dnscache-log"],
      require => [
        Exec["dnscache-setup"],
        Package['util-linux-ng'],
        Class["daemontools::install"],
        ];
  }

}