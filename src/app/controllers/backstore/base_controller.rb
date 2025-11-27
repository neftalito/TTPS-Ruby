# frozen_string_literal: true

module Backstore
  class BaseController < ApplicationController
    layout "backstore"
    # Requiere login siempre
    before_action :authenticate_user!
  end
end