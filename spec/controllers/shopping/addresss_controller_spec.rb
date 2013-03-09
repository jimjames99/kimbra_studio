#require 'spec_helper'
#
describe Shopping::AddressesController do

  # This should return the minimal set of attributes required to create a valid
  # Admin::Customer::Friend. As you add validations to Admin::Customer::Friend, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::Customer::FriendsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe 'GET index' do
    it 'assigns all admin_customer_friends as @admin_customer_friends' do
      friend = Admin::Customer::Friend.create! valid_attributes
      get :index, {}, valid_session
      assigns(:admin_customer_friends).should eq([friend])
    end
  end

  describe 'GET show' do
    it 'assigns the requested friend as @friend' do
      friend = Admin::Customer::Friend.create! valid_attributes
      get :show, {:id => friend.to_param}, valid_session
      assigns(:friend).should eq(friend)
    end
  end

  describe 'GET new' do
    it 'assigns a new friend as @friend' do
      get :new, {}, valid_session
      assigns(:friend).should be_a_new(Admin::Customer::Friend)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested friend as @friend' do
      friend = Admin::Customer::Friend.create! valid_attributes
      get :edit, {:id => friend.to_param}, valid_session
      assigns(:friend).should eq(friend)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Admin::Customer::Friend' do
        expect {
          post :create, {:friend => valid_attributes}, valid_session
        }.to change(Admin::Customer::Friend, :count).by(1)
      end

      it 'assigns a newly created friend as @friend' do
        post :create, {:friend => valid_attributes}, valid_session
        assigns(:friend).should be_a(Admin::Customer::Friend)
        assigns(:friend).should be_persisted
      end

      it 'redirects to the created friend' do
        post :create, {:friend => valid_attributes}, valid_session
        response.should redirect_to(Admin::Customer::Friend.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved friend as @friend' do
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::Customer::Friend.any_instance.stub(:save).and_return(false)
        post :create, {:friend => {}}, valid_session
        assigns(:friend).should be_a_new(Admin::Customer::Friend)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::Customer::Friend.any_instance.stub(:save).and_return(false)
        post :create, {:friend => {}}, valid_session
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested friend' do
        friend = Admin::Customer::Friend.create! valid_attributes
        # Assuming there are no other admin_customer_friends in the database, this
        # specifies that the Admin::Customer::Friend created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Admin::Customer::Friend.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => friend.to_param, :friend => {'these' => 'params'}}, valid_session
      end

      it 'assigns the requested friend as @friend' do
        friend = Admin::Customer::Friend.create! valid_attributes
        put :update, {:id => friend.to_param, :friend => valid_attributes}, valid_session
        assigns(:friend).should eq(friend)
      end

      it 'redirects to the friend' do
        friend = Admin::Customer::Friend.create! valid_attributes
        put :update, {:id => friend.to_param, :friend => valid_attributes}, valid_session
        response.should redirect_to(friend)
      end
    end

    describe 'with invalid params' do
      it 'assigns the friend as @friend' do
        friend = Admin::Customer::Friend.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::Customer::Friend.any_instance.stub(:save).and_return(false)
        put :update, {:id => friend.to_param, :friend => {}}, valid_session
        assigns(:friend).should eq(friend)
      end

      it "re-renders the 'edit' template" do
        friend = Admin::Customer::Friend.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Admin::Customer::Friend.any_instance.stub(:save).and_return(false)
        put :update, {:id => friend.to_param, :friend => {}}, valid_session
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested friend' do
      friend = Admin::Customer::Friend.create! valid_attributes
      expect {
        delete :destroy, {:id => friend.to_param}, valid_session
      }.to change(Admin::Customer::Friend, :count).by(-1)
    end

    it 'redirects to the admin_customer_friends list' do
      friend = Admin::Customer::Friend.create! valid_attributes
      delete :destroy, {:id => friend.to_param}, valid_session
      response.should redirect_to(admin_customer_friends_url)
    end
  end

end
