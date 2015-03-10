# == Class ckan::postinstall
#
# Manages tasks to be performed after the initial install like
# initializing the database
#
# details: http://docs.ckan.org/en/ckan-2.0/install-from-package.html
#
class ckan::postinstall {
  include check_run

  check_run::task { 'init_db':
    exec_command => '/usr/bin/ckan db init',
  }

  check_run::task { 'set_database_perms':
    cwd          => "/var/lib/postgresql",
    exec_command => "/usr/bin/ckan datastore set-permissions | sudo -u postgres psql --set ON_ERROR_STOP=1",
    require      => Check_run::Task['init_db'],
  }
}
