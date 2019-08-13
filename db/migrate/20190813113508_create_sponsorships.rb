class CreateSponsorships < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsorships do |t|
      t.integer :sponsor_id
      t.integer :amount
      t.integer :sponsorship_level_id
      t.integer :user_id
      t.integer :conference_id
    end
  end
end
