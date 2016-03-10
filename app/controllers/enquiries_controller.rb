class EnquiriesController < ApplicationController

  def matnr_onhand
    if params[:matnr]
      sql       = "
        select a.matnr,a.maktx,a.matkl,a.charg,a.werks,a.meins,a.aufnr,a.datecode,a.budat,
               b.uuid,b.name,b.menge,a.werks ||'-'|| nvl(b.storage,b.lgort)storage,b.status,b.seq
          from stock_master a
            join barcode b on b.stock_master_id = a.uuid and b.status <> 'stock_out'
            where a.matnr = ? and a.werks like '%#{params[:werks].upcase}%'
      "
      @barcodes = StockMaster.find_by_sql [sql, params[:matnr].upcase]

      menge      = 0
      pallet_cnt = 0
      box_cnt    = 0
      storages   = {}
      @barcodes.each { |barcode|
        menge += barcode.menge
        barcode.name == 'box' ? box_cnt += 1 : pallet_cnt += 1
        storages[barcode.storage] = [0,0,0] unless storages.key?(barcode.storage)
        storages[barcode.storage][0] += barcode.menge
        barcode.name == 'box' ? storages[barcode.storage][1] += 1 : storages[barcode.storage][2] += 1
      }
      @htable = {
          menge:      menge,
          pallet_cnt: pallet_cnt,
          box_cnt:    box_cnt,
          storages:   storages
      }
    end
  end

  def storage_onhand
    if params[:storage]
      sql       = "
        select a.matnr,a.maktx,a.matkl,a.charg,a.werks,a.meins,a.aufnr,a.datecode,a.budat,
               b.uuid,b.name,b.menge,a.werks ||'-'|| nvl(b.storage,b.lgort)storage,b.status,b.seq
          from stock_master a
            join barcode b on b.stock_master_id = a.uuid and b.status <> 'stock_out'
            where b.storage = ? and a.werks like '%#{params[:werks].upcase}%'
      "
      @barcodes = StockMaster.find_by_sql [sql, params[:storage].upcase]

      @storages   = {}
      @barcodes.each { |barcode|
        storage_matnr = "#{barcode.storage}_#{barcode.matnr}"
        @storages[storage_matnr] = [0,0,0,barcode.meins] unless @storages.key?(storage_matnr)
        @storages[storage_matnr][0] += barcode.menge
        barcode.name == 'box' ? @storages[storage_matnr][1] += 1 : @storages[storage_matnr][2] += 1
      }
    end
  end

  def not_putaway
    if params[:werks]
      sql       = "
        select a.matnr,a.maktx,a.matkl,a.charg,a.werks,a.meins,a.aufnr,a.datecode,a.budat,
               b.uuid,b.name,b.menge,nvl(b.storage,b.lgort)storage,b.status,b.seq
          from stock_master a
            join barcode b on b.stock_master_id = a.uuid and b.status <> 'stock_out' and b.storage is null
            where a.werks = ? and a.matnr like '%#{params[:matnr].upcase}%'
      "
      @barcodes = StockMaster.find_by_sql [sql, params[:werks].upcase]
      @storages   = {}
      @barcodes.each { |barcode|
        @storages[barcode.matnr] = [0,0,0,barcode.meins] unless @storages.key?(barcode.matnr)
        @storages[barcode.matnr][0] += barcode.menge
        barcode.name == 'box' ? @storages[barcode.matnr][1] += 1 : @storages[barcode.matnr][2] += 1
      }
    end
  end

end
