# == Class ckan::install
#
# installs ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
#
class ckan::install {

  class { 'wget': version => latest}

  # Install Jetty
  package { ['openjdk-6-jdk', 'solr-jetty']:
    ensure => present,
  }

  # Install Postgres
  if $ckan::setup_postgres_server == true {
    class { 'postgresql::server':
      pg_hba_conf_defaults => $ckan::pg_hba_conf_defaults,
      postgres_password    => $ckan::postgres_pass,
      listen_addresses     => '*',
    }
  }

  # Install CKAN deps
  $ckan_libs = ['apache2', 'libapache2-mod-wsgi', 'nginx', 'libpq5',
                'python-pastescript']
  ensure_resource('package', $ckan_libs, { ensure => present })
  exec { 'a2enmod wsgi':
    command => '/usr/sbin/a2enmod wsgi',
    creates => '/etc/apache2/mods-enabled/wsgi.conf',
    require => Package['apache2', 'libapache2-mod-wsgi'],
  }

  # Install CKAN either from APT repositories or from the specified file
  if $ckan::is_ckan_from_repo == true {
    package { 'python-ckan':
      ensure  => latest,
      require => Package[$ckan_libs],
    }
  } else {
    file { $ckan::ckan_package_dir:
      ensure => directory,
    }
    wget::fetch { 'ckan package':
      source      => $ckan::ckan_package_url,
      destination => "${ckan::ckan_package_dir}/${ckan::ckan_package_filename}",
      verbose     => false,
      require     => File[$ckan::ckan_package_dir],
    }
    package { 'python-ckan':
      ensure   => latest,
      provider => dpkg,
      source   => "${ckan::ckan_package_dir}/${ckan::ckan_package_filename}",
      require  => [Wget::Fetch['ckan package'], Package[$ckan_libs]],
    }
  }

  # Install Node and NPM (which comes with Node)
  include nodejs

  # less requires a compile of the css before changes take effect.
  exec { 'Install Less and Nodewatch':
    command => '/usr/bin/npm install less nodewatch',
    cwd     => '/usr/lib/ckan/default/src/ckan',
    require => [Package['nodejs'], Package['python-ckan']],
    creates => '/usr/lib/ckan/default/src/ckan/bin/less',
  }

  # Git is necessary for installing extensions
  package { 'git-core':
    ensure => present,
  }

  # setup the plugin collector 
  file {'/opt/ckan_plugin_collector':
    ensure => directory,
  }

  file {'/opt/ckan_plugin_collector/plugin_collector.bash':
    ensure  => file,
    source  => 'puppet:///modules/ckan/plugin_collector.bash',
    mode    => '0755',
    require => File['/opt/ckan_plugin_collector'],
  }
}
