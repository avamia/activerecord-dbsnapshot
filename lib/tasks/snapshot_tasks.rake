# lib/tasks/snapshot_tasks.rake

namespace :db do
  namespace :snapshot do
    desc "Dump database based on snapshot configuration"
    task :dump, [:name] => :environment do |t, args|
      unless `which pg_dump`.present?
        puts "Error: pg_dump not found. Ensure PostgreSQL client tools are installed."
        next
      end

      unless Rails.env.development?
        puts "You are about to dump the database. This action is not recommended in non-development environments."
        puts "Proceed? (yes/no)"
        response = STDIN.gets.chomp.downcase
        unless response == 'yes'
          puts "Dump canceled."
          next
        end
      end

      config = args[:name] ? ActiveRecord::DbSnapshot.find_configuration(args[:name]) : ActiveRecord::DbSnapshot.latest_configuration
      unless config
        puts "No snapshot configuration found."
        next
      end

      db_config = ActiveRecord::Base.connection_config
      output_file = Rails.root.join('db', 'snapshots', "#{config.snapshot_name}.sql")

      command = ActiveRecord::DbSnapshot.build_dump_command(config, db_config, output_file)
      ActiveRecord::DbSnapshot.execute_command(command)

      puts "Database dump completed: #{output_file}"
    end

    desc "Restore a snapshot SQL file into the database"
    task :restore, [:name] => :environment do |_, args|
      unless `which pg_restore`.present?
        puts "Error: pg_restore not found. Ensure PostgreSQL client tools are installed."
        next
      end

      name = args[:name]
      filename = "db/snapshots/#{name}.sql"

      unless File.exist?(filename)
        puts "Snapshot file not found: #{filename}"
        next
      end

      unless Rails.env.development?
        puts "You are about to restore a database snapshot. This action is not recommended in non-development environments."
        puts "Proceed? (yes/no)"
        response = STDIN.gets.chomp.downcase
        unless response == 'yes'
          puts "Snapshot restoration canceled."
          next
        end
      end

      # Restore the SQL file into the database
      db_config = ActiveRecord::Base.connection_config
      command = ActiveRecord::DbSnapshot.build_restore_command(db_config, filename)
      ActiveRecord::DbSnapshot.execute_command(command)

      puts "Snapshot '#{name}' restored successfully."
    end
  end
end
