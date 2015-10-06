class CreateBooks < ActiveRecord::Migration

  def change
    create_table :books do |t|
      t.column :name, :string
      t.string :format
      t.column :status, :integer, default: 0
      t.column :read_status, :integer, default: 0
      t.column :nullable_status, :integer
    end
  end

end
