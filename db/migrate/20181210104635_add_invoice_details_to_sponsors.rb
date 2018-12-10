class AddInvoiceDetailsToSponsors < ActiveRecord::Migration[5.0]
  def change
    add_column :sponsors, :invoice_name, :string
    add_column :sponsors, :invoice_address, :string
    add_column :sponsors, :invoice_vat, :string
  end
end
