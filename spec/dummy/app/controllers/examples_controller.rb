class ExamplesController < ApplicationController
  def simple
    @grid = SimpleUserGrid.new(params.permit!)
  end

  def complex
    @grid = ComplexPostGrid.new(params.permit!)
  end

  def dashboard
    # Limit to 5 for dashboard "At a Glance" feel, though SimpleUserGrid defines scope as ALL.
    # We might need to override valid params or modify grid to accept scope override.
    # For now, let's just use the grid as is, maybe the dashboard has full tables.
    @users_grid = SimpleUserGrid.new(params.permit!)
    @posts_grid = ComplexPostGrid.new(params.permit!)
  end
end
