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
        @qty      = Barcode.where(parent_id: @barcode.uuid).sum(:menge)
        @barcodes = Barcode.where(parent_id: @barcode.uuid).select(:seq, :menge)
      end
    end
  end

  def link_scan
    if params[:barcode].present?
      @barcode = Barcode.find_by_uuid(params[:barcode]) if params[:barcode].size == 32
      @barcode = Barcode.find_by_seq(params[:barcode]) if @barcode.blank?
    end
    if @barcode.present?
      if @barcode.name.eql?('box')
        @qty = @barcode.menge
      else
        @qty      = Barcode.where(parent_id: @barcode.uuid).sum(:menge)
        @barcodes = Barcode.where(parent_id: @barcode.uuid).select(:seq, :menge)
      end
    end
  end

  def split_box
    if params[:barcode].present?
      @barcode = Barcode.find_by_uuid(params[:barcode]) if params[:barcode].size == 32
      @barcode = Barcode.find_by_seq(params[:barcode]) if @barcode.blank?
    end

    # if @barcode.present?
    #   if @barcode.name.eql?('box')
    #     @qty = @barcode.menge
    #   else
    #     @qty = Barcode.where(parent_id: @barcode.uuid).sum(:menge)
    #     @barcodes = Barcode.where(parent_id: @barcode.uuid).select(:seq,:menge)
    #   end
    # end
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

  def link_pallet
    barcode           = Barcode.find params[:id]
    barcode.parent_id = params[:parent_id]
    barcode.save
    redirect_to link_scan_barcodes_url
  end

  def unlink_pallet
    barcode           = Barcode.find params[:id]
    barcode.parent_id = '0'
    barcode.save
    redirect_to scan_barcodes_url(barcode: barcode.uuid)
  end

  def unlink_box

    message     = '分箱成功!'
    uuid        = ''
    qtys        = params[:qty]
    old_barcode = Barcode.find params[:uuid]
    menge       = old_barcode.menge
    barcodes    = []

    input_qty = 0.0
    qtys.select { |b| b.to_f > 0 }.each { |qty|
      input_qty += qty.to_f
    }

    if input_qty > menge
      message = '分箱總數量大於原箱數量!'
      uuid    = old_barcode.uuid
    else
      begin
        Barcode.transaction do
          qtys.select { |b| b.to_f > 0 }.each { |qty|
            new_barcode       = old_barcode.dup
            new_barcode.seq   = nil
            new_barcode.menge = qty.to_f
            new_barcode.save!
            menge = menge - qty.to_f
            barcodes.append new_barcode.uuid
          }
          if old_barcode.name.eql?('box') and menge != 0
            new_barcode       = old_barcode.dup
            new_barcode.seq   = nil
            new_barcode.menge = menge
            new_barcode.save!
            barcodes.append new_barcode.uuid
          end

          old_barcode.status = 'split_box'
          old_barcode.menge  = 0
          old_barcode.save!
        end
      rescue Exception => error
        message = "分箱失敗!, #{error.message}"
        uuid    = old_barcode.uuid
        barcodes.clear
      end

      printer = Printer.find params[:printer_id]
      socket  = TCPSocket.new(printer.ip, printer.port)

      Barcode.where(uuid: barcodes).order(seq: :asc).each { |barcode|
        hash        = {
            :id          => barcode.id,
            :date        => barcode.stock_master.budat,
            :date_code   => barcode.stock_master.datecode,
            :lot_no      => barcode.stock_master.charg,
            :mo          => barcode.stock_master.aufnr,
            :qty         => barcode.menge,
            :product_no  => barcode.stock_master.matnr,
            :seq         => barcode.seq,
            :name        => barcode.name.blank? ? '' : barcode.name[0].upcase,
            :meins       => barcode.stock_master.meins,
            :seq_parent  => barcode.parent.present? ? barcode.parent.seq : '',
            :name_parent => barcode.parent.present? ? '' : '',
            :factory     => barcode.stock_master.werks
        }
        zpl_command = Barcode.finish_goods_label hash
        socket.write zpl_command
      }

      socket.close
    end
    redirect_to split_box_barcodes_url(barcode: uuid), notice: message
  end

  def packing

    message = '填箱成功!'
    uuid = ''
    old_barcode = Barcode.find params[:uuid]
    other_barcode = Barcode.find params[:other_id]
    menge       = 0
    barcodes = []

    if old_barcode.menge + other_barcode.menge >= old_barcode.stock_master.menge
      menge = old_barcode.stock_master.menge
    else
      menge = old_barcode.menge + other_barcode.menge
    end

      begin
        #被填箱更改數量
        old_barcode.menge = menge
        old_barcode.save

        #填箱更改數量 0
        other_barcode.menge = 0
        other_barcode.status = 'packing_box'
        other_barcode.save

        if old_barcode.menge + other_barcode.menge >= old_barcode.stock_master.menge
          bar = Barcode.create({
                             storage: old_barcode.storage,
                             name: old_barcode.name,
                             stock_master_id: old_barcode.stock_master_id,
                             parent_id: old_barcode.parent_id,
                             child: old_barcode.child,
                             lgort: old_barcode.lgort,
                             status: old_barcode.status,
                             menge: old_barcode.menge + other_barcode.menge - old_barcode.stock_master.menge
                         })

          barcodes.append bar.uuid
        end
      rescue Exception => error
        message = "填箱失敗!, #{error.message}"
        uuid = old_barcode.uuid
        barcodes.clear
      end

      printer = Printer.find params[:printer_id]
      socket = TCPSocket.new(printer.ip, printer.port)

      Barcode.where(uuid: barcodes).order(seq: :asc).each { |barcode|
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
          :seq_parent => barcode.parent.present? ? barcode.parent.seq : '',
          :name_parent => barcode.parent.present? ? barcode.parent.name[0].upcase : '',
          :factory => barcode.stock_master.werks
        }
        zpl_command = zpl_command + (Barcode.finish_goods_label hash)
