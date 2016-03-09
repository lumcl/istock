class StockMastersController < ApplicationController
  before_action :set_stock_master, only: [:show, :edit, :update, :destroy]

  # GET /stock_masters
  # GET /stock_masters.json
  def index
    @stock_masters = StockMaster.all.page
  end

  # GET /stock_masters/1
  # GET /stock_masters/1.json
  def show
  end

  # GET /stock_masters/new
  def new
    @stock_master = StockMaster.new
  end

  # GET /stock_masters/1/edit
  def edit
  end

  # POST /stock_masters
  # POST /stock_masters.json
  def create
    @stock_master = StockMaster.new(stock_master_params)

    respond_to do |format|
      if @stock_master.save
        format.html { redirect_to @stock_master, notice: 'Stock master was successfully created.' }
        format.json { render :show, status: :created, location: @stock_master }
      else
        format.html { render :new }
        format.json { render json: @stock_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_masters/1
  # PATCH/PUT /stock_masters/1.json
  def update
    respond_to do |format|
      if @stock_master.update(stock_master_params)
        format.html { redirect_to @stock_master, notice: 'Stock master was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_master }
      else
        format.html { render :edit }
        format.json { render json: @stock_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_masters/1
  # DELETE /stock_masters/1.json
  def destroy
    @stock_master.destroy
    respond_to do |format|
      format.html { redirect_to stock_masters_url, notice: 'Stock master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_master
      @stock_master = StockMaster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_master_params
      params.require(:stock_master).permit(:matnr, :maktx, :matkl, :charg, :menge, :box_cnt, :pallet_cnt, :werks, :meins, :mjahr, :mblnr, :zeile, :aufnr, :prdln, :ebeln, :ebelp)
    end
end
