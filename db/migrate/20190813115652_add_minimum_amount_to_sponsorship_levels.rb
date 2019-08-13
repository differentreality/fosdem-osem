class AddMinimumAmountToSponsorshipLevels < ActiveRecord::Migration[5.2]
  def change
    add_column :sponsorship_levels, :min_amount, :integer
  end
end
