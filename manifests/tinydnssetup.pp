class djbdns::tinydnssetup {

  exec {
    "rebuild-tinydns-data":
      cwd         => "/etc/tinydns/root",
      command     => "/usr/bin/make",
      refreshonly => true,
      notify      => Daemontools::Service["dnscache"],
      require     => [
        Class["djbdns::install"],
        Exec["tinydns-setup"],
        ];

    "tinydns-setup":
      command => "/usr/local/bin/tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0",
      creates => "/etc/tinydns",
      require => [
        Class["djbdns::install"],
        User['tinydns'],
        User['dnslog'],
        ];

    "tinydns log restart":
      command => '/usr/local/bin/svc -t /service/tinydns/log',
      refreshonly => true;
  }

  user {
    "tinydns":
      ensure  => present,
      uid     => 40,
      comment => "Tinydns User",
      home    => "/dev/null",
      shell   => "/bin/false";
  }

  if (!defined(User["dnslog"])){ ## might already be defined in djbdns::dnscachesetup
    user {
      "dnslog":
        ensure  => present,
        uid     => 42,
        comment => "Djbdns Log User",
        home    => "/dev/null",
        shell   => "/bin/false";
    }
  }

  file {
    "/etc/tinydns/log/run":
      owner   => "dnslog",
      group   => "dnslog",
      mode    => 0755,
      source  => "puppet:///modules/djbdns/tinydns-log",
      notify  => Exec["tinydns log restart"],
      require => [
        Exec["tinydns-setup"],
        Package['util-linux-ng'],
        Class["daemontools::install"],
        ];
  }

}