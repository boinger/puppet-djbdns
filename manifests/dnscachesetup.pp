class djbdns::dnscachesetup {

  exec {
    "dnscache-setup":
      command => "/usr/local/bin/dnscache-conf dnscache dnslog /etc/dnscache 127.0.0.1",
      creates => "/etc/dnscache",
      require => [
        Class["djbdns::install"],
        User['dnslog'],
        User['dnscache'],
        ];

    "dnscache log restart":
      command => '/usr/local/bin/svc -t /service/dnscache/log',
      refreshonly => true;
  }

  user {
    "dnscache":
      ensure  => present,
      uid     => 41,
      comment => "Dnscache User",
      home    => "/dev/null",
      shell   => "/bin/false";
  }

  if (!defined(User["dnslog"])){ ## might already be defined in djbdns::tinydnssetup
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
    "/etc/dnscache/log/run":
      owner   => "dnslog",
      group   => "dnslog",
      mode    => 0755,
      source  => "puppet:///modules/djbdns/dnscache-log",
      notify  => Exec["dnscache log restart"],
      require => [
        Exec["dnscache-setup"],
        Package['util-linux-ng'],
        Class["daemontools::install"],
        ];
  }

}