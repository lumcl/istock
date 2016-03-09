class BarcodesController < ApplicationController
  before_action :set_barcode, only: [:show, :edit, :update, :destroy]

  # GET /barcodes
  # GET /barcodes.json
  def index
    @barcodes = Barcode.all
  end

  def scan
    if params[:barcode].present?
      @barcode = Barcode.find_by_uuid(params[:barcode]) if params[:barcode].size == 32
      @barcode = Barcode.find_by_seq(params[:barcode]) if @barcode.blank?
    end
    if @barcode.present?
      if @barcode.name.eql?('box')
        @qty = @barcode.menge
      else
        @qty = Barcode.where(parent_id: @barcode.uuid).sum(:menge)
        @barcodes = Barcode.where(parent_id: @barcode.uuid).select(:seq,:menge)
      end
    end
  end

  # GET /barcodes/1
  # GET /barcodes/1.json
  def show
  end

  # GET /barcodes/new
  def new
    @barcode = Barcode.new
  end

  # GET /barcodes/1/edit
  def edit
  end

  # POST /barcodes
  # POST /barcodes.json
  def create
    @barcode = Barcode.new(barcode_params)

    respond_to do |format|
      if @barcode.save
        format.html { redirect_to @barcode, notice: 'Barcode was successfully created.' }
        format.json { render :show, status: :created, location: @barcode }
      else
        format.html { render :new }
        format.json { render json: @barcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /barcodes/1
  # PATCH/PUT /barcodes/1.json
  def update
    respond_to do |format|
      if @barcode.update(barcode_params)
        format.html { redirect_to @barcode, notice: 'Barcode was successfully updated.' }
        format.json { render :show, status: :ok, location: @barcode }
      else
        format.html { render :edit }
        format.json { render json: @barcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /barcodes/1
  # DELETE /barcodes/1.json
  def destroy
    @barcode.destroy
    respond_to do |format|
      format.html { redirect_to barcodes_url, notice: 'Barcode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def unlink_pallet
    barcode = Barcode.find params[:id]
    barcode.parent_id = ''
    barcode.save
    redirect_to scan_barcodes_url(barcode: barcode.uuid)
  end

  def in

  end

  def in_scan
    rows    = []
    barcode = Barcode.find_by_uuid params[:barcode]
    if barcode.present?
      uuid = barcode.parent_id.size == 32 ? barcode.parent_id : barcode.uuid
      sql  = "
          select a.uuid,a.seq,a.name,a.menge,b.matnr,b.charg
            from barcode a join stock_master b on b.uuid = a.stock_master_id
            where a.parent_id = ? or a.uuid = ?
        "
      rows = Barcode.find_by_sql [sql, uuid, uuid]
    end
    render json: rows
  end

  def in_putaway
    barcodes = Barcode.includes(:stock_master).joins(:stock_master)
                   .where(uuid: params[:uuid].split(','))

    response     = {
        barcode_uuid: 'success'
    }
    barcode_uuid = ''
    StockTran.transaction do
      begin
        barcodes.each { |barcode|
          barcode_uuid = barcode.uuid
          StockTran.create({
                               master_id:   barcode.stock_master_id,
                               barcode_id:  barcode.uuid,
                               lgort_old:   barcode.storage.blank? ? barcode.lgort : barcode.storage,
                               lgort:       params[:storage],
                               status:      barcode.status,
                               menge:       barcode.menge,
                               vbeln:       '',
                               posnr:       '',
                               meins:       barcode.stock_master.meins,
                               mjahr:       barcode.stock_master.mjahr,
                               mblnr:       barcode.stock_master.mblnr,
                               zeile:       barcode.stock_master.zeile,
                               aufnr:       barcode.stock_master.aufnr,
                               prdln:       barcode.stock_master.prdln,
                               ebeln:       barcode.stock_master.ebeln,
                               ebelp:       barcode.stock_master.ebelp,
                               mtype:       'in_putway',
                               created_by:  current_user.email,
                               created_ip:  request.ip,
                               created_mac: '',
                               updated_by:  current_user.email,
                               updated_ip:  request.ip,
                               updated_mac: '',
                           })
          barcode.status  = 'putaway'
          barcode.storage = params[:storage]
          barcode.save
        }
      rescue Exception => e
        response = {
            barcode_uuid:  barcode_uuid,
            error_message: e.message
        }
      end
    end
    render json: response
  end

  def repeat_printer
    if params[:barcode].present?
      @barcode = Barcode.find_by_uuid(params[:barcode])
      @barcode = Barcode.find_by_seq(params[:barcode]) if @barcode.blank?
    end
  end

  def printer_label
    barcode = Barcode.where(:uuid => params[:uuid]).first

    printer = Printer.find params[:printer_id]
    socket = TCPSocket.new(printer.ip, printer.port)

    hash = {
        :id => barcode.id,
        :date => barcode.stock_master.budat,
        :date_code => barcode.stock_master.datecode,
        :lot_no => barcode.stock_master.charg,
        :mo => barcode.stock_master.aufnr,
        :qty => barcode.menge,
        :product_no => barcode.stock_master.matnr,
        :seq => barcode.seq,
        :name => barcode.name.blank? ? '' : barcode.name[0].upcase,
        :meins => barcode.stock_master.meins,
        :seq_parent => (barcode.parent_id != 0 && barcode.name[0].upcase.eql?('B')) ? barcode.parent.seq : '',
        :name_parent => (barcode.parent_id != 0 && barcode.name[0].upcase.eql?('P')) ? 'P' : barcode.parent.name[0].upcase,
        :factory => barcode.stock_master.werks
    }
    zpl_command = Barcode.finish_goods_label hash
    socket.write zpl_command
    socket.close
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_barcode
    @barcode = Barcode.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def barcode_params
    params.require(:barcode).permit(:storage, :name, :stock_master_id, :parent_id, :child, :lgort, :status, :menge)
  end
end
