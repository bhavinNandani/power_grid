require "spec_helper"

RSpec.describe PowerGrid::Base do
  let(:table_class) do
    Class.new(PowerGrid::Base) do
      scope { User.all }
      column :name, sortable: true
      column :email
      column :custom do |record|
        record.name.upcase
      end
    end
  end

  describe ".scope" do
    it "stores the scope block" do
      expect(table_class.defined_scope).to be_a(Proc)
    end
  end

  describe ".column" do
    it "stores column definitions" do
      columns = table_class.defined_columns
      expect(columns.keys).to contain_exactly(:name, :email, :custom)
      expect(columns[:name][:sortable]).to be true
      expect(columns[:custom][:block]).to be_a(Proc)
    end
  end
end
