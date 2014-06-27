module OpenProject::TimestampMigrator
  class Engine < ::Rails::Engine
    engine_name :openproject_timestamp_migrator

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-timestamp_migrator',
             :author_url => 'http://finn.de',
             :requires_openproject => '>= 4.0.0'

  end
end
