require 'rails/generators'

class SnapshotGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :exclude_tables, type: :array, default: [], desc: "List of tables to exclude from the snapshot"

  def create_snapshot_config
    @exclude_tables = options[:exclude_tables] || []

    @class_name = file_name.gsub('-', '_').camelize
    @symbol_name = file_name.gsub('-', '_').underscore

    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    filename_with_timestamp = "#{timestamp}_#{@symbol_name}"
    template "snapshot_config.rb.erb", File.join("db/snapshots", "#{filename_with_timestamp}.rb")
  end
end
