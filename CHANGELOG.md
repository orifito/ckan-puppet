## 2015-03-04 Release 1.0.13
### Summary
Account Migration

### Changed
 - Migrated from github to bitbucket
 - Changed ownership of puppetforge account
 - Added openhub badge to readme.
 - Migrated changelog into md format.
 - Changed ckan_run dependancy to landcareresearch account.

### Fixes
  - Output of new CKAN Fact now correctly reports if the /etc/ckan/plugins.out file doesn't exist.

## 2015-02-16 Version 1.0.12
### Summary
Ext Plugin Reworked

### Changes
 - Including extension plugins in the plugins parameter caused the module to fail due to a depedancy on the extension to already be installed prior to ckan started.
   This patch incorperates the plugin into the extension so the extension plugins no longer need to be set via the plugin option.
   It will require 2 puppet runs in order to bring the extensions online though (there isn't any way around this that I know of).
 
## 2015-01-29 Version 1.0.11
### Summary
Hot Fix

### Fixes:
 - Added ckan user password string to ckan.ini.
 - Added puppetforge badge

## 2015-01-28 Version 1.0.10
### Summary
Minor Changes

### Features
 - Added an option to enable event tracking for the Google Analystics which pushes events every hour
 - Added a convience script for creating admin accounts.

### Fixes
 - Cleaned up code
 - Added documentation for ckan::config
 - Added configuration for backup directory
 - Added configuration for ckan database password


## 2015-01-14 Version 1.0.9
### Summary
Added ckanapi support

### Features
 - The ckanapi can now be installed (optional)
 - A helper script for calling ckanapi command line tool

## 2015-01-08 Version 1.0.8
### Summary
Quality Control

### Fixes
 - Cleaned up the code based on puppet-lint (via puppetlinter.com)
 - Enabled github hook for puppetlinter so future commits are checked and reported

## 2015-01-07 Version 1.0.7
### Summary
Fixed a recent security exploit that has effected CKAN sites globally

### Fixes
 - Set the security settings to restrict anonymous users from creating groups and datasets
 - Set the default backend for spatial search to solr in the spatial search extension
 - Changed backups from weekly to daily


## 2014-11-12 Version 1.0.6
### Summary:
CKAN Developers have added a new submodule for managing CKAN extensions.

### Features
 - Added ckan::ext submodule
 - Added Google Analytics extension
 - Added Hierarchy extesion
 - Added New Zealand Landcare extension
 - Added Spatial extension
 - Updated to using metadata.json

## 2014-08-13 Version 1.0.5
### Summary
A CKAN Developer has cleaned up the module and prepared for ckan extensions.

### Features
 - Removed apache module dependency
 - Removed module stage complexity with anchor pattern
 - Removed hard coded security keys from production.ini.erb
 - Added security keys to module parameters

## 2014-07-23 Version 1.0.4
### Summary
Updated Dependencies

### Features
 - Removed the reset_apt module as vagrant can handle updating puppet with a recomended script
 - Updated to the latest apache module which has the necessary changes integrated
 - Changed default value of the apache headers variable
 
## 2014-06-09 Version 1.0.3
### Features
 - Added dependancy for Debian/Ubuntu based systems only
 - Updated readme with new installation parameters
 - Added Server admin's email specified
 - Added recaptcha support
 - Added max_resource_size parameter
 - Added data pusher formats
 - Added apache head configuration (in order to control search engine crawlers) and is optional
 - Added the postgres password as a parameter
 - Added postgres hba configuration to pass in as a parameter

## 2014-06-08 Version 1.0.2
### Summary
Minor bug fixes and supports CKAN 2.2 package version

### Features
 - Fixed a bug if the license was left off, caused errors in datastore
 - Added support for CKAN 2.2 package

## 2014-01-15 Version 1.0.1
### Summary
Minor bug fix when deploying outside of a Vagrant environment

### Features
 - Added a parameter to disable the apt reset

### Fixes
 - Removed puppetlabs-apt and apt::ppa which was causing dependency loops if a class outside of ckan required apt::ppa
 - Removed ppa for nodejs & ubuntugis
 - Added puppetlabs-nodejs class
 - Added dependency for puppetlabs-nodejs

## Version 1.0.0
### Summary
Initial Release.
