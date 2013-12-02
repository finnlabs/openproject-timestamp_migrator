#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require Rails.root.join("db","migrate","migration_utils","utils").to_s

class MigrateTimestampsToUtc < ActiveRecord::Migration
  include Migration::Utils

  def up
    raise "Error: Adapting Timestamps is only supported for " +
      "postgres and mysql yet." unless postgres? || mysql?
    readOldTimezone

    begin
      setFromTimezone

      getQueries.each do |statement|
        ActiveRecord::Base.connection.execute statement.values.first
      end

    ensure
      setOldTimezone
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration "This migration is not reversible. Use the core rake" +
    "task rake migrations:change_timestamps_to_utc with appropriate parameters to change the timestamps back"
  end

  private

  def readOldTimezone
    if postgres?
      @old_timezone = ActiveRecord::Base.connection.select_all(
                  "SELECT current_setting('timezone') AS timezone").first['timezone']
    end
  end

  def setFromTimezone
    if postgres?
      from_timezone = ENV['FROM'] || 'LOCAL'
      ActiveRecord::Base.connection.execute "SET TIME ZONE #{from_timezone}"
    elsif mysql?
      converted_time = ActiveRecord::Base.connection.select_all( \
        "SELECT CONVERT_TZ('2013-11-06 15:13:42', 'SYSTEM', 'UTC')").first.values.first

      if converted_time.nil?
        raise <<-error
          Error: timezone information has not been loaded into mysql, please execute
          mysql_tzinfo_to_sql <path-to-zoneinfo> | mysql -u root mysql
          Hint: a likely location of <path-to-zoneinfo> is /usr/share/zoneinfo
          see: http://dev.mysql.com/doc/refman/5.0/en/mysql-tzinfo-to-sql.html
        error
      end
    end
  end

  def setOldTimezone
    if postgres?
      ActiveRecord::Base.connection.execute "SET TIME ZONE #{@old_timezone}"
    end
  end

  def getQueries
    if postgres?
      ActiveRecord::Base.connection.select_all <<-SQL
        select 'UPDATE ' || table_name || ' SET ' || column_name || ' = ' || column_name || '::timestamptz at time zone ''utc'';'
        from information_schema.columns
        where table_schema='public'
        and data_type like 'timestamp without time zone'
      SQL
    elsif mysql?
      from_timezone = ENV['FROM'] || 'SYSTEM'

      ActiveRecord::Base.connection.select_all <<-SQL
        select concat('UPDATE ',table_name, ' SET ', column_name, ' = CONVERT_TZ(', column_name, ', \\'#{from_timezone}\\', \\'UTC\\');')
        from information_schema.columns
        where table_schema = '#{ActiveRecord::Base.connection.current_database}' and data_type like 'datetime'
      SQL
    end
  end
end
