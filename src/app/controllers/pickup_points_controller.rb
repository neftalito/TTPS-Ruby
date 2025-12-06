class PickupPointsController < ApplicationController
  before_action :set_pickup_point, only: %i[show edit update destroy]

  # GET /pickup_points or /pickup_points.json
  def index
    @pickup_points = PickupPoint.all
  end

  # GET /pickup_points/1 or /pickup_points/1.json
  def show; end

  # GET /pickup_points/new
  def new
    @pickup_point = PickupPoint.new
  end

  # GET /pickup_points/1/edit
  def edit; end

  # POST /pickup_points or /pickup_points.json
  def create
    @pickup_point = PickupPoint.new(pickup_point_params)

    respond_to do |format|
      if @pickup_point.save
        format.html { redirect_to @pickup_point, notice: "Pickup point was successfully created." }
        format.json { render :show, status: :created, location: @pickup_point }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pickup_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pickup_points/1 or /pickup_points/1.json
  def update
    respond_to do |format|
      if @pickup_point.update(pickup_point_params)
        format.html { redirect_to @pickup_point, notice: "Pickup point was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @pickup_point }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pickup_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pickup_points/1 or /pickup_points/1.json
  def destroy
    @pickup_point.destroy!

    respond_to do |format|
      format.html { redirect_to pickup_points_path, notice: "Pickup point was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pickup_point
    @pickup_point = PickupPoint.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def pickup_point_params
    params.expect(pickup_point: %i[name address city province enabled])
  end
end
