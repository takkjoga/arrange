module Arrange
  class ModelsController < ApplicationController
    before_action :set_models
    before_action :set_model, only: [:schema, :records, :record, :create_record, :update_record, :destroy_record]
    before_action :overload_view, only: [:index, :schema, :records, :record]

    helper_method :overload_partial_file

    def index
      render @view_file
    end

    def schema
      render @view_file
    end

    def records
      @search = @model.search(search_params)
      @records = @search.result
      @explain = @records.explain if params[:explain]
      render @view_file
    end

    def record
      if params[:id] == 'new'
        @record = @model.new
        @path = url_for(create_table_record_path(table_name: @model.table_name))
      else
        @record = @model.find params[:id]
        @path = url_for(update_table_record_path(table_name: @model.table_name, id: params[:id]))
      end
      render @view_file
    end

    def create_record
      save_record
    end

    def update_record
      save_record
    end

    def destroy_record
      record = @model.find params[:id]
      record.destroy
      if params[:with_related_records]
        @model.reflections.each do |name, relation|
          case relation.macro.to_sym
          when :has_one, :has_many, :has_and_belongs_to_many
            record.send(relation.name).destroy_all
          end
        end
      end
      redirect_to table_records_path(table_name: @model.table_name), notice: "#{@model.to_s.classify} record (id: #{params[:id]}) was successfully destroyed."
    end

    private

    # {Rails.root}/app/views/arrange/ 以下に、指定のファイル名で配置すると
    # そのファイルをviewファイルとして使用する
    # 優先度の高い順から
    # * {table_name}.{action}.html.erb 
    # * {action}.html.erb 
    # * default
    def overload_view
      view_path = File.join(Rails.root, 'app', 'views', Arrange.config.overload_view_path)
      if Dir.exist?(view_path)
        view_file_by_action = File.join(view_path, params[:action] + Arrange.config.overload_view_file_extension)
        if @model.nil?
          if File.exist?(view_file_by_action)
            @view_file = File.join(Arrange.config.overload_view_path, File.basename(view_file_by_action))
          end
        else
          view_file_by_model = File.join(view_path, @model.table_name + '.' + params[:action] + Arrange.config.overload_view_file_extension)
          if File.exist?(view_file_by_model)
            @view_file = File.join(Arrange.config.overload_view_path, File.basename(view_file_by_model))
          else
            if File.exist?(view_file_by_action)
              @view_file = File.join(Arrange.config.overload_view_path, File.basename(view_file_by_action))
            end
          end
        end
      end
      @view_file = params[:action] if @view_file.nil?
    end

    def overload_partial_file(partial_file_name_without_first_underscore_and_without_file_extension = nil)
      view_path = File.join(Rails.root, 'app', 'views', Arrange.config.overload_view_path)
      if Dir.exist?(view_path)
        partial_file = File.join(view_path, '_' + partial_file_name_without_first_underscore_and_without_file_extension + Arrange.config.overload_view_file_extension)
        if File.exist?(partial_file)
          return File.join(Arrange.config.overload_view_path, partial_file_name_without_first_underscore_and_without_file_extension)
        end
      end
      partial_file_name_without_first_underscore_and_without_file_extension
    end

    def set_models
      @models = Arrange::Utility.get_all_models
    end

    def set_model
      @model = @models[params[:table_name]]
      @belongs, @relations = Arrange::Utility.relations(@model)
    end

    def model_params
      params.require(@model.name.underscore).permit(*@model.column_names)
    end

    def search_params
      columns = @model.columns.map do |column|
        case column.type
        when :boolean
          ["#{column.name}_true", "#{column.name}_false"]
        when :integer
          ["#{column.name}_eq", "#{column.name}_lt", "#{column.name}_gt", "#{column.name}_in"]
        when :string, :text
          ["#{column.name}_eq", "#{column.name}_cont", "#{column.name}_start"]
        when :datetime, :date, :time
          ["#{column.name}_eq", "#{column.name}_lt", "#{column.name}_gt"]
        end
      end.flatten
      @model.columns.each do |column|
        if params[column.name].present?
          params[:q] ||= {}
          params[:q]["#{column.name}_eq"] = params[column.name]
        end
      end
      if params[:q].present?
        params.require(:q).permit(*columns, :s)
      end
    end

    def save_record
      if params[:id] == 'new'
        record = @model.new(model_params)
        id_text = 'new'
        action_text = 'created'
      else
        record = @model.find params[:id]
        record.update(model_params)
        id_text = "id: #{params[:id]}"
        action_text = 'updated'
      end
      record.save
      redirect_to table_record_path(table_name: @model.table_name, id: record.id), notice: "#{@model.to_s.classify} record (#{id_text}) was successfully #{action_text}."
    end
  end
end
