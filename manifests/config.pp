# == Class: ckan::config
#
# Configuration supporting ckan
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
#
# === Parameters
# [*site_url*]
#   The site url of the ckan instance.  Defaults to localhost.
#
# [*site_title*]
#   The title of the ckan instance.  Defaults to localhost.
#
# [*site_description*]
#   This is for a description, or tag line for the site, as displayed in the
#   header of the CKAN web interface.
#
# [*site_intro*]
#   This is for an introductory text used in the default template's index page.
#
# [*site_about*]
#   Multiline string can be used by indenting lines.  The format is in
#   Markdown.
#
#   Its better to overload the snippet in home/snippets/about_text.html
#   because if this parameter is set, this is not automatically translated.
#
# [*site_logo*]
#   This sets the logo use din the title bar.
#
# [*plugins*]
#   Specifies which CKAN plugins are to be enabled.
#   Default: 'stats text_preview recline_preview'
#
# [*backup_dir*]
#   The location where backups are stored.
#   Default: /backup
#
# === Variables
#
# [*ckan_etc*]
#   The configuration directory.
#
# [*ckan_default*]
#   The default directory in the ckan directory.
#
# [*ckan_src*]
#   The ckan src directory.
#
# [*ckan_img_dir*]
#   The directory to install images.
#
# [*ckan_css_dir*]
#   The directory that contains the css files.
#
# [*storage_path*]
#   The directory that contains the storage (ie downloads).
#
# [*email_to*]
#   This controls where the error messages will be sent to.
#
# [*err_email_from*]
#   This controls from which email the error messages will come from.
#
# [*smtp_server*]
#   The SMTP server to connect to when sending emails with optional port.
#
# [*ckan_plugin_dir*]
#   The directory that contains files that builds the plugins entry in the
#   production ini file
#
# [*license_file*]
#   The name of the license file.
#
# [*ckan_conf*]
#   The default production ini file for ckan configuration.
#
# [*paster*]
#   The full path to the paster command.
#
class ckan::config (
  $site_url           = 'localhost',
  $site_title         = 'localhost',
  $site_description   = '',
  $site_intro         = '',
  $site_about         = '',
  $site_logo          = '',
  $plugins            = 'stats text_preview recline_preview',
  $backup_dir         = '/backup',
  $storage_path       = '/var/lib/ckan/default',
  $email_to           = '',
  $err_email_from     = '',
  $smtp_server        = ''
){

  # == variables ==
  $ckan_etc          = '/etc/ckan'
  $ckan_default      = "${ckan_etc}/default"
  $ckan_src          = '/usr/lib/ckan/default/src/ckan'
  $ckan_img_dir      = "${ckan_src}/ckan/public/base/images"
  $ckan_css_dir      = "${ckan_src}/ckan/public/base/css"
  $ckan_plugin_dir   = "${ckan_etc}/plugins"
  $license_file      = 'license.json'
  $ckan_conf         = "${ckan_default}/production.ini"
  $paster            = '/usr/lib/ckan/bin/paster'

  # Jetty configuration
  file {'/etc/default/jetty':
    ensure => file,
    source => 'puppet:///modules/ckan/jetty',
  }
  # Change default schema to use CKAN schema
  file {'/etc/solr/conf/schema.xml':
    ensure => link,
    target => "${ckan_src}/ckan/config/solr/schema.xml",
  }

  # CKAN configuration
  file { [$ckan_etc, $ckan_default]:
    ensure  => directory,
  }

  concat { $ckan_conf:
    owner => root,
    group => root,
    mode  => '0644',
  }
  concat::fragment { 'config_head':
    target  => $ckan_conf,
    content => template('ckan/production_head.ini.erb'),
    order   => 01,
  }
  concat::fragment { 'config_tail':
    target  => $ckan_conf,
    content => template('ckan/production_tail.ini.erb'),
    order   => 99,
  }
  
  # write default plugins
  file {"${ckan_etc}/plugins":
    ensure  => directory,
    require => File[$ckan_etc],
  }
  file {"${ckan_etc}/plugins/default":
    ensure  => file,
    content => inline_template("<%= scope.lookupvar('ckan::plugins') %>"),
    require => File["${ckan_etc}/plugins"],
  }

  $ckan_data_dir = unique(['/var/lib/ckan', $storage_path])
  file {$ckan_data_dir:
    ensure => directory,
    owner  => www-data,
    group  => www-data,
    mode   => '0755',
  }

  # download the license file if it exists
  if $ckan::license != '' {
    # add a license
    file { "${ckan_default}/${license_file}":
      ensure => file,
      source => $ckan::license,
    }
  }

  if $ckan::custom_imgs != '' {
    # manage the default image directory
    ckan::custom_images { $ckan::custom_imgs: }
  }

  # download custom css if specified
  if $ckan::custom_css != 'main.css' {
    file {"${ckan_css_dir}/custom.css":
      ensure => file,
      source => $ckan::custom_css,
    }
  }

  # backup configuration
  file { $backup_dir:
    ensure => directory,
    owner  => backup,
    group  => backup,
    mode   => '0755',
  }
  file { '/usr/local/bin/ckan_backup.bash':
    ensure  => file,
    content => template('ckan/ckan_backup.bash.erb'),
    mode    => '0755',
    require => File[$backup_dir],
  }
  cron {'ckan-backup-daily':
    command => '/usr/local/bin/ckan_backup.bash daily',
    user    => backup,
    weekday => '*',
    hour    => '2',
    minute  => '5',
  }
  cron {'ckan-backup-weekly':
    command => '/usr/local/bin/ckan_backup.bash weekly',
    user    => backup,
    weekday => '2',
    hour    => '2',
    minute  => '10',
  }
  cron {'ckan-backup-monthly':
    command  => '/usr/local/bin/ckan_backup.bash monthly',
    user     => backup,
    monthday => '2',
    hour     => '2',
    minute   => '20',
  }
  # additional userful scripts
  file { '/usr/local/bin/ckan_create_admin.bash':
    ensure  => file,
    source  => 'puppet:///modules/ckan/ckan_create_admin.bash',
    mode    => '0755',
    require => File['/usr/local/bin/ckan_backup.bash'],
  }
}
