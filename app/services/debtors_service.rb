require 'csv'

class DebtorsService
  def initialize
    @data = []
    @codes = [(1..78).to_a, 86, 89, 82, 92].flatten.map { |x| x.to_s.rjust(2, '0') }
  end

  def call
    # (1..3).each { |x| process(x) }
    process

    csv_string = CSV.generate do |csv|
      csv << ['ФИО', 'Дата рождения', 'Код региона']
      @data.each do |data|
        csv << data
      end
    end
    csv_string
  end

  private

  def process
    @codes.each do |code|
      resp = send_request(code)
      next unless resp

      json = JSON.parse resp
      parsed_data = Nokogiri::HTML.parse(json['html']) if json && json['html']

      parsed_data.css('.b-personnel__card').each do |tag|
        title = tag.css('.b-personnel__card-title')[0].text.split(',')[0]
        text = tag.css('.b-personnel__card-text')[0].text
        date = DatesFromString.new.find_date(text)[0] || DatesFromString.new.find_date(title)[0]
        @data << [title, date.nil? ? '' : date.to_date.strftime('%d.%m.%Y'), code]
      end
    end
    # page = parsed_data.xpath('//a').last.attributes['href'].text.split('page=').last.split('&').first.to_i
  end

  def send_request(code, page = nil)
    link = "https://fssp.gov.ru/vnimanie_rozysk/action/debtors/?#{"page=#{page}&" if page}region=#{code}"
    print code
    z = RestClient.get(link)
    puts
    z
  rescue
    puts(' - fail')
    nil
  end
end
