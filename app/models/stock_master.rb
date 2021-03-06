class StockMaster < ActiveRecord::Base
  self.primary_key = :uuid
  has_many :barcodes, :class_name => 'Barcode', :dependent => :destroy

  def self.get_packaging(matnr, werks)
    return get_plm_packaging_v2(matnr, werks)
    # if box.present?
    #   return box, pallet
    # else
    #   return get_sap_pop3(matnr)
    # end
  end

  def self.get_plm_packaging(matnr, werks)
    # sql    = "
    #   select child_material_text,usage,(1/usage * 1000) qty,remarks,wom,grwt,ntwt,uom from it.pbomxtb
    #   where pmatnr=? and (child_material_text like 'CARTON%' or child_material_text like 'PALLET%')
    # "
    # rows   = Sapco.find_by_sql [sql, matnr]
    sql    = "
      select a.cmaktx child_material_text, a.potx1 remarks, a.meins uom,
             b.gewei wom, b.brgew grwt, b.ntgew ntwt
      from it.sbomxtb a
        join sapsr3.mara@sapp b on b.mandt='168' and b.matnr=a.cmatnr
      where a.pmatnr=? and a.werks=? and (a.cmaktx like 'CARTON%' or a.cmaktx like 'PALLET%')
    "
    rows   = Sapco.find_by_sql [sql, matnr, werks]
    pallet = {}
    box    = {}
    rows.each do |row|
      #寻找包装数量
      buf     = row.remarks.split('/')
      qty_str = ''
      if buf.size > 1
        buf.second.strip.each_char do |char|
          if char.numeric?
            qty_str = "#{qty_str}#{char}"
          else
            break
          end
        end
      end
      if qty_str.present?
        if row.child_material_text.include?('CARTON')
          box[:qty]    = qty_str.to_i if qty_str.to_i >= (box[:qty] || 0)
          box[:weight] = row.grwt
          box[:wuom]   = row.wom
        else
          pallet[:qty] = qty_str.to_i if qty_str.to_i <= (pallet[:qty] || qty_str.to_i)
          pallet[:uom] = row.wom
        end
      end #qty_str.present?
    end #rows

    if box.present?
      sql  = "select meins, brgew, ntgew, gewei from sapsr3.mara where mandt='168' and matnr=?"
      rows = Sapdb.find_by_sql [sql, matnr]
      rows.each do |row|
        box[:uom]   = row.meins
        box[:brgew] = row.brgew
        box[:ntgew] = row.ntgew
        box[:gewei] = row.gewei
      end
      if pallet.blank?
        pallet[:qty] = 20 * box[:qty]
        pallet[:uom] = 'ST'
      end
    end
    return box, pallet
  end

  def self.get_plm_packaging_v2(matnr, werks)
    # sql    = "
    #   select child_material_text,usage,(1/usage * 1000) qty,remarks,wom,grwt,ntwt,uom from it.pbomxtb
    #   where pmatnr=? and (child_material_text like 'CARTON%' or child_material_text like 'PALLET%')
    # "
    # rows   = Sapco.find_by_sql [sql, matnr]
    sql     = "
      select a.cmatnr,a.child_material_text, a.remarks
        from it.pbomxtb a
        where a.pmatnr=? and a.plant=? and a.cmatnr='2002013960000'
    "
    rows    = Sapco.find_by_sql [sql, matnr, werks]
    pallet  = {}
    box     = {}
    min_qty = 0
    max_qty = 0
    rows.each do |row|
      #寻找包装数量
      buf     = row.remarks.split('/')
      qty_str = ''
      if buf.size > 1
        buf.second.strip.each_char do |char|
          if char.numeric?
            qty_str = "#{qty_str}#{char}"
          else
            break
          end
        end
      end
      if qty_str.present?
        plm_qty = qty_str.to_i
        min_qty = plm_qty if (min_qty == 0 or min_qty >= plm_qty)
        max_qty = plm_qty if (max_qty == 0 or max_qty <= plm_qty)
      end
    end #rows
    if min_qty != 0
      box[:qty]    = min_qty
      box[:weight] = 0
      box[:wuom]   = 'EA'
      pallet[:qty] = max_qty
      pallet[:uom] = 'ST'
    end
    return box, pallet
  end


  def self.get_sap_pop3(matnr)
    sql          = "
      select e.packnr, e.pobjid,f.paitemtype,f.matnr,f.subpacknr,f.trgqty,f.baseunit,g.brgew,g.ntgew,g.gewei
      from sapsr3.packkp e
        join sapsr3.packpo f on f.mandt=e.mandt and f.packnr=e.packnr and f.inddel <> 'X'
        left join sapsr3.mara g on g.mandt=f.mandt and g.matnr=f.matnr,
        (
          select e.packnr
          from sapsr3.packkp e
            join sapsr3.packpo f on f.mandt=e.mandt and f.packnr=e.packnr and f.inddel <> 'X'
          where e.mandt='168' and e.pobjid like '#{matnr}%' and f.matnr='#{matnr}' and e.pobjid <> f.matnr
        ) v
      where e.packnr = v.packnr or f.subpacknr = v.packnr and e.pobjid like '#{matnr}%'
    "
    pallet       = {}
    box          = {}
    list         = Sapdb.find_by_sql sql
    pallet[:qty] = 20
    pallet[:uom] = 'ST'
    pallet_found = false

    list.select { |b| b.subpacknr.present? and (b.pobjid[(b.pobjid.size - 3)..(b.pobjid.size)] == 'PAL') }.each do |row|
      pallet[:qty] = row.trgqty
      pallet[:uom] = row.baseunit
      pallet_found = true
    end

    if not pallet_found
      list.select { |b| b.subpacknr.present? and (b.pobjid[(b.pobjid.size - 3)..(b.pobjid.size)] == 'PAQ') }.each do |row|
        pallet[:qty] = row.trgqty
        pallet[:uom] = row.baseunit
        pallet_found = true
      end
    end

    if not pallet_found
      list.select { |b| b.subpacknr.present? and (b.pobjid[(b.pobjid.size - 2)..(b.pobjid.size)] == 'PA') }.each do |row|
        pallet[:qty] = row.trgqty
        pallet[:uom] = row.baseunit
        pallet_found = true
      end
    end

    list.each do |row|
      if row.matnr == matnr
        box[:qty]   = row.trgqty
        box[:uom]   = row.baseunit
        box[:brgew] = row.brgew
        box[:ntgew] = row.ntgew
        box[:gewei] = row.gewei
      elsif row.matnr[0..2] == 'BOX'
        box[:weight] = row.brgew
        box[:wuom]   = row.gewei
        # elsif row.subpacknr != ' '
        #   pallet[:qty] = row.trgqty
        #   pallet[:uom] = row.baseunit
      end
    end

    return box, pallet
  end


  def self.get_label_info(rowid)

    list = Sapdb.find_by_sql [SQL_MKPF, rowid]

    records = []

    list.each do |row|
      record         = {}
      record[:rowid] = rowid
      record[:mblnr] = row.mblnr
      record[:mjahr] = row.mjahr
      record[:zeile] = row.zeile
      record[:budat] = row.budat
      record[:cputm] = row.cputm
      record[:usnam] = row.usnam
      record[:matnr] = row.matnr
      record[:maktx] = row.maktx
      record[:werks] = row.werks
      record[:lgort] = row.lgort
      record[:charg] = row.charg
      record[:atwrt] = row.atwrt
      record[:menge] = row.menge
      record[:meins] = row.meins
      record[:aufnr] = row.aufnr
      record[:psmng] = row.psmng
      record[:wemng] = row.wemng

      box, pallet            = get_packaging(row.matnr, row.werks)

      # puts "$$$$$$$$$$$$"
      # puts pallet[:qty]
      # puts "$$$$$$$$$$$$"

      box[:qty]              = row.menge if box[:qty].nil?
      no_of_box              = (row.menge.to_f / box[:qty].to_f).ceil
      no_of_box1             = (row.menge.to_f / box[:qty].to_f).to_i
      no_of_box2             = no_of_box - no_of_box1


      pallet[:qty]           = no_of_box if pallet[:qty].blank?
      no_of_pallet           = (row.menge.to_f / pallet[:qty].to_f).ceil #向上取整數
      no_of_pallet1          = (row.menge.to_f / pallet[:qty].to_f).to_i #取整數不作4捨五入
      no_of_pallet2          = no_of_pallet - no_of_pallet1

      # puts "!!!!!!!!!!!!!!!!!!!"
      # puts pallet[:qty]
      # puts row.menge
      # puts no_of_pallet
      # puts no_of_pallet1
      # puts no_of_pallet2
      # puts "!!!!!!!!!!!!!!!!!!!"

      record[:box_qty]       = box[:qty]
      record[:box_qty2]      = row.menge - (no_of_box1 * box[:qty])
      record[:pallet_qty]    = pallet[:qty]
      record[:pallet_qty2]   = row.menge - (no_of_pallet1 * pallet[:qty])
      record[:no_of_box1]    = no_of_box1
      record[:no_of_box2]    = no_of_box2
      record[:no_of_pallet1] = no_of_pallet1
      record[:no_of_pallet2] = no_of_pallet2
      records << record
    end
    records.first
  end


  def self.print_box_label(params)
    record       = (Sapdb.find_by_sql [SQL_MKPF, params[:id]]).first
    stock_master = StockMaster.where(:mjahr => record.mjahr).where(:mblnr => record.mblnr).first || create_label_v2(params, record)

    printer = Printer.find params[:printer_id]
    socket  = TCPSocket.new(printer.ip, printer.port)

    list = stock_master.barcodes
    i    = 0
    list.each do |barcode|
      parent_seq = ''
      parent_seq = barcode.parent.seq if barcode.parent.present?
      parent_name = ''
      parent_name = barcode.parent.name[0].upcase if barcode.parent.present?
      i           = i + 1
      hash        = {
          :id          => barcode.id,
          :date        => stock_master.budat,
          :date_code   => stock_master.datecode,
          :lot_no      => stock_master.charg,
          :mo          => stock_master.aufnr,
          :qty         => barcode.menge,
          :product_no  => stock_master.matnr,
          :seq         => barcode.seq,
          :name        => barcode.name.blank? ? '' : barcode.name[0].upcase,
          :meins       => stock_master.meins,
          :seq_parent  => (barcode.parent_id != 0 && barcode.name[0].upcase.eql?('B')) ? parent_seq : '',
          :name_parent => (barcode.parent_id != 0 && barcode.name[0].upcase.eql?('P')) ? 'P' : parent_name,
          :factory     => stock_master.werks,
          :xb          => list.size == i ? '' : '^XB'
      }
      zpl_command = Barcode.finish_goods_label hash
      socket.write zpl_command
    end

    socket.close

    sup_code = ''
    if stock_master.matnr[stock_master.matnr.length-3,stock_master.matnr.length] == 'LEI' || stock_master.matnr[stock_master.matnr.length-3,stock_master.matnr.length] == 'LB'
      list.each do |brcode|
        if stock_master.werks == '381A' or stock_master.werks == '382A'
          sup_code = 'L300'
        elsif stock_master.werks == '481A' or stock_master.werks == '482A'
          sup_code = 'L400'
        elsif stock_master.werks == '281A' or stock_master.werks == '282A'
          sup_code = 'L210'
        elsif stock_master.werks == '111A'
          sup_code = 'L111'
        end
        begin
          MesTErpPoItem.create(po_number: "#{stock_master.mjahr}.#{stock_master.mblnr}", item_code: stock_master.matnr, item_line: '00010', item_num: brcode.menge, item_lot: stock_master.charg, item_sn: brcode.id, item_sn_qty: brcode.menge, receive_type: brcode.menge, supplier_code: sup_code, supplier_lot: stock_master.charg, supplier_date: stock_master.budat, plant: stock_master.werks, supplier_dn: stock_master.aufnr, has_label: 1)
        rescue

        end

      end
    end

  end

  private

  def self.create_label_v2(params, record)

    StockMaster.transaction do
      stock_master    = StockMaster.create(
          :matnr      => record.matnr,
          :maktx      => record.maktx,
          :matkl      => record.matkl,
          :charg      => record.charg,
          :menge      => record.menge,
          :box_cnt    => params[:no_of_box1].to_i + params[:no_of_box2].to_i,
          :pallet_cnt => params[:no_of_pallet1].to_i + params[:no_of_pallet2].to_i,
          :werks      => record.werks,
          :meins      => record.meins,
          :mjahr      => record.mjahr,
          :mblnr      => record.mblnr,
          :zeile      => record.zeile,
          :aufnr      => record.aufnr,
          :datecode   => record.atwrt,
          :budat      => record.budat,
      )
      wt_pallet_qty   = record.menge #4020
      wt_carton_qty   = record.menge #4020
      carton_qty      = params[:box_qty].to_i #60
      full_pallet_qty = params[:pallet_qty].to_i #1200

      while wt_pallet_qty > 0
        if carton_qty != full_pallet_qty
          pallet = Barcode.create(
              :stock_master_id => stock_master.id,
              :name            => 'pallet',
              :parent_id       => 0,
              :child           => true,
              :lgort           => record.lgort,
              :status          => 'created',
              :menge           => 0)
        end
        ws_carton_qty = 0
        while wt_carton_qty > 0
          if wt_carton_qty >= carton_qty #如果carton余量 >=  整箱数,箱子数量为整箱的数量
            Barcode.create(
                :stock_master_id => stock_master.id,
                :name            => 'box',
                :parent_id       => pallet.present? ? pallet.id : 0,
                :child           => true,
                :lgort           => record.lgort,
                :status          => 'created',
                :menge           => carton_qty
            )
            wt_carton_qty = wt_carton_qty - carton_qty
            wt_pallet_qty = wt_pallet_qty - carton_qty
            ws_carton_qty = ws_carton_qty + carton_qty
            break if ws_carton_qty >= full_pallet_qty
          else
            Barcode.create(
                :stock_master_id => stock_master.id,
                :name            => 'box',
                :parent_id       => pallet.present? ? pallet.id : 0,
                :child           => true,
                :lgort           => record.lgort,
                :status          => 'created',
                :menge           => wt_carton_qty
            )
            wt_pallet_qty = wt_pallet_qty - wt_carton_qty
            wt_carton_qty = wt_carton_qty - wt_carton_qty
            break
          end
        end
      end
      return stock_master
    end
  end

  def self.create_label(params, record)

    StockMaster.transaction do
      stock_master = StockMaster.create(
          :matnr      => record.matnr,
          :maktx      => record.maktx,
          :matkl      => record.matkl,
          :charg      => record.charg,
          :menge      => record.menge,
          :box_cnt    => params[:no_of_box1].to_i + params[:no_of_box2].to_i,
          :pallet_cnt => params[:no_of_pallet1].to_i + params[:no_of_pallet2].to_i,
          :werks      => record.werks,
          :meins      => record.meins,
          :mjahr      => record.mjahr,
          :mblnr      => record.mblnr,
          :zeile      => record.zeile,
          :aufnr      => record.aufnr,
          :datecode   => record.atwrt,
          :budat      => record.budat,
      )

      #这是正常的
      pallet       = Barcode.new
      no_of_box1   = 0
      (1..params[:no_of_pallet1].to_i).each do |i|
        pallet = Barcode.create(
            :stock_master_id => stock_master.id,
            :name            => 'pallet',
            :parent_id       => 0,
            :child           => true,
            :lgort           => record.lgort,
            :status          => 'created',
            :menge           => 0
        )
        (1..(params[:pallet_qty].to_i / params[:box_qty].to_i)).each do |i|
          no_of_box1 += 1
          Barcode.create(
              :stock_master_id => stock_master.id,
              :name            => 'box',
              :parent_id       => pallet.id,
              :child           => true,
              :lgort           => record.lgort,
              :status          => 'created',
              :menge           => params[:box_qty].to_i
          ) if stock_master.menge >= params[:box_qty].to_i
          break if no_of_box1 == params[:no_of_box1].to_i
        end
      end

      #这是代表还有一些箱子么有被打印出来, 或者还有尾数栈板
      if params[:no_of_box2].to_i > 0
        #这是代表没有尾数栈板
        if params[:pallet_qty2].to_i == 0
          #打印箱标签
          (1..params[:no_of_box2].to_i).each do |i|
            #检查最后一箱是否是尾箱还是整箱
            if (i == params[:no_of_box2].to_i) and (params[:box_qty2].to_i != 0)
              Barcode.create(
                  :stock_master_id => stock_master.id,
                  :name            => 'box',
                  :parent_id       => pallet.id,
                  :child           => true,
                  :lgort           => record.lgort,
                  :status          => 'created',
                  :menge           => params[:box_qty2].to_i
              )
            else
              Barcode.create(
                  :stock_master_id => stock_master.id,
                  :name            => 'box',
                  :parent_id       => pallet.id,
                  :child           => true,
                  :lgort           => record.lgort,
                  :status          => 'created',
                  :menge           => params[:box_qty].to_i
              )
            end
          end
        end
      end

      #还有放不下的箱子, 那就是要加一个栈板标签
      if params[:pallet_qty2].to_i > 0
        pallet = Barcode.create(
            :stock_master_id => stock_master.id,
            :name            => 'pallet',
            :parent_id       => 0,
            :child           => true,
            :lgort           => record.lgort,
            :status          => 'created',
            :menge           => 0
        )
      end
      (1..(params[:pallet_qty2].to_i / params[:box_qty].to_i).ceil).each do |i|
        #检查最后一箱是否是尾箱还是整箱
        if (i == (params[:pallet_qty2].to_i / params[:box_qty].to_i).ceil) and (params[:box_qty2].to_i != 0)
          Barcode.create(
              :stock_master_id => stock_master.id,
              :name            => 'box',
              :parent_id       => pallet.id,
              :child           => true,
              :lgort           => record.lgort,
              :status          => 'created',
              :menge           => params[:box_qty2].to_i
          )
        else
          Barcode.create(
              :stock_master_id => stock_master.id,
              :name            => 'box',
              :parent_id       => pallet.id,
              :child           => true,
              :lgort           => record.lgort,
              :status          => 'created',
              :menge           => params[:box_qty].to_i
          )
        end
      end
      return stock_master
    end
  end


  SQL_MKPF = "
      select
        a.mblnr,a.mjahr,b.zeile,a.budat,a.cputm,a.usnam,
        b.matnr,d.maktx,b.werks,b.lgort,b.charg,f.atwrt,b.menge,b.meins,
        b.aufnr,g.psmng,g.wemng,c.matkl
      from sapsr3.mkpf a
        join sapsr3.mseg b on b.mandt=a.mandt and b.mblnr=a.mblnr and b.aufnr <> ' '
        join sapsr3.mara c on c.mandt=b.mandt and c.matnr=b.matnr
        join sapsr3.makt d on d.mandt=c.mandt and d.matnr=c.matnr and d.spras='M'
        join sapsr3.mch1 e on e.mandt=b.mandt and e.matnr=b.matnr and e.charg=b.charg
        join sapsr3.ausp f on f.mandt=e.mandt and f.objek=e.cuobj_bm and f.atinn='0000000816' and f.klart='023'
        join sapsr3.afpo g on g.mandt=b.mandt and g.aufnr=b.aufnr
      where a.mandt='168' and a.rowid=?  and rownum=1
 "


end
