Rails.application.routes.draw do

  resources :enquiries do
    get :matnr_onhand, on: :collection
    get :storage_onhand, on: :collection
    get :not_putaway, on: :collection
  end

  resources :printers

  resources :barcodes do
    get :scan, on: :collection
    get :unlink_pallet, on: :member
    get :in, on: :collection
    get :in_scan, on: :collection
    post :in_putaway, on: :collection
    get :repeat_printer, on: :collection
    get :printer_label, on: :collection
    get :out, on: :collection
    get :out_scan, on: :collection
    post :out_takeaway, on: :collection
    get :split_box, on: :collection
    get :unlink_box, on: :member
  end

  resources :stock_masters
  resources :stock_trans do
    get :in, :on => :collection
    get :in_scan, :on => :collection
    get :out, :on => :collection
  end

  resources :work_orders do
    get :receipt, :on => :collection
    get :confirm_box_label, :on => :member
    post :print_box_label, :on => :member
    get :stock_in_label, :on => :member
  end

  root to: 'visitors#index' #首頁

  devise_for :users

  resources :users do
    get :autocomplete_user_email, :on => :collection
  end

end