#        socket.write zpl_command
      }

      socket.write zpl_command

      socket.close

    redirect_to packing_box_barcodes_url(barcode: uuid), notice: message

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
        receipts = {}
        barcodes.each { |barcode|
          barcode_uuid = barcode.uuid

          receipts.key?(barcode.stock_master_id) ?
              receipts[barcode.stock_master_id] += barcode.menge : receipts[barcode.stock_master_id] = barcode.menge

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

        receipts.keys.each do |key|
          barcode = barcodes.select { |b| b.stock_master_id == key }.first
          lgort   = case barcode.stock_master.werks
                      when '281A'
                        'EXFG'
                      when '381A'
                        'EBFG'
                      else
                        'FG01'
                    end
          SaprfcMb1b.create({
                                parent_id: barcode.stock_master_id,
                                matnr:     barcode.stock_master.matnr,
                                werks:     barcode.stock_master.werks,
                                lgort:     lgort,
                                old_lgort: barcode.lgort,
                                charg:     barcode.stock_master.charg,
                                bwart:     '311',
                                menge:     receipts[key],
                                status:    'wait',
                                creator:   current_user.email,
                                updater:   current_user.email
                            })
        end
      rescue Exception => e
        response = {
            barcode_uuid:  barcode_uuid,
            error_message: e.message
        }
      end
    end
    render json: response
  end

  def out

  end

  def out_scan
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

  def out_takeaway
    barcodes = Barcode.includes(:stock_master).joins(:stock_master)
                   .where(uuid: params[:uuid].split(','))

    response     = {
        barcode_out_uuid: 'success'
    }
    barcode_out_uuid = ''
    StockTran.transaction do
      begin
        barcodes.each { |barcode|
          barcode_out_uuid = barcode.uuid
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
                               mtype:       'out_takeway',
                               created_by:  current_user.email,
                               created_ip:  request.ip,
                               created_mac: '',
                               updated_by:  current_user.email,
                               updated_ip:  request.ip,
                               updated_mac: '',
                           })
          barcode.storage = ''
          barcode.status  = 'takeaway'
          barcode.menge   = 0
          barcode.save
        }
      rescue Exception => e
        response = {
            barcode_out_uuid:  barcode_out_uuid,
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

  def packing_box
    if params[:barcode].present?
      @barcode = Barcode.find_by_uuid(params[:barcode]) if params[:barcode].size == 32
      @barcode = Barcode.find_by_seq(params[:barcode]) if @barcode.blank?
    end
  end

  def printer_label
    barcode = Barcode.where(:uuid => params[:uuid]).first

    printer = Printer.find params[:printer_id]
    socket  = TCPSocket.new(printer.ip, printer.port)

    hash        = {
        :id          => barcode.id,
        :date        => barcode.stock_master.budat,
        :date_code   => barcode.stock_master.datecode,
        :lot_no      => barcode.stock_master.charg,
        :mo          => barcode.stock_master.aufnr,
        :qty         => barcode.menge,
        :product_no  => barcode.stock_master.matnr,
        :seq         => barcode.seq,
        :name        => barcode.name.blank? ? '' : barcode.name[0].upcase,
        :meins       => barcode.stock_master.meins,
        :seq_parent  => barcode.parent.present? ? barcode.parent.seq : '',
        :name_parent => barcode.parent.present? ? barcode.parent.name[0].upcase : '',
        :factory     => barcode.stock_master.werks
    }
    zpl_command = Barcode.finish_goods_label hash
    socket.write zpl_command
    socket.close
    redirect_to repeat_printer_barcodes_url
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
