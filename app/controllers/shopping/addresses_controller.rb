module Shopping
  class AddressesController < BaseController

    belongs_to :cart,
               parent_class: Shopping::Cart,
               singleton:    true,
               finder: :find_by_tracking

    def new
      @states = State.form_selector
      @storyline.describe 'Entering new address.'
      new! do
        return render("new#{@shopping_layout}")
      end
    end

    def create
      create! do
        if @address.errors.present?
          @states = State.form_selector
          @storyline.describe "Error in creating new address: #{@address.errors.full_messages}"
          return render()
        else
          @storyline.describe 'Created new address.'
          if @cart.shipping
            edit_shopping_cart_shipping_path(@cart, @cart.shipping)
          else
            new_shopping_cart_shipping_path(@cart)
          end
        end
      end
    end

    def edit
      @storyline.describe 'Editing the address.'
      @states = State.form_selector
      edit! do
        return render("edit#{@shopping_layout}")
      end
    end

    def update
      update! do
        if @address.errors.present?
          @states = State.form_selector
          @storyline.describe "Error in updating new address: #{@address.errors.full_messages}"
          return render("edit#{@shopping_layout}")
        else
          @storyline.describe 'Updated the address.'
          if @cart.shipping
            edit_shopping_cart_shipping_path(@cart, @cart.shipping)
          else
            new_shopping_cart_shipping_path(@cart)
          end
        end
      end
    end

  end
end