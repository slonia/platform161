class AddPdfReportToReports < ActiveRecord::Migration
  def change
    add_column :reports, :pdf_report, :string
  end
end
