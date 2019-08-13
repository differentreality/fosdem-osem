class ChangeSponsorIdToSponsorshipId < ActiveRecord::Migration[5.2]
  def change
    remove_column :sponsors, :sponsorship_level_id
    remove_column :sponsors, :conference_id
  end
end
