class Report < ActiveRecord::Base
  mount_uploader :pdf_report, PdfUploader
  include FillReport

  belongs_to :user
end
