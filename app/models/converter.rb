# frozen_string_literal: true

class Converter

  def initialize(params)
    @size      = params[:size]&.to_i               ||  1
    @prefix    = params[:prefix]                   || '#'
    @splitter  = params[:splitter]&.to_i           ||  8
    @separator = params[:separator]&.sub('_', ' ') || ', '
    @file      = params[:file]
  end

  def start
    array = []
    File.open(@file).each_byte do |byte|
      array << byte.to_s(16).rjust(2, '0')
    end
    array = array.each_slice(@splitter).to_a.map do |arr|
      arr.each_slice(@size).to_a.map(&:join)
          .map { |str| @prefix + str }.join(@separator)
    end
    array.join("\n")
  end
end
