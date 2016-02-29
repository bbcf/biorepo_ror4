class CreateAttrValues < ActiveRecord::Migration
  def change
    create_table :attr_values do |t|

      t.timestamps null: false
    end
  end
end
