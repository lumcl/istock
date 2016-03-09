class WorkOrdersController < ApplicationController

  def receipt
    budat = params[:budat] || Time.now.strftime('%Y%m%d')
    usnam = params[:usnam] || ''
    werks = params[:werks] || ''
    matnr = params[:matnr] || ''
    aufnr = params[:aufnr] || ''

    if current_user.territory == 'TX'
      t_werks = "and werks in (#{Figaro.env.tx_sql_werks})"
    elsif current_user.territory == 'DT'
      t_werks = "and werks in (#{Figaro.env.dt_sql_werks})"
    end

    sql = "
      select a.rowid,
        a.mblnr,a.mjahr,b.zeile,a.budat,a.cputm,a.usnam,
        b.matnr,d.maktx,b.werks,b.lgort,b.charg,f.atwrt,b.menge,b.meins,
        b.aufnr
      from sapsr3.mkpf a
        join sapsr3.mseg b on b.mandt=a.mandt and b.mblnr=a.mblnr and b.aufnr <> ' '
        join sapsr3.mara c on c.mandt=b.mandt and c.matnr=b.matnr
        join sapsr3.makt d on d.mandt=c.mandt and d.matnr=c.matnr and d.spras='M'
        join sapsr3.mch1 e on e.mandt=b.mandt and e.matnr=b.matnr and e.charg=b.charg
        join sapsr3.ausp f on f.mandt=e.mandt and f.objek=e.cuobj_bm and f.atinn='0000000816' and f.klart='023'
      where a.mandt='168' and a.vgart = 'WR' and a.budat = '#{budat}'
        and usnam like '%#{usnam}%' and werks like '%#{werks}%' and matnr like '%#{matnr}%'
        and aufnr like '%#{aufnr}%'
        #{t_werks}
      order by mjahr desc, mblnr desc
    "
    @list = Sapdb.find_by_sql sql

  end

  def confirm_box_label
    @record = StockMaster.get_label_info params[:id]
  end

  def print_box_label
    StockMaster.print_box_label(params)
    redirect_to receipt_work_orders_path
  end

  def stock_in_label
    #redirect_to new_stock_tran_path
    redirect_to stock_in_stock_tran_path
  end
end
