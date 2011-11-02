class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.string :nickname
      t.string :name
      t.integer :followee_count
      t.string :provider
      t.string :token
      t.string :secret

      t.timestamps
    end
  end
end
