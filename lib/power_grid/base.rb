module PowerGrid
  require_relative "exporter"
  class Base
    class << self
      def scope(&block)
        @scope_block = block
      end

      def column(name, **options, &block)
        @columns ||= {}
        @columns[name] = options.merge(block: block)
      end

      def filter(name, **options, &block)
        @filters ||= {}
        @filters[name] = options.merge(block: block)
      end

      def defined_scope
        @scope_block
      end

      def defined_columns
        @columns || {}
      end

      def defined_filters
        @filters || {}
      end
    end

    attr_reader :params, :initial_scope
    attr_accessor :hide_controls

    def initialize(params = {}, initial_scope: nil, **options)
      params ||= {}
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params = params.with_indifferent_access
      
      # Handle namespaced params (common pattern for custom forms: grid[field])
      if params[:grid].present? && params[:grid].is_a?(Hash)
         params = params.merge(params[:grid])
      end

      @params = params.merge(options)
      @initial_scope = initial_scope
      @hide_controls = false # Initialize to false by default
    end

    def records
      @records ||= apply_pagination(scope)
    end

    def scope
      @scope ||= begin

        s = @initial_scope || instance_eval(&self.class.defined_scope)
        s = apply_includes(s)
        s = apply_filters(s)
        s = apply_search(s)
        s = apply_sort(s)
        
        # Capture total count after filtering but before pagination
        @total_count = s.count
        s
      end
    end

    def total_count
      # Ensure records are loaded to populate @total_count
      records unless defined?(@total_count)
      @total_count
    end

    def searchable?
      self.class.defined_columns.any? { |_, opts| opts[:searchable] }
    end

    def current_page
      (params[:page] || 1).to_i
    end

    def per_page
      limit = (params[:per_page] || 10).to_i
      limit > 100 ? 100 : limit # Cap at 100 for safety
    end

    def offset
      (current_page - 1) * per_page
    end

    def page_range_start
      return 0 if total_count == 0
      offset + 1
    end

    def page_range_end
      end_val = offset + per_page
      end_val > total_count ? total_count : end_val
    end

    def total_pages
      (total_count.to_f / per_page).ceil
    end

    def pagination_window(window: 2)
      return (1..total_pages).to_a if total_pages <= (window * 2) + 5

      current = current_page
      last = total_pages
      left = current - window
      right = current + window

      range = []
      range << 1
      range << :gap if left > 2
      
      (left..right).each do |i|
        range << i if i > 1 && i < last
      end
      
      range << :gap if right < last - 1
      range << last
      range
    end

    
    def to_csv
      Exporter.new(self).to_csv
    end

    private

    def apply_includes(scope)
      includes_list = self.class.defined_columns.values.map { |opts| opts[:includes] }.compact
      return scope if includes_list.empty?
      
      scope.includes(*includes_list)
    end
    def apply_pagination(scope)
      scope.offset(offset).limit(per_page)
    end


    def apply_search(scope)
      query = params[:q]
      return scope if query.blank?

      searchable_columns = self.class.defined_columns.select { |_, opts| opts[:searchable] }
      return scope if searchable_columns.empty?

      conditions = searchable_columns.map do |name, opts|
        # If sql_expression is provided, use it. Otherwise use the column name (which might be table.col)
        # We cast to text/string for generic like search if needed, but for now simple LIKE
        col_expr = opts[:sql_expression] || name.to_s
        "#{col_expr} LIKE :query"
      end.join(" OR ")

      scope.where(conditions, query: "%#{query}%")
    end

    def apply_sort(scope)
      order_column = params[:order]
      direction = params[:dir] || "asc"

      return scope unless order_column.present?
      
      column_def = self.class.defined_columns[order_column.to_sym]
      return scope unless column_def && column_def[:sortable]

      # Use sql_expression for sorting if provided (useful for joined columns or calculated fields)
      sort_expr = column_def[:sql_expression] || order_column
      
      scope.order(sort_expr => direction)
    end

    def apply_filters(scope)

      self.class.defined_filters.each do |name, options|
        value = @params[name] || @params[name.to_s]
        
        is_number_range = options[:type].to_s == "number_range"
        has_min_max = @params["#{name}_min"].present? || @params["#{name}_max"].present?

        next if value.blank? && !(is_number_range && has_min_max)

        if options[:block]
          scope = options[:block].call(scope, value)
        elsif options[:type].to_s == "date_range" && value.is_a?(String) && value.include?(" to ")
          start_date, end_date = value.split(" to ")
          col_name = options[:sql_expression] || name
          scope = scope.where(col_name => start_date..end_date)
        elsif options[:type].to_s == "number_range"
          min = @params["#{name}_min"]
          max = @params["#{name}_max"]
          col_name = options[:sql_expression] || name
          


          if min.present? && max.present?
            scope = scope.where(col_name => min..max)
          elsif min.present?
            scope = scope.where("#{col_name} >= ?", min)
          elsif max.present?
            scope = scope.where("#{col_name} <= ?", max)
          end
        elsif options[:type].to_s == "boolean"
          col_name = options[:sql_expression] || name
          bool_value = ActiveRecord::Type::Boolean.new.cast(value)
          scope = scope.where(col_name => bool_value)
        else
          # Basic equality filter
          # If sql_expression option exists, use that
          col_name = options[:sql_expression] || name
          scope = scope.where(col_name => value)
        end
      end
      scope
    end


  end
end
