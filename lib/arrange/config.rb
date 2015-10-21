module Arrange
  module Config
    class << self
      attr_accessor :table_records_sort_order
      attr_accessor :table_records_limit
      attr_accessor :table_records_offset
      attr_accessor :overload_view_path
      attr_accessor :overload_view_file_extension

      def table_records_sort_order
        @table_records_sort_order ||= :asc
      end

      def table_records_limit
        @table_records_limit ||= 10
      end

      def table_records_offset
        @table_records_offset ||= 0
      end

      # app/views/arrange
      def overload_view_path
        @overload_view_path ||= 'arrange'
      end

      def overload_view_file_extension
        @overload_view_file_extension ||= '.html.erb'
      end
    end
  end
end
