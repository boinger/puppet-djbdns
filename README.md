puppet-djbdns
================

This module can be used to:
* install djbdns
* manage tinydns data files

##Requirements ##

You need to enable storeconfigs to allow host defs to create their own dnsrecords & have the dns master node pull them all in.

In your puppetmaster (v2.6+) config (mine's at /etc/puppet/puppet.conf):
```ini
[master]
  storeconfigs = true
  thin_storeconfigs = true
  dbadapter = postgresql
  dbuser = puppet
  dbpassword = password
  dbserver = localhost
  dbname = puppet
```

Set up a postgresql (or mysql) db backend to store configs.

See also: http://docs.puppetlabs.com/guides/exported_resources.html & http://projects.puppetlabs.com/projects/puppet/wiki/Using_Stored_Configuration

##  Usage ##

### djbdns Installation
```puppet
  class { 'djbdns::install': }
```
### Manage tinydns

#### Before the interesting parts
Include tinydns::setup to get the command to re-gen data.cdb

```puppet
    include tinydns::setup
```

#### NS record
Per http://cr.yp.to/djbdns/tinydns-data.html

```puppet
    dnsrecord {
      "boin.gr NS & A":
        ensure => present,
        fqdn   => "boin.gr",
        ipaddr => "10.1.1.1",
        type   => ".",
        notify => Exec["rebuild-tinydns-data"]
    }
```

#### Reverse lookups for your subnet
With this, the `type => '='` attribute will auto-create the forward (A) and reverse (PTR)
```puppet
    dnsrecord {
      "10.1.1.0/24 PTRs":
        ensure => present,
        fqdn   => "1.1.10.in-addr.arpa",
        ipaddr => "10.1.1.1",
        type   => ".",
        notify => Exec["rebuild-tinydns-data"];
    }
```
#### A/PTR pair for each host:
By virtue of the resources under lib/, adding the following per server definition creates an A/PTR pair:
```puppet
    @@dnsrecord {
    "dns for $fqdn":
      ensure => "present",
      fqdn   => "$fqdn",
      ipaddr => "$ipaddress",
      type   => "=",
      ttl    => 300,
      notify => Exec["rebuild-tinydns-data"];
    }
```

#### Manual A record
```puppet
    @@dnsrecord {"puppet.boin.gr A"
      ensure => present,
      fqdn   => "puppet.boin.gr",
      ipaddr => "10.1.1.5",
      type   => ".",
      notify => Exec["rebuild-tinydns-data"]
    }
```

#### alias (not CNAME!)
Define alternate names for a host like this.

Usually define these in a host's def

(you usually want this instead of a CNAME)
```puppet
    @@dnsrecord {"pencil.boin.gr CNAME"
      ensure => present,
      fqdn   => "puppet.boin.gr",
      ipaddr => "10.1.1.8",
      type   => "+",
      notify => Exec["rebuild-tinydns-data"]
    }
```
#### Slurp in all the @@dnsrecord entries

On the master dns server's host def add this:
```puppet
Dnsrecord <<| |>>
```
    
## Notes
###TODO
Z (zone) record type

### Original project
Some of this project (the resource defs, mostly) is based on http://github.com/yendor/puppet-tinydns.git

## License
 Copyright (C) 2013 Jeff Vier <jeff@jeffvier.com> (Author)<br />
 License: Apache 2.0