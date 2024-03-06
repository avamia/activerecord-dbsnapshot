require 'activerecord/dbsnapshot'
require 'rails'

module ActiveRecord
  class DbSnapshot
    class Railtie < Rails::Railtie
      # Auto-load the generator when Rails starts
      generators do
        require 'generators/snapshot/snapshot_generator'
      end

      rake_tasks do
        load 'tasks/snapshot_tasks.rake'
      end
    end
  end
end
