class SaprfcMb1bsController < ApplicationController
  before_action :set_saprfc_mb1b, only: [:show, :edit, :update, :destroy]

  # GET /saprfc_mb1bs
  # GET /saprfc_mb1bs.json
  def index
    @saprfc_mb1bs = SaprfcMb1b.all
  end

  # GET /saprfc_mb1bs/1
  # GET /saprfc_mb1bs/1.json
  def show
  end

  # GET /saprfc_mb1bs/new
  def new
    @saprfc_mb1b = SaprfcMb1b.new
  end

  # GET /saprfc_mb1bs/1/edit
  def edit
  end

  # POST /saprfc_mb1bs
  # POST /saprfc_mb1bs.json
  def create
    @saprfc_mb1b = SaprfcMb1b.new(saprfc_mb1b_params)

    respond_to do |format|
      if @saprfc_mb1b.save
        format.html { redirect_to @saprfc_mb1b, notice: 'Saprfc mb1b was successfully created.' }
        format.json { render :show, status: :created, location: @saprfc_mb1b }
      else
        format.html { render :new }
        format.json { render json: @saprfc_mb1b.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saprfc_mb1bs/1
  # PATCH/PUT /saprfc_mb1bs/1.json
  def update
    respond_to do |format|
      if @saprfc_mb1b.update(saprfc_mb1b_params)
        format.html { redirect_to @saprfc_mb1b, notice: 'Saprfc mb1b was successfully updated.' }
        format.json { render :show, status: :ok, location: @saprfc_mb1b }
      else
        format.html { render :edit }
        format.json { render json: @saprfc_mb1b.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /saprfc_mb1bs/1
  # DELETE /saprfc_mb1bs/1.json
  def destroy
    @saprfc_mb1b.destroy
    respond_to do |format|
      format.html { redirect_to saprfc_mb1bs_url, notice: 'Saprfc mb1b was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saprfc_mb1b
      @saprfc_mb1b = SaprfcMb1b.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saprfc_mb1b_params
      params.require(:saprfc_mb1b).permit(:uuid, :parent_id, :matnr, :werks, :lgort, :old_lgort, :charg, :bwart, :menge, :menge, :msg_type, :msg_id, :msg_number, :msg_text, :rfc_date, :status, :mjahr, :mblnr, :zeile, :creator, :updater)
    end
end
