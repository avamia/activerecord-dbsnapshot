require_relative "dbsnapshot/version"

module ActiveRecord
  class DbSnapshot
    class << self
      attr_accessor :snapshot_name, :excluded_tables

      def name(value)
        formatted_name = value.to_s.gsub('-', '_').underscore.to_sym
        @snapshot_name = formatted_name
      end

      # Stores an array of tables to be excluded from the snapshot.
      def exclude(tables)
        @excluded_tables = tables.map(&:to_s)
      end

      # Finds the latest snapshot configuration
      def latest_configuration
        config_files = Dir.glob(Rails.root.join('db', 'snapshots', "*.rb"))
        return nil if config_files.empty?

        latest_config_file = config_files.max_by { |file| extract_timestamp(file) }
        return nil unless latest_config_file

        require latest_config_file

        klass_name = File.basename(latest_config_file, '.rb').gsub(/^[^_]+_/, '').camelize
        klass = klass_name.constantize

        puts klass.snapshot_name, klass.excluded_tables.inspect
        klass
      end

      # Finds snapshot configuration by name
      def find_configuration(name)
        config_file = Dir.glob(Rails.root.join('db', 'snapshots', "*_#{name}.rb")).first
        unless config_file
          puts "Snapshot configuration not found: #{name}"
          return nil
        end

        load config_file
        ActiveRecord::DbSnapshot.new
      end

      # Builds the dump command based on configuration
      def build_dump_command(config, db_config, output_file)
        pg_dump_cmd = "pg_dump"
        pg_dump_cmd << " -U #{db_config[:username]}"
        pg_dump_cmd << " -h #{db_config[:host]}"
        pg_dump_cmd << " #{db_config[:database]}"

        excluded_tables = config.excluded_tables.map(&:to_s).join(" ")
        if excluded_tables.empty?
          return "#{pg_dump_cmd} > #{output_file}"
        else
          excluded_tables_option = "--exclude-table=" + excluded_tables
          return "#{pg_dump_cmd} #{excluded_tables_option} > #{output_file}"
        end
      end

      # Executes the dump command
      def execute_dump_command(dump_command)
        system(dump_command)
      end

      private
      def extract_timestamp(file)
        timestamp = File.basename(file, ".rb").split('_').first.to_i
        Time.at(timestamp)
      end
    end
  end
end

require 'activerecord/dbsnapshot/railtie' if defined?(Rails)
