Arrange::Engine.routes.draw do
  root 'models#index'
  get ':table_name/schema', controller: :models, action: :schema, as: 'table_schema'
  get ':table_name', controller: :models, action: :records, as: 'table_records'
  get ':table_name/:id', controller: :models, action: :record, as: 'table_record'
  post ':table_name/:id', controller: :models, action: :create_record, as: 'create_table_record'
  patch ':table_name/:id', controller: :models, action: :update_record, as: 'update_table_record'
  delete ':table_name/:id', controller: :models, action: :destroy_record, as: 'destroy_table_record'
end
