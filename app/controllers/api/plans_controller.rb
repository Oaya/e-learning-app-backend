module Api
  class PlansController < ApplicationController
    def index
      plans = Plan.all
      render json: plans.as_json(only: [ :id, :name, :price, :features ])
    end
  end
end
