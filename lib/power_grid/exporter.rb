require 'csv'

module PowerGrid
  class Exporter
    def initialize(grid)
      @grid = grid
    end

    def to_csv
      collection = @grid.records
      columns = @grid.class.defined_columns

      CSV.generate(headers: true) do |csv|
        # Header Row
        csv << columns.map { |name, options| options[:header] || name.to_s.humanize }

        # Data Rows
        collection.each do |record|
          csv << columns.map do |name, options|
            # Try to fetch value from record
            if record.respond_to?(name)
              record.public_send(name)
            else
              # Fallback for virtual columns not on the model
              nil 
            end
          end
        end
      end
    end
  end
end
