# frozen_string_literal: true

class ZilogController < ApplicationController

  PREFIX    = ['', '#', '$', '0x'].freeze
  SEPARATOR = ['_', ',', ',_'].freeze
  DEFINE    = ['', 'db', 'defb'].freeze

  before_action :check_file

  def disasm
    return if @error

    service = Z80Disassembler::Disassembler.new(params[:file], params[:org])
    service.start
    @result = service.text
    @org = service.org
    render layout: false
  end

  def converter
    return if @error

    @result = Converter.new(params).start
    render layout: false
  end

  private

  def check_file
    @result = if params[:file].nil? || params[:file] == 'undefined'
                'File not found'
              elsif params[:file].size > (1024 * 1024)
                'File size > 1mb'
              end
    @error = @result.present?
  end
end
