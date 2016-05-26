class SaprfcVl02sController < ApplicationController
  before_action :set_saprfc_vl02, only: [:show, :edit, :update, :destroy]

  # GET /saprfc_vl02s
  # GET /saprfc_vl02s.json
  def index
    @saprfc_vl02s = SaprfcVl02.all
  end

  # GET /saprfc_vl02s/1
  # GET /saprfc_vl02s/1.json
  def show
  end

  # GET /saprfc_vl02s/new
  def new
    @saprfc_vl02 = SaprfcVl02.new
  end

  # GET /saprfc_vl02s/1/edit
  def edit
  end

  # POST /saprfc_vl02s
  # POST /saprfc_vl02s.json
  def create
    @saprfc_vl02 = SaprfcVl02.new(saprfc_vl02_params)

    respond_to do |format|
      if @saprfc_vl02.save
        format.html { redirect_to @saprfc_vl02, notice: 'Saprfc vl02 was successfully created.' }
        format.json { render :show, status: :created, location: @saprfc_vl02 }
      else
        format.html { render :new }
        format.json { render json: @saprfc_vl02.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saprfc_vl02s/1
  # PATCH/PUT /saprfc_vl02s/1.json
  def update
    respond_to do |format|
      if @saprfc_vl02.update(saprfc_vl02_params)
        format.html { redirect_to @saprfc_vl02, notice: 'Saprfc vl02 was successfully updated.' }
        format.json { render :show, status: :ok, location: @saprfc_vl02 }
      else
        format.html { render :edit }
        format.json { render json: @saprfc_vl02.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /saprfc_vl02s/1
  # DELETE /saprfc_vl02s/1.json
  def destroy
    @saprfc_vl02.destroy
    respond_to do |format|
      format.html { redirect_to saprfc_vl02s_url, notice: 'Saprfc vl02 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def scan_dn

  end

  def dn_scan
    rows    = []
      sql  = "
          select vbeln,posnr,matnr,lfimg,meins,werks
            from sapsr3.lips@sapp
            where mandt='168' and vbeln = ?
        "
      rows = Barcode.find_by_sql [sql, params[:barcode]]
    render json: rows
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_saprfc_vl02
      @saprfc_vl02 = SaprfcVl02.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saprfc_vl02_params
      params.require(:saprfc_vl02).permit(:VBELN, :POSNR, :MATNR, :CHARG, :MENGE, :MEINS, :WERKS, :LGORT, :MSG_TYPE, :MSG_ID, :MSG_NUMBER, :MSG_TEXT, :RFC_DATE, :STATUS, :MJAHR, :MBLNR, :ZEILE, :CREATOR, :UPDATER, :CREATED_AT, :UPDATED_AT, :BARCODE_ID)
    end
end
