module PowerGrid
  class Base
    class << self
      def scope(&block)
        @scope_block = block
      end

      def column(name, **options, &block)
        @columns ||= {}
        @columns[name] = options.merge(block: block)
      end

      def filter(name, **options)
        @filters ||= {}
        @filters[name] = options
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

    def initialize(params = {}, initial_scope: nil, **options)
      @params = params.merge(options)
      @initial_scope = initial_scope
    end

    def records
      @records ||= begin
        scope = @initial_scope || instance_eval(&self.class.defined_scope)
        scope = apply_includes(scope)
        scope = apply_includes(scope)
        scope = apply_search(scope)
        scope = apply_sort(scope)
        
        # Capture total count after filtering but before pagination
        @total_count = scope.count
        
        scope = apply_pagination(scope)
        scope
      end
    end

    def total_count
      # Ensure records are loaded to populate @total_count
      records unless defined?(@total_count)
      @total_count
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

  end
end
