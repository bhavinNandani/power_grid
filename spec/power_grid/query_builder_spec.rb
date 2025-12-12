require "rails_helper"

RSpec.describe PowerGrid::Base, type: :model do
  class UsersTable < PowerGrid::Base
    scope { User.all }
    column :name, sortable: true, searchable: true
    column :email, sortable: true
    column :status
  end

  before do
    User.create!(name: "Alice", email: "alice@example.com", status: "active")
    User.create!(name: "Bob", email: "bob@example.com", status: "inactive")
    User.create!(name: "Charlie", email: "charlie@example.com", status: "active")
  end

  describe "#records" do
    it "returns all records by default" do
      grid = UsersTable.new({})
      expect(grid.records.count).to eq(3)
    end

    it "filters by search term" do
      grid = UsersTable.new({ q: "Alice" })
      expect(grid.records.map(&:name)).to contain_exactly("Alice")
    end

    it "sorts by column ascending" do
      grid = UsersTable.new({ order: :name, dir: :asc })
      expect(grid.records.map(&:name)).to eq(["Alice", "Bob", "Charlie"])
    end

    it "sorts by column descending" do
      grid = UsersTable.new({ order: :name, dir: :desc })
      expect(grid.records.map(&:name)).to eq(["Charlie", "Bob", "Alice"])
    end

    it "paginates results" do
      grid = UsersTable.new({ page: 1, per_page: 2, order: :name, dir: :asc })
      expect(grid.records.map(&:name)).to eq(["Alice", "Bob"])
      
      grid_page_2 = UsersTable.new({ page: 2, per_page: 2, order: :name, dir: :asc })
      expect(grid_page_2.records.map(&:name)).to eq(["Charlie"])
    end
  end
end
