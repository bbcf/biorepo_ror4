class CreateFus < ActiveRecord::Migration
  def change
    create_table :fus do |t|

      t.timestamps null: false
    end
  end
end
