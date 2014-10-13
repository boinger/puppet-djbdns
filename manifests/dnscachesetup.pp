class djbdns::dnscachesetup (
  $listen_on = '127.0.0.1',
  ){

 if $operatingsystemmajrelease > 5 { $utillinux = 'util-linux-ng' }
    else { $utillinux = 'util-linux' }

  exec {
    "dnscache-setup":
      command => "/usr/local/bin/dnscache-conf dnscache dnslog /etc/dnscache ${listen_on}",
      creates => "/etc/dnscache",
      require => [
        Class["djbdns::install"],
        User['dnslog'],
        User['dnscache'],
        ];

    "dnscache log restart":
      command     => '/usr/local/bin/svc -t /service/dnscache/log',
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
        Package["$utillinux"],
        Class["daemontools::install"],
        ];

    "/etc/dnscache/net-dns":
      recurse => true,
      source  => "puppet:///modules/djbdns/net-dns",
      require => Exec['dnscache-setup'];
  }

}
