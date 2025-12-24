require "rails_helper"

RSpec.describe PowerGrid::Base do
  # Setup a temporary Active Record model for testing
  before(:all) do
    ActiveRecord::Base.connection.create_table :test_items, force: true do |t|
      t.string :name
      t.string :category
      t.boolean :active
      t.integer :price
      t.date :created_at
    end

    class TestItem < ActiveRecord::Base
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :test_items
  end

  let!(:item1) { TestItem.create!(name: "Item 1", category: "A", active: true, price: 10, created_at: "2023-01-01") }
  let!(:item2) { TestItem.create!(name: "Item 2", category: "B", active: false, price: 20, created_at: "2023-01-02") }
  let!(:item3) { TestItem.create!(name: "Item 3", category: "A", active: true, price: 30, created_at: "2023-01-03") }

  class TestGrid < PowerGrid::Base
    scope { TestItem.all }
    
    column :name
    column :category
    column :active
    column :price
    column :created_at

    filter :category, type: :string
    filter :active, type: :boolean
    filter :price_range, type: :number_range, sql_expression: "price"
    filter :date_range, type: :date_range, sql_expression: "created_at"
  end

  describe "initialization" do
    it "handles nil params gracefully" do
      expect { TestGrid.new(nil) }.not_to raise_error
      grid = TestGrid.new(nil)
      expect(grid.params).to eq({})
    end
  end

  describe "#records" do
    it "returns all records by default" do
      grid = TestGrid.new
      expect(grid.records).to include(item1, item2, item3)
      expect(grid.records.count).to eq(3)
    end

    describe "filtering" do
      it "filters by string equality" do
        grid = TestGrid.new(category: "A")
        expect(grid.records).to include(item1, item3)
        expect(grid.records).not_to include(item2)
      end

      it "filters by boolean (true)" do
        grid = TestGrid.new(active: "true")
        expect(grid.records).to include(item1, item3)
        expect(grid.records).not_to include(item2)
      end

      it "filters by boolean (false)" do
        grid = TestGrid.new(active: "false")
        expect(grid.records).to include(item2)
        expect(grid.records).not_to include(item1, item3)
      end

      it "filters by number range (min..max)" do
        grid = TestGrid.new(price_range_min: 15, price_range_max: 25)
        expect(grid.records).to include(item2)
        expect(grid.records).not_to include(item1, item3)
      end

      it "filters by number range (min only)" do
        grid = TestGrid.new(price_range_min: 25)
        expect(grid.records).to include(item3)
        expect(grid.records).not_to include(item1, item2)
      end

      it "filters by number range (max only)" do
        grid = TestGrid.new(price_range_max: 15)
        expect(grid.records).to include(item1)
        expect(grid.records).not_to include(item2, item3)
      end

      it "filters by date range" do
        grid = TestGrid.new(date_range: "2023-01-02 to 2023-01-03")
        expect(grid.records).to include(item2, item3)
        expect(grid.records).not_to include(item1)
      end
    end

    describe "exporting" do
      it "generates CSV" do
        grid = TestGrid.new
        csv = grid.to_csv
        expect(csv).to include("Item 1", "Item 2", "Item 3")
        expect(csv).to include("Name,Category,Active,Price,Created at")
      end
    end
  end
end
