class AddDefaultForPaidToSponsors < ActiveRecord::Migration[5.0]
  def change
    change_column :sponsors, :paid, :boolean, default: false
  end
end
