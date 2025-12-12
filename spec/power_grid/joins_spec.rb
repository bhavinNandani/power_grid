require "rails_helper"

RSpec.describe PowerGrid::Base, type: :model do
  class UsersWithPostsTable < PowerGrid::Base
    scope { User.joins(:posts) }
    
    column :name, sortable: true, searchable: true
    # Define a column that maps to a joined table field
    column :"posts.title", sortable: true, searchable: true, sql_expression: "posts.title"
  end

  before do
    Post.delete_all
    User.delete_all
    
    alice = User.create!(name: "Alice", email: "alice@example.com", status: "active")
    bob = User.create!(name: "Bob", email: "bob@example.com", status: "inactive")
    
    Post.create!(user: alice, title: "Alice's Adventures")
    Post.create!(user: bob, title: "Ruby on Rails")
  end

  describe "joined queries" do
    it "filters by joined column" do
      grid = UsersWithPostsTable.new({ q: "Adventures" })
      expect(grid.records.map(&:name)).to contain_exactly("Alice")
    end

    it "sorts by joined column" do
      grid = UsersWithPostsTable.new({ order: :"posts.title", dir: :desc })
      expect(grid.records.map(&:name)).to eq(["Bob", "Alice"])
    end
  end

  describe "N+1 optimization" do
    class UsersWithIncludesTable < PowerGrid::Base
      scope { User.all }
      column :title, includes: :posts do |user|
        user.posts.first&.title
      end
    end

    it "eager loads associations defined in columns" do
      grid = UsersWithIncludesTable.new({})
      # We check if the relation has includes value
      relation = grid.records
      expect(relation.includes_values).to include(:posts)
    end
  end
end
