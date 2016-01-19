require "prawn"
require 'squid'
# !!!!!!!!!!!!!
# TODO: recheck formulas
# !!!!!!!!!!!!!

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

  def header
    @pdf_document.text 'Platform 161'
    @pdf_document.text ['Campaign Name', @report.campaign_name].join(' ')
    @pdf_document.text ['Start Date', @report.start_on].join(' ')
    @pdf_document.text ['End Date', @report.end_on].join(' ')
    @pdf_document.text ['Media Budget', @report.media_budget].join(' ')
    @pdf_document.text ['Media Spent', @report.media_spent].join(' ')
  end

  def campaigns_table
    @pdf_document.start_new_page
    data = []
    campaing_overview_titles = ['Campaign name', 'Imps.', 'Clicks', 'Ctr', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
    data << campaing_overview_titles
    @advertiser_report_camp['results'].each do |campaign|
      gross = campaign['gross_revenues'].to_f || 0
      data << [
        campaign['campaign_name'],
        campaign['impressions'],
        campaign['clicks'],
        (campaign['ctr'].to_f.round(2) * 100).to_s + '%',
        campaign['conversions'],
        gross/(campaign['impressions'].to_i * 1000),
        gross/(campaign['clicks'].to_i),
        gross/(campaign['conversions'].to_i),
        campaign['media_budget'].to_f
      ]
    end
    @pdf_document.table(data, width: @pdf_document.bounds.width)
  end

  def creatives_table
    @pdf_document.start_new_page
    data = []
    creative_overview_titles = ['Creative size', 'Imps.', 'Clicks', 'Ctr', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
    data << creative_overview_titles
    @advertiser_report_creatives['results'].each do |creative|
      gross = creative['gross_revenues'].to_f || 0
      data << [
        creative['creative_name'],
        creative['impressions'].to_i,
        creative['clicks'],
        (creative['ctr'].to_f.round(2) * 100).to_s + '%',
        creative['conversions'],
        gross/(creative['impressions'].to_i * 1000),
        gross/(creative['clicks'].to_i),
        gross/(creative['conversions'].to_i),
        creative['media_budget'].to_f
      ]
    end
    @pdf_document.table(data, width: @pdf_document.bounds.width)
  end

  def spent_per_day_chart
    @pdf_document.start_new_page
    data = @charts_data.map {|a| {a['date'] => a['media_budget'].to_f}}.inject(:merge)
    @pdf_document.chart('Spent per day' => data)
  end

  def imp_clicks_per_day_chart
    imps = @charts_data.map {|a| {a['date'] => a['impressions'].to_i}}.inject(:merge)
    clicks = @charts_data.map {|a| {a['date'] => a['clicks'].to_i}}.inject(:merge)
    @pdf_document.chart({'Impressions' => imps, 'Clicks' => clicks}, {:type => :line})
  end

  def ecpm_ecpc_per_day_chart
    @pdf_document.start_new_page
    ecpm = @charts_data.map {|a| {a['date'] => ecpm_for_day(a)}}.inject(:merge)
    ecpc = @charts_data.map {|a| {a['date'] => ecpc_for_day(a)}}.inject(:merge)
    @pdf_document.chart({'eCPM' => ecpm, 'eCPC' => ecpc}, {:type => :line})
  end

  def ctr_per_day_chart
    data = @charts_data.map {|a| {a['date'] => a['ctr'].to_f}}.inject(:merge)
    @pdf_document.chart('CTR' => data)
  end

  def conversions_per_day_chart
    @pdf_document.start_new_page
    data = @charts_data.map {|a| {a['date'] => a['conversions'].to_i}}.inject(:merge)
    @pdf_document.chart('Conversions' => data)
  end

  private

    def ecpm_for_day(row)
      gross = row['gross_revenues'].to_f || 0
      gross/(row['impressions'].to_i * 1000)
    end

    def ecpc_for_day(row)
      gross = row['gross_revenues'].to_f || 0
      gross/(row['clicks'].to_i)
    end
end


