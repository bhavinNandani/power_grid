class UsersController < ApplicationController
  def index
    @grid = UsersTable.new(params)
  end
end

class UsersTable < PowerGrid::Base
  scope { User.all }
  column :name, sortable: true, searchable: true
  column :email, sortable: true
  column :status
end
