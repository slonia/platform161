require 'prawn'
require 'squid'

class PdfReport
  def initialize(report)
    @report = report
    @advertiser_report = AdvertiserReports.new(@report.user)
    @advertiser_report_camp = AdvertiserReports.new(report.user).generate
    @advertiser_report_creatives = AdvertiserReports.new(report.user).generate(groupings: :creative)
    @charts_data = @advertiser_report.generate(groupings: :date, interval: :daily)['results']
    @name = Rails.root.join('tmp', SecureRandom.hex + '.pdf')
    @pdf_document = Prawn::Document.new
  end

  def generate
    header
    campaigns_table
    creatives_table
    spent_per_day_chart
    imp_clicks_per_day_chart
    ecpm_ecpc_per_day_chart
    ctr_per_day_chart
    conversions_per_day_chart
    @pdf_document.render_file(@name)
    @name
  end

  private

    def header
      @pdf_document.font_size 36
      @pdf_document.text 'Platform 161'
      @pdf_document.font_size 12
      @pdf_document.text ['Campaign Name', '<b>', @report.campaign_name, '</b>'].join(' '), inline_format: true
      @pdf_document.text ['Campaign Id', '<b>', @report.campaign_id, '</b>'].join(' '), inline_format: true
      @pdf_document.text ['Start Date', '<b>', @report.start_on, '</b>'].join(' '), inline_format: true
      @pdf_document.text ['End Date', '<b>', @report.end_on, '</b>'].join(' '), inline_format: true
      @pdf_document.text ['Media Budget', '<b>', @report.media_budget, '</b>'].join(' '), inline_format: true
      @pdf_document.text ['Media Spent', '<b>', @report.media_spent, '</b>'].join(' '), inline_format: true
    end

    def campaigns_table
      @pdf_document.start_new_page
      data = []
      campaing_overview_titles = ['Campaign name', 'Imps.', 'Clicks', 'Ctr', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
      data << campaing_overview_titles
      totals = Array.new(8, 0)
      total_gross = 0
      @advertiser_report_camp['results'].each do |campaign|
        row = table_row(campaign)
        data << row
        row_without_name = row[1..-1] # deleting campaign name
        row_without_name.each_with_index do |tot, i|
          totals[i] += row_without_name[i]
        end
        total_gross += campaign['gross_revenues'].to_f || 0
      end
      [2, 4, 5, 6].each do |avg_ind|
        totals[avg_ind] /= @advertiser_report_camp['results'].size
      end
      data << (['Total'] + totals)
      update_report_with_campaigns_data(totals, total_gross)
      @pdf_document.table(data, width: @pdf_document.bounds.width)
    end

    def creatives_table
      @pdf_document.start_new_page
      data = []
      creative_overview_titles = ['Creative size', 'Imps.', 'Clicks', 'Ctr, %', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
      data << creative_overview_titles
      totals = Array.new(8, 0)
      @advertiser_report_creatives['results'].each do |creative|
        row = table_row(creative)
        data << row
        row_without_name = row[1..-1] # deleting creative size
        row_without_name.each_with_index do |tot, i|
          totals[i] += row_without_name[i]
        end
      end
      [2, 4, 5, 6].each do |avg_ind|
        totals[avg_ind] /= @advertiser_report_creatives['results'].size
      end
      data << (['Total'] + totals)
      @pdf_document.table(data, width: @pdf_document.bounds.width)
    end

    def table_row(row)
      gross = row['gross_revenues'].to_f || 0
      ecpm = row['impressions'].to_i.zero? ? 0 : gross/(row['impressions'].to_i * 1000)
      ecpc = row['clicks'].to_i.zero? ? 0 : gross/row['clicks'].to_i
      ecpa = row['conversions'].to_i.zero? ? 0 : gross/row['conversions'].to_i
      [
        row['campaign_name'] || row['creative_name'],
        row['impressions'].to_i,
        row['clicks'].to_i,
        (row['ctr'].to_f * 100).round,
        row['conversions'].to_i,
        ecpm.round(2),
        ecpc.round(2),
        ecpa.round(2),
        row['campaign_cost'].to_f.round(2)
      ]
    end

    def update_report_with_campaigns_data(totals, gross)
      @report.update_attributes(
        impressions: totals[0],
        clicks: totals[1],
        ctr: totals[2],
        conversions: totals[3],
        gross_revenues: gross
      )
    end

    def spent_per_day_chart
      @pdf_document.start_new_page
      @pdf_document.font_size 24
      @pdf_document.text 'Spent per day'
      data = @charts_data.map {|a| {a['date'] => a['campaign_cost'].to_f}}.inject(:merge)
      @pdf_document.chart('Spent per day' => data)
      @pdf_document.font_size 12
    end

    def imp_clicks_per_day_chart
      @pdf_document.font_size 24
      @pdf_document.text 'Impressions vs clicks per day'
      imps = @charts_data.map {|a| {a['date'] => a['impressions'].to_i}}.inject(:merge)
      clicks = @charts_data.map {|a| {a['date'] => a['clicks'].to_i}}.inject(:merge)
      @pdf_document.chart({'Impressions' => imps, 'Clicks' => clicks}, {:type => :line})
      @pdf_document.font_size 12
    end

    def ecpm_ecpc_per_day_chart
      @pdf_document.start_new_page
      @pdf_document.font_size 24
      @pdf_document.text 'eCPM vs eCPC per day'
      ecpm = @charts_data.map {|a| {a['date'] => ecpm_for_day(a)}}.inject(:merge)
      ecpc = @charts_data.map {|a| {a['date'] => ecpc_for_day(a)}}.inject(:merge)
      @pdf_document.chart({'eCPM' => ecpm, 'eCPC' => ecpc}, {:type => :line})
      @pdf_document.font_size 12
    end

    def ctr_per_day_chart
      @pdf_document.font_size 24
      @pdf_document.text 'CTR per day'
      data = @charts_data.map {|a| {a['date'] => a['ctr'].to_f}}.inject(:merge)
      @pdf_document.chart('CTR' => data)
      @pdf_document.font_size 12
    end

    def conversions_per_day_chart
      @pdf_document.start_new_page
      @pdf_document.font_size 24
      @pdf_document.text 'Conversions per day'
      data = @charts_data.map {|a| {a['date'] => a['conversions'].to_i}}.inject(:merge)
      @pdf_document.chart('Conversions' => data)
      @pdf_document.font_size 12
    end

    def ecpm_for_day(row)
      gross = row['gross_revenues'].to_f || 0
      gross/(row['impressions'].to_i * 1000)
    end

    def ecpc_for_day(row)
      gross = row['gross_revenues'].to_f || 0
      gross/(row['clicks'].to_i)
    end
end


