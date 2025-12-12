require "view_component"

module PowerGrid
  class TableComponent < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(grid_or_class, params: nil)
    if grid_or_class.is_a?(Class)
      @grid = grid_or_class.new(params)
    else
      @grid = grid_or_class
    end
  end

    def columns
      @grid.class.defined_columns
    end

    def records
      @grid.records
    end

    def sort_url(column, direction)
      # TODO: Helper to generate URL with updated params
      # For now just return hash or similar, we might need a helper that merges params
      # We need request context or helpers provided by Rails
    end
  end
end
