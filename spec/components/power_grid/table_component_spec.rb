require "rails_helper"

RSpec.describe PowerGrid::TableComponent, type: :component do
  before(:all) do
    ActiveRecord::Base.connection.create_table :component_test_items, force: true do |t|
      t.string :name
      t.boolean :active
    end
    class ComponentTestItem < ActiveRecord::Base; end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :component_test_items
  end

  class TableTestGrid < PowerGrid::Base
    scope { ComponentTestItem.all }
    column :name
    column :active
    filter :name, type: :string
    filter :active, type: :boolean
  end

  it "renders the table with records" do
    ComponentTestItem.create!(name: "Item 1", active: true)
    
    grid = TableTestGrid.new
    render_inline(described_class.new(grid))

    expect(page).to have_text("Item 1")

    expect(page).to have_selector("table")
    expect(page).to have_selector("input[name='name']")
  end

  it "renders in headless mode (no default classes)" do
    grid = TableTestGrid.new
    render_inline(described_class.new(grid, headless: true))

    # Basic check: assert it doesn't have a known default class from DEFAULT_CSS
    # e.g. DEFAULT_CSS[:container] is "power-grid-container"
    expect(page).not_to have_css(".power-grid-container")
    expect(page).to have_selector("table")
  end
end
