# frozen_string_literal: true

class ZilogController < ApplicationController

  SIZE      = 1..8
  PREFIX    = ['', '#', '$', '0x'].freeze
  SEPARATOR = ['_', ',', ',_'].freeze
  SPLITTER  = 1..32
  DEFINE    = ['', 'db', 'defb'].freeze

  def disasm
    @result = {}
  end

  def converter
  end

  def xfile
    @result = Z80Disassembler::Disassembler.new(params[:file], params[:org]).start
    render layout: false
  end

  def yfile
    @result = params[:file] != 'undefined' ? Converter.new(params).start : ''
    render layout: false
  end
end
