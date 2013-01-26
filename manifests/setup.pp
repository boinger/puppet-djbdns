class tinydns::setup {

  Package  { ensure => "installed", }

  $base_pkgs = [
    "make",
    "bsdutils",
    ]

  package { $base_pkgs: require => [Yumrepo['epel']], }

  exec {
    "rebuild-tinydns-data":
      cwd         => "/etc/tinydns/root",
      command     => "/usr/bin/make",
      refreshonly => true,
      notify      => Service["dnscache"],
      require     => [
        Class["djbdns::install"],
        Exec["tinydns-setup"],
        Exec["dnscache-setup"],
        ];

    "tinydns-setup":
      command => "/usr/bin/tinydns-conf tinydns dnslog /etc/tinydns 127.0.0.1",
      creates => "/etc/tinydns",
      require => Class["djbdns::install"];

    "dnscache-setup":
      command => "/usr/bin/dnscache-conf dnscache dnslog /etc/dnscache $ipaddress",
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
    "/etc/service/tinydns":
      ensure  => "/etc/tinydns",
      require => [Exec["tinydns-setup"], Exec["dnscache-setup"]];

    "/etc/service/dnscache":
      ensure  => "/etc/dnscache",
      require => [Exec["tinydns-setup"], Exec["dnscache-setup"]];

    "/etc/tinydns/log/run":
      owner   => "root",
      group   => "root",
      mode    => "0755",
      source  => "puppet:///modules/tinydns/tinydns-log",
      notify  => Service["tinydns-log"],
      require => [
        Exec["tinydns-setup"],
        Class["daemontoolsi::install"],
        Package["bsdutils"],
        ];

    "/etc/dnscache/log/run":
      owner   => "root",
      group   => "root",
      mode    => "0755",
      source  => "puppet:///modules/tinydns/dnscache-log",
      notify  => Service["dnscache-log"],
      require => [
        Exec["dnscache-setup"],
        Class["daemontoolsi::install"],
        Package["bsdutils"],
        ];
  }

  service {
    "dnscache":
      provider => "daemontools",
      path     => "/etc/dnscache";

    "dnscache-log":
      provider => "daemontools",
      path     => "/etc/dnscache/log";

    "tinydns":
      provider => "daemontools",
      path     => "/etc/tinydns";

    "tinydns-log":
      provider => "daemontools",
      path     => "/etc/tinydns/log";
  }
}