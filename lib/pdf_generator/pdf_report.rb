require "prawn"

# !!!!!!!!!!!!!
# TODO: recheck formulas
# !!!!!!!!!!!!!

class PdfReport
  def initialize(report)
    @report = report
    @advertiser_report_camp = AdvertiserReports.new(report.user).generate
    @advertiser_report_creatives = AdvertiserReports.new(report.user).generate(groupings: :creatives)
  end

  def generate
    Prawn::Document.new do
      text 'hello_world'
      # campaigns_table
      # creatives_table
      # spent_per_day_chart
      # imp_clicks_per_day_chart
      # ecpm_ecpc_per_day_chart
      # ctr_per_day_chart
      # conversions_per_day_chart
    end.render
  end

  def campaigns_table
    campaing_overview_titles = ['Campaign name', 'Imps.', 'Clicks' 'Ctr', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
    @advertiser_report_camp['results'].each do |campaign|
      gross = campaign['gross_revenues'].to_f || 0
      data = [
        campaign['campaign_name'],
        campaign['impressions'],
        campaign['clicks'],
        (campaign['ctr'].to_f.round(2) * 100).to_s + '%',
        campaign['conversions'],
        gross/(campaign['impressions'].to_i * 1000),
        gross/(campaign['clicks'].to_i),
        gross/(campaign['conversions'].to_i),
        campaign['media_budget'].to_i
      ]
      table([campaing_overview_titles, data])
    end
  end

  def creatives_table
    creative_overview_titles = ['Creative size', 'Imps.', 'Clicks' 'Ctr', 'Conv', 'eCPM', 'eCPC', 'eCPA', 'Spent']
    @advertiser_report_creatives['results'].each do |creative|
      gross = creative['gross_revenues'].to_f || 0
      data = [
        creative['creative_name'],
        creative['impressions'].to_i,
        creative['clicks'],
        (creative['ctr'].to_f.round(2) * 100).to_s + '%',
        creative['conversions'],
        gross/(creative['impressions'].to_i * 1000),
        gross/(creative['clicks'].to_i),
        gross/(creative['conversions'].to_i),
        campaign['media_budget'].to_i
      ]
      table([creative_overview_titles, data])
    end
  end

  def spent_per_day_chart
    results_per_date = @advertiser_report_camp
    data = results_per_date.map {|a| {a['date'] => a['media_budget'].to_i}}.map(:merge)
    chart('Spent per day' => data)
  end

  def imp_clicks_per_day_chart
    results_per_date = @advertiser_report_camp
    imps = results_per_date.map {|a| {a['date'] => a['impressions'].to_i}}.map(:merge)
    clicks = results_per_date.map {|a| {a['date'] => a['clicks'].to_i}}.map(:merge)
    chart('Impressions' => imps, 'Clicks' => clicks)
  end

  def ecpm_ecpc_per_day_chart
    results_per_date = @advertiser_report_camp
    ecpm = results_per_date.map {|a| {a['date'] => ecpm_for_day(a)}}.map(:merge)
    ecpc = results_per_date.map {|a| {a['date'] => ecpc_for_day(a)}}.map(:merge)
    chart('eCPM' => ecpm, 'eCPC' => ecpc)
  end

  def ctr_per_day_chart
    results_per_date = @advertiser_report_camp
    data = results_per_date.map {|a| {a['date'] => a['ctr'].to_f}}.map(:merge)
    chart('CTR' => data)
  end

  def conversions_per_day_chart
    results_per_date = @advertiser_report_camp
    data = results_per_date.map {|a| {a['date'] => a['conversions'].to_i}}.map(:merge)
    chart('Conversions' => data)
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


