class SimpleUserGrid < PowerGrid::Base
  scope { User.all }

  column :name, header: "NAME"
  column :email, header: "EMAIL ADDRESS"
  column :status, header: "STATUS" do |user|
    if user.status == "active"
      "<span class='inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20'>Active</span>".html_safe
    else
      "<span class='inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10'>Inactive</span>".html_safe
    end
  end
end
