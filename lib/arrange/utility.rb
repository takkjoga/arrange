module Arrange
  module Utility
    class << self
      def get_all_models
        Dir.glob("#{Rails.root}/app/models/*.rb") do |file|
          require_dependency file
        end

        models = lambda {
          p = lambda { |c|
            f = c.subclasses
            if f.empty?
              [c]
            else
              f.map(&p)
            end
          }
        }.call.call(ActiveRecord::Base)
        return [] if models.blank?

        models = models.flatten.uniq(&:table_name).select do |model|
          if model == ActiveRecord::Base
            false
          elsif model == ActiveRecord::SchemaMigration
            false
          else
            true
          end
        end
        return [] if models.blank?

        models.index_by(&:table_name)
      end

      def relations(model)
        belongs = {}
        relations = {}
        model.reflections.each do |name, assoc|
          if assoc.belongs_to?
            belongs[assoc.foreign_key.to_sym] = assoc.klass
          else
            relations[name] = assoc
          end
        end
        [belongs, relations]
      end
    end
  end
end
