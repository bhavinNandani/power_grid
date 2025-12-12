require "rails_helper"

RSpec.describe PowerGrid::TableComponent, type: :component do
  class UsersTable < PowerGrid::Base
    scope { User.all }
    column :name, sortable: true
    column :email
  end

  before do
    User.create!(name: "Alice", email: "alice@example.com")
    User.create!(name: "Bob", email: "bob@example.com")
  end

  it "renders the table with records" do
    with_request_url "/users" do
      render_inline(described_class.new(UsersTable, params: {}))
    end

    expect(page).to have_content("User 1")
    expect(page).to have_content("User 2")
    expect(page).to have_content("Name")
    expect(page).to have_css("table.min-w-full") # Tailwind class
    expect(page).to have_select("per_page")
    expect(page).to have_content("Showing")
    expect(page).to have_content("entries")
  end

  it "renders search input" do
    with_request_url "/users" do
      render_inline(described_class.new(UsersTable, params: {}))
    end
    expect(page).to have_field("q")
  end
end
