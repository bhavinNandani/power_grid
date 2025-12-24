class ComplexPostGrid < PowerGrid::Base
  scope { Post.includes(:user) }

  filter :title, label: "Search Title"
  filter :created_at, type: :date_range, label: "Created Date"
  filter :user_id, type: :select, collection: -> { User.pluck(:name, :id) }, label: "Author"

  column :title, header: "POST TITLE"
  column :user_id, header: "AUTHOR" do |post|
    post.user.name
  end
  column :created_at, header: "PUBLISHED ON" do |post|
    post.created_at.strftime("%b %d, %Y")
  end
end
