class Report < ActiveRecord::Base
  mount_uploader :pdf_report, PdfUploader
  include ReportValidations
  include FillReport

  belongs_to :user

  def ecpm
    impressions.zero? ? 0 : gross_revenues/(impressions * 1000)
  end

  def ecpc
    clicks.zero? ? 0 : gross_revenues/clicks
  end

  def ecpa
    conversions.zero? ? 0 : gross_revenues/conversions
  end
end
