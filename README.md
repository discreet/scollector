[![Build Status](https://travis-ci.org/discreet/scollector.svg?branch=master)](https://travis-ci.org/discreet/scollector)

# scollector

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with scollector](#setup)
    * [What scollector affects](#what-scollector-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with scollector](#beginning-with-scollector)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will install and confgure the Scollector agent on both Windows and
Linux hosts. It will manage external collectors as well however there is
currently a dependency on the external collector being added to the module as a
static file in the files direcotry.

## Setup

### What scollector affects

* Creates a directory structure to install and configure Scollector
* Creates a Scollector service on Windows and places a startup script on Linux

### Setup Requirements

* [cyberious-pget >= 0.1.3](https://github.com/cyberious/puppet-pget)
* [maestrodev-wget >= 1.7.3](https://github.com/maestrodev/puppet-wget)
* [puppetlabs-stdlib >= 4.12.0](https://github.com/puppetlabs/puppetlabs-stdlib)

### Beginning with scollector

Due to the intricacies of this module there is no option to simply use an
include. You will be required to declare the `scollector` class and specify
valid inputs. Depending on your architecture this will either be by modifying
the parameters in `init.pp` or writing a profile with a class declaration or
multiple hiera lookups.

## Usage

Basic example using a class declaration:
```
class { '::scollector':
  use_hiera           => true,
  version             => '0.5.0',
  host                => '10.276.43.51',
  port                => '8067',
  external_collectors => true,
  freq_dir            => ['15', '30', '45', '60'],
  freq                => 60,
  full_host           => true,
  proto               => 'http',
  collector           => { nagios => { collector => 'Process',
                                       name      => 'Nagios',
                                       command   => 'nagios',
                                       args      => '.*nagios.cfg',
                                     },
                           bosun => { collector => 'Process',
                                      name      => 'Bosun',
                                      command   => '/sbin/sv',
                                      args      => 'status bosun',
                                    }
                         },
        tag_override  => { 'environment' => $::environment,
                           'what_am_i'   => "${::osfamily}_${::location}_${::environment}" }
}
```

External Collector example without hiera:
```
scollector::collector { 'sendthings.py':
  ensure => present,
  freq   => '45',
}
```

External Collector example using hiera:
```
scollector::custom_collector:
  'sendthings.py':
    ensure: present
    freq: '45'
```
## Reference

**Classes**
* [scollector](https://github.com/discreet/scollector/blob/master/manifests/init.pp)
* [redhat](https://github.com/discreet/scollector/blob/master/manifests/redhat.pp)
* [windows](https://github.com/discreet/scollector/blob/master/manifests/windows.pp)
* [collectors](https://github.com/discreet/scollector/blob/master/manifests/collectors.pp)

**Defines**
* [collector](https://github.com/discreet/scollector/blob/master/manifests/collector.pp)

**Custom Facts**
* [scollector_version](https://github.com/discreet/scollector/blob/master/lib/facter/scollector_version.rb)

**BONUS!**
* [bosun_mirror.rb](https://github.com/discreet/scollector/blob/master/files/bosun-mirror.rb)

**Parameters**

`use_hiera`  
If Hiera data should be used to create external collectors  
Type: boolean  
Default: false  
*required*

`version`  
The version of Scollector to install on the node  
Type: string  
Default: undef  
*required*

`host`  
The host to have Scollector send metrics to  
Type: string  
Default: undef  
*required*

`port`  
The port for Scollector to use to connect to the host  
Type: string  
Default: 8090  
*required*

`user`  
The user for Scollector to authenticate with  
Type: string  
Default: undef  
*optional*

`password`  
The password for authentication  
Type: string  
Default: undef  
*optional*

`external_collectors`  
Whether or not external collectors are going to be used   
Type: boolean  
Default: false  
*required*

`freq`  
The frequency in seconds to send metrics  
Type: integer  
Default: 60  
*required*

`freq_dir`  
The directory to deploy external collectors to in relation to frequency  
Type: array  
Default: undef  
*optional*

`full_host`  
Whether or not to use the full hostname when sending metrics  
Type: boolean  
Default: false  
*required*

`proto`  
The protocol to connect to the host with  
Type: string  
Default: https  
*required*

`collector`  
The native collector to use with valid inputs  
Type: hash  
Default: undef  
*optional*

`tag_override`  
What tags to override in the scollector.toml file  
Type: hash  
Default: undef  
*optional*

## Limitations

* Only written for RHEL 6/7 and Windows 2008R2/2012R2
* Only supports x86_64 and x64 bit architecture

## Development

1. Fork the project
2. Create your feature and fully test it
3. Write your tests
4. Squash your commits
5. Submit a pull request to the upstream

