# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do


  #create_table "shopping_carts", :force => true do |t|
  #  t.integer  "email_id"
  #  t.string   "tracking"
  #  t.datetime "created_at"
  #  t.datetime "updated_at"
  #end
  factory :shopping_cart, class: 'Shopping::Cart', aliases: [:cart] do
    tracking nil

    ignore do
      items_count 1
    end

    before :create do |cart, evaluator|
      puts "carts: create items_count:#{evaluator.items_count} cart.id:#{cart.new_record?}BEGIN"
      FactoryGirl.create_list :shopping_item, evaluator.items_count, cart: cart
      #puts "carts: create items list:#{d.inspect}END"
    end

    trait :with_address do
      before :create do |cart, evaluator|
        puts "with_address before::create"
        FactoryGirl.create(:address, cart: cart)
      end
    end

    trait :with_purchase do

      before :create do |cart, evaluator|
        puts "carts: with_purchase before_create"
        puts "carts: items:#{cart.items.inspect}"
        puts "carts: address:#{cart.address.inspect}"
        cart.address = FactoryGirl.create(:address, cart: cart) if cart.address.nil?
        puts "carts: create=>#{cart}"
      end

      after :create do |cart, evaluator|
        cart.items.reload
        raise "missing address" if cart.address.nil?
        raise "missing cart items" if cart.items.size < 1
        puts "carts: after create address=>#{cart.address}"
        puts "carts: after create purchase=>#{cart.purchase}"
        FactoryGirl.create(:purchase, cart: cart)
        puts "carts: after create build purchase=>#{cart.purchase.errors.full_messages}"
        cart.save!
      end
    end

    trait :with_shipping do
      before :create do |cart, evaluator|
        puts "with_shipping before:create BEGIN"
        FactoryGirl.create(:shipping, cart: cart)
        puts "with_shipping before:create END"
      end
    end

  end
end
