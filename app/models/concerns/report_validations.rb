module ReportValidations
  extend ActiveSupport::Concern

  included do
    enum status: [:processing, :error, :success]
    ALLOWED_IDS = [2108960, 2108961, 2108962, 2109230]
    validates :campaign_id, presence: true, inclusion: { in: ALLOWED_IDS }
    validates :comment, length: { maximum: 160 }
  end
end
