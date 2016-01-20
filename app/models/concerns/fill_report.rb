module FillReport
  extend ActiveSupport::Concern

  included do
    before_create :set_report_dates
    after_create :set_data
    after_create :save_file
  end

  def generate_pdf
    PdfReport.new(self).generate
  end

  private

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

    def save_file
      file = generate_pdf
      self.pdf_report = File.open(file)
      if self.save
        self.update_attributes(status: :success)
        File.delete(file)
      end
    rescue Exception => e
      self.update_attributes(status: :error)
    end
end
