# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Todo controlador del storefront es público
    skip_before_action :authenticate_user!
  end
end