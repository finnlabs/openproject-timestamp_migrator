# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

require 'open_project/timestamp_migrator/version'
# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-timestamp_migrator"
  s.version     = OpenProject::TimestampMigrator::VERSION
  s.authors     = "OpenProject GmbH"
  s.email       = "info@openproject.com"
  s.homepage    = "https://www.openproject.org/projects/timestamp-migrator"  # TODO check this URL
  s.summary     = 'OpenProject Timestamp Migrator'
  s.description = "A plugin to migrate timestamps from local time to UTC"
  s.license     = "GPLv3" # e.g. "MIT" or "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w(CHANGELOG.md README.md)

  s.add_dependency 'rails', '~> 5.0.0'
end
