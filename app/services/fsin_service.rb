require 'csv'

class FsinService
  def initialize(text, page = 1)
    @page = page.to_i
    @text = CGI::escape text.encode('windows-1251')
    @data = []
  end

  def call
    process
    @data
  end

  private

  def process
    resp = send_request
    return unless resp

    parsed_data = Nokogiri::HTML.parse(resp)
    parsed_data.css('.news-list').children.each { |t| parse(t) }
  end

  def parse(tag)
    text = tag.text
    date = DatesFromString.new.find_date(text).first
    dt = begin
           date&.to_date ? date.to_date.strftime('%d.%m.%Y') : ''
         rescue
           nil
         end
    return if dt.blank?

    if tag.children.size > 1
      tag.children.each do |t|
        parse(t)
      end
    else
      fio = text.split(dt).first
      return unless fio

      fio = fio.delete("\r\n\t,.;:")
      fio = fio.split(' ').compact.join(' ')
      @data << { fio: fio, dt: dt }
    end
  end

  def send_request
    link = "https://limited.fsin.gov.ru/criminal/?arrFilterAdd_pf%5Bfio%5D=#{@text}&set_filter=Y"
    resp = RestClient.get(link)
    resp.body if resp.code == 200
  rescue
    nil
  end
end
