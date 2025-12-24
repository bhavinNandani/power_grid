require "view_component"

module PowerGrid
  class TableComponent < ViewComponent::Base
    include Turbo::FramesHelper

    DEFAULT_CSS = {
      container: "w-full bg-white dark:bg-gray-900 rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 overflow-hidden ring-1 ring-black/5",
      toolbar: "flex flex-col md:flex-row md:items-center justify-between gap-4 p-4 border-b border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900",
      search_input: "block w-full rounded-lg border-0 py-1.5 pl-10 text-gray-900 dark:text-white shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 bg-white dark:bg-gray-950 transition-shadow",
      filter_select: "block w-full rounded-lg border-0 py-1.5 pl-3 pr-10 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 bg-white dark:bg-gray-950 transition-shadow",
      filter_input: "block w-full rounded-lg border-0 py-1.5 text-gray-900 dark:text-white shadow-sm ring-1 ring-inset ring-gray-300 dark:ring-gray-700 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 bg-white dark:bg-gray-950 transition-shadow",
      table: "min-w-full divide-y divide-gray-200 dark:divide-gray-800",
      thead: "bg-gray-50 dark:bg-gray-800/50",
      th: "px-4 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider",
      tbody: "divide-y divide-gray-200 dark:divide-gray-800 bg-white dark:bg-gray-900",
      tr: "hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors duration-150 ease-in-out group",
      td: "px-4 py-3 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300",
      pagination: "flex items-center justify-between px-4 py-3 border-t border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900",
      pagination_summary: "text-sm text-gray-700 dark:text-gray-400 hidden sm:block",
      page_link: "relative inline-flex items-center px-3 py-1.5 text-sm font-semibold text-gray-900 dark:text-gray-200 ring-1 ring-inset ring-gray-300 dark:ring-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 focus:z-20 focus:outline-offset-0 rounded-lg mx-0.5 transition-all",
      page_link_active: "relative z-10 inline-flex items-center px-3 py-1.5 text-sm font-semibold text-white bg-blue-600 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 rounded-lg mx-0.5 shadow-sm",
      page_prev: "relative inline-flex items-center rounded-l-lg px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 dark:ring-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 focus:z-20 focus:outline-offset-0 mr-1 transition-all",
      page_prev_disabled: "relative inline-flex items-center rounded-l-lg px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-200 dark:ring-gray-800 cursor-not-allowed mr-1 bg-gray-50 dark:bg-gray-900/50",
      page_next: "relative inline-flex items-center rounded-r-lg px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 dark:ring-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 focus:z-20 focus:outline-offset-0 ml-1 transition-all",
      page_next_disabled: "relative inline-flex items-center rounded-r-lg px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-200 dark:ring-gray-800 cursor-not-allowed ml-1 bg-gray-50 dark:bg-gray-900/50",
      page_gap: "relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 dark:text-gray-300 ring-1 ring-inset ring-gray-300 dark:ring-gray-700 rounded-lg mx-0.5"
    }.freeze

    attr_reader :headless

    def initialize(grid_or_class, params: nil, css: {}, toolbar: true, headless: false)
      if grid_or_class.is_a?(Class)
        @grid = grid_or_class.new(params)
      else
        @grid = grid_or_class
      end
      @show_toolbar = toolbar
      @headless = headless
      if @headless
        @css = css
      else
        @css = DEFAULT_CSS.merge(css)
      end
    end

    def show_toolbar?
      @show_toolbar
    end

    def css_class(key)
      if headless
        @css[key]
      else
        @css[key] || DEFAULT_CSS[key]
      end
    end

    def columns
      @grid.class.defined_columns
    end

    def records
      @grid.records
    end

    def render_filter(name, options)
      label = options[:header] || options[:label] || name.to_s.humanize
      value = @grid.params[name]
      
      collection = options[:collection]
      collection = collection.call if collection.respond_to?(:call)

      if options[:type].to_s == "checkbox" && collection
        # Checkbox Logic
        # ...
        current_values = Array(value).map(&:to_s)
        
        content_tag(:div, class: "flex flex-col gap-1") do
          concat content_tag(:span, label, class: "text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1")
          content_tag(:div, class: "flex flex-wrap gap-2") do
            collection.each do |item|
              # Handle collection item being [label, value] or just value
              display, val = item.is_a?(Array) ? item : [item.to_s.humanize, item]
              checked = current_values.include?(val.to_s)
              
              concat(
                content_tag(:label, class: "inline-flex items-center space-x-2 cursor-pointer") do
                  concat check_box_tag("#{name}[]", val, checked, class: "form-checkbox rounded text-indigo-600 focus:ring-indigo-500 border-gray-300 dark:border-gray-700 dark:bg-gray-800", onchange: "this.form.requestSubmit()")
                  concat content_tag(:span, display, class: "text-sm text-gray-700 dark:text-gray-300")
                end
              )
            end
          end
        end

      elsif options[:type].to_s == "radio" && collection
        # Radio Logic
        content_tag(:div, class: "flex flex-col gap-1") do
          concat content_tag(:span, label, class: "text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1")
          content_tag(:div, class: "flex flex-wrap gap-2") do
            # Add "All" option for Radio
            all_checked = value.blank?
            concat(
              content_tag(:label, class: "inline-flex items-center space-x-2 cursor-pointer") do
                concat radio_button_tag(name, "", all_checked, class: "form-radio text-indigo-600 focus:ring-indigo-500 border-gray-300 dark:border-gray-700 dark:bg-gray-800", onchange: "this.form.requestSubmit()")
                concat content_tag(:span, "All", class: "text-sm text-gray-700 dark:text-gray-300")
              end
            )

            collection.each do |item|
              display, val = item.is_a?(Array) ? item : [item.to_s.humanize, item]
              checked = value.to_s == val.to_s
              
              concat(
                content_tag(:label, class: "inline-flex items-center space-x-2 cursor-pointer") do
                  concat radio_button_tag(name, val, checked, class: "form-radio text-indigo-600 focus:ring-indigo-500 border-gray-300 dark:border-gray-700 dark:bg-gray-800", onchange: "this.form.requestSubmit()")
                  concat content_tag(:span, display, class: "text-sm text-gray-700 dark:text-gray-300")
                end
              )
            end
          end
        end

      elsif collection
        # Select Logic (Default for collections)
        select_tag name, options_for_select(collection, value), 
          include_blank: "All #{name.to_s.humanize.pluralize}",
          class: css_class(:filter_select),
          onchange: "this.form.requestSubmit()"
      else
        # Text Input Logic
        text_field_tag name, value, placeholder: label,
          class: css_class(:filter_input),
          data: { action: "input->power-grid-table#search" }
      end
    end

    def sort_url(column, direction)
      # TODO: Helper to generate URL with updated params
      # For now just return hash or similar, we might need a helper that merges params
      # We need request context or helpers provided by Rails
    end
  end
end
