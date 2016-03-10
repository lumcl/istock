class StockTransController < ApplicationController
  before_action :set_stock_tran, only: [:show, :edit, :update, :destroy]

  # GET /stock_trans
  # GET /stock_trans.json
  def index
    @stock_trans = StockTran.all
  end

  # GET /stock_trans/1
  # GET /stock_trans/1.json
  def show
  end

  # GET /stock_trans/new
  def new
    @stock_tran = StockTran.new
  end

  # GET /stock_trans/1/edit
  def edit
  end

  # POST /stock_trans
  # POST /stock_trans.json
  def create
    @stock_tran = StockTran.new(stock_tran_params)

    respond_to do |format|
      if @stock_tran.save
        format.html { redirect_to @stock_tran, notice: 'Stock tran was successfully created.' }
        format.json { render :show, status: :created, location: @stock_tran }
      else
        format.html { render :new }
        format.json { render json: @stock_tran.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_trans/1
  # PATCH/PUT /stock_trans/1.json
  def update
    respond_to do |format|
      if @stock_tran.update(stock_tran_params)
        format.html { redirect_to @stock_tran, notice: 'Stock tran was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_tran }
      else
        format.html { render :edit }
        format.json { render json: @stock_tran.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_trans/1
  # DELETE /stock_trans/1.json
  def destroy
    @stock_tran.destroy
    respond_to do |format|
      format.html { redirect_to stock_trans_url, notice: 'Stock tran was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def stock_in
    master_id = params[:master_id] || ''
  end

  def in_process
    master_id = params[:master_id] || 0

    list = Barcode.where(:id => master_id)

    if list.empty?
      redirect_to in_stock_trans_url, notice: 'error message'
    else
      list.each do |barcode|
        if barcode.name = 'pallet'

          Barcode.where(parent_id: master_id).each do |bar|
            StockTran.create(
                {
                    :master_id   => bar.stock_master_id,
                    :barcode_id  => bar.id,
                    :lgort_old   => bar.lgort,
                    :lgort       => bar.lgort,
                    :status      => 'in',
                    :qty         => bar.menge,
                    :vbeln       => '',
                    :posnr       => '',
                    :meins       => bar.stock_master.meins,
                    :mjahr       => bar.stock_master.mjahr,
                    :mblnr       => bar.stock_master.mblnr, :zeile => bar.stock_master.zeile,
                    :aufnr       => bar.stock_master.aufnr, :prdln => '',
                    :ebeln       => bar.stock_master.ebeln, :ebelp => bar.stock_master.ebelp,
                    :mtype       => '',
                    :created_by  => current_user,
                    :created_ip  => request.remote_ip,
                    :created_mac => request.env['HTTP_X_FORWARDED_FOR'],
                    :updated_by  => current_user,
                    :updated_ip  => request.remote_ip, :updated_mac => ''
                }
            )
          end
          Barcode.where(parent_id: master_id).update_all({ status: 'in' })
        end
        barcode.status = 'in'
        barcode.save
      end
      redirect_to in_stock_trans_url, notice: 'success'
    end
  end

  def in

  end

  def out

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_stock_tran
    @stock_tran = StockTran.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def stock_tran_params
    params.require(:stock_tran).permit(:master_id, :barcode_id, :lgort_old, :lgort, :status, :qty, :vbeln, :posnr, :meins, :mjahr, :mblnr, :zeile, :aufnr, :prdln, :ebeln, :ebelp, :mtype, :created_by, :created_ip, :created_mac, :updated_by, :updated_ip, :updated_mac)
  end
end
