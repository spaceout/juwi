require 'test_helper'

class TvshowsControllerTest < ActionController::TestCase
  setup do
    @tvshow = tvshows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tvshows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tvshow" do
    assert_difference('Tvshow.count') do
      post :create, tvshow: {  }
    end

    assert_redirected_to tvshow_path(assigns(:tvshow))
  end

  test "should show tvshow" do
    get :show, id: @tvshow
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tvshow
    assert_response :success
  end

  test "should update tvshow" do
    put :update, id: @tvshow, tvshow: {  }
    assert_redirected_to tvshow_path(assigns(:tvshow))
  end

  test "should destroy tvshow" do
    assert_difference('Tvshow.count', -1) do
      delete :destroy, id: @tvshow
    end

    assert_redirected_to tvshows_path
  end
end
