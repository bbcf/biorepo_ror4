class CreateMeasurementRels < ActiveRecord::Migration
  def change
    create_table :measurement_rels do |t|

      t.timestamps null: false
    end
  end
end
