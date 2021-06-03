# frozen_string_literal: true

class DisasmController < ApplicationController

  def index
    @result = []
  end

  def xfile
    @result = Disasm.new(params[:file], params[:org]).start
    render layout: false
  end
end
