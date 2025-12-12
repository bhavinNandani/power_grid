require "rails_helper"

RSpec.describe PowerGrid::Base, type: :model do
  # Setup models for this test
  class Post < ActiveRecord::Base
    belongs_to :user
  end

  # Open the User class from dummy app and add association
  User.class_eval do
    has_many :posts, class_name: "Post"
  end

  class UsersWithPostsTable < PowerGrid::Base
    scope { User.joins(:posts) }
    
    column :name, sortable: true, searchable: true
    # Define a column that maps to a joined table field
    column :"posts.title", sortable: true, searchable: true, sql_expression: "posts.title"
  end

  before(:all) do
    # Create temp table for posts
    ActiveRecord::Schema.define do
      create_table :posts, force: true do |t|
        t.string :title
        t.references :user
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :posts
    end
  end

  before do
    User.delete_all
    Post.delete_all
    
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
