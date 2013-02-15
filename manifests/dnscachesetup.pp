class djbdns::dnscachesetup {

  exec {
    "dnscache-setup":
      command => "/usr/local/bin/dnscache-conf dnscache dnslog /etc/dnscache 0.0.0.0",
      creates => "/etc/dnscache",
      require => [
        Class["djbdns::install"],
        User['dnslog'],
        User['dnscache'],
        ];
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