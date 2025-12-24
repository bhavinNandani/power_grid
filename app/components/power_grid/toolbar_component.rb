require "view_component"

module PowerGrid
  class ToolbarComponent < ViewComponent::Base
    include Turbo::FramesHelper

    DEFAULT_CSS = {
      container: "flex flex-col md:flex-row md:items-center justify-between gap-4 p-4",
      search_input: "block w-full pl-12 pr-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg leading-5 bg-white dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm",
      filter_select: "block w-full pl-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-700 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-lg bg-white dark:bg-gray-800",
      filter_input: "block w-full pl-3 pr-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg leading-5 bg-white dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
    }.freeze

    def initialize(grid, css: {}, headless: false)
      @grid = grid
      @css = css
      @headless = headless
    end

    def css_class(key)
      if @headless
        @css[key]
      else
        @css[key] || DEFAULT_CSS[key]
      end
    end

    def render_filter(name, options)
      label = options[:header] || options[:label] || name.to_s.humanize
      value = @grid.params[name] || @grid.params[name.to_s]
      
      collection = options[:collection]
      collection = collection.call if collection.respond_to?(:call)
      
      filter_type = options[:type].to_s.downcase

      if filter_type == "checkbox" && collection
        current_values = Array(value).map(&:to_s)
        content_tag(:div, class: "flex flex-col gap-1") do
          concat content_tag(:span, label, class: "text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1")
          concat(content_tag(:div, class: "flex flex-wrap gap-2") do
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
            nil
          end)
        end
      elsif filter_type == "radio" && collection
        content_tag(:div, class: "flex flex-col gap-1") do
          concat content_tag(:span, label, class: "text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1")
          concat(content_tag(:div, class: "flex flex-wrap gap-2") do
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
            nil
          end)
        end
      elsif filter_type == "number_range"
        min_value = @grid.params["#{name}_min"]
        max_value = @grid.params["#{name}_max"]
        content_tag(:div, class: "flex flex-col gap-1") do
          concat content_tag(:span, label, class: "text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1")
          concat(content_tag(:div, class: "flex items-center space-x-2") do
            concat text_field_tag("#{name}_min", min_value, placeholder: "Min", class: css_class(:filter_input), data: { action: "input->power-grid-table#search" })
            concat content_tag(:span, "-", class: "text-gray-500")
            concat text_field_tag("#{name}_max", max_value, placeholder: "Max", class: css_class(:filter_input), data: { action: "input->power-grid-table#search" })
          end)
        end
      elsif filter_type == "boolean"
        boolean_options = [["Yes", "true"], ["No", "false"]]
        select_tag name, options_for_select(boolean_options, value), 
          include_blank: "All #{name.to_s.humanize.pluralize}",
          class: css_class(:filter_select),
          onchange: "this.form.requestSubmit()"
      elsif filter_type == "date_range"
        text_field_tag name, value, 
          placeholder: label,
          class: css_class(:filter_input),
          data: { controller: "power-grid--flatpickr" }
      elsif collection
        select_tag name, options_for_select(collection, value), 
          include_blank: "All #{name.to_s.humanize.pluralize}",
          class: css_class(:filter_select),
          onchange: "this.form.requestSubmit()"
      else
        text_field_tag name, value, placeholder: label,
          class: css_class(:filter_input),
          data: { action: "input->power-grid-table#search" }
      end
    end
  end
end
