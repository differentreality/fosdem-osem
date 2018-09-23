class AddFieldsToSponsors < ActiveRecord::Migration[5.0]
  def change
    add_column :sponsors, :amount, :float
    add_column :sponsors, :paid, :boolean
    add_column :sponsors, :has_swag, :boolean
    add_column :sponsors, :swag_delivered, :boolean
    add_column :sponsors, :swag_available, :boolean
    add_column :sponsors, :has_banner, :boolean
    add_column :sponsors, :swag, :text
    add_column :sponsors, :shipments, :text
    add_column :sponsors, :invoice_sent_at, :date
    add_column :sponsors, :state, :string
  end
end
