module FillReport
  extend ActiveSupport::Concern

  included do
    ALLOWED_IDS = [2108960, 2108961, 2108962, 2109230]
    validates :campaign_id, presence: true, inclusion: { in: ALLOWED_IDS }

    before_create :set_report_dates
    after_create :set_data
  end

  def set_report_dates
    self.start_on = 2.weeks.ago
    self.end_on = Date.today
  end

  def set_data
    campaign = Campaigns.new(user).get(campaign_id)
    self.update_attributes(
      campaign_name: campaign['name'],
      media_budget: campaign['media_budget'].to_f
    )
  end

  def generate_pdf
    PdfReport.new(self).generate
  end
end
