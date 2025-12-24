module PowerGrid
  module Helper
    def render_grid(grid, **options)
      render PowerGrid::TableComponent.new(grid, **options)
    end
  end
end
