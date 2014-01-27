require 'test_helper'

class NameDeviationsControllerTest < ActionController::TestCase
  setup do
    @name_deviation = name_deviations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_deviations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_deviation" do
    assert_difference('NameDeviation.count') do
      post :create, name_deviation: { enabled: @name_deviation.enabled, episode_number: @name_deviation.episode_number, season_number: @name_deviation.season_number, tvshow_id: @name_deviation.tvshow_id, tvshow_title: @name_deviation.tvshow_title, type: @name_deviation.type }
    end

    assert_redirected_to name_deviation_path(assigns(:name_deviation))
  end

  test "should show name_deviation" do
    get :show, id: @name_deviation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @name_deviation
    assert_response :success
  end

  test "should update name_deviation" do
    put :update, id: @name_deviation, name_deviation: { enabled: @name_deviation.enabled, episode_number: @name_deviation.episode_number, season_number: @name_deviation.season_number, tvshow_id: @name_deviation.tvshow_id, tvshow_title: @name_deviation.tvshow_title, type: @name_deviation.type }
    assert_redirected_to name_deviation_path(assigns(:name_deviation))
  end

  test "should destroy name_deviation" do
    assert_difference('NameDeviation.count', -1) do
      delete :destroy, id: @name_deviation
    end

    assert_redirected_to name_deviations_path
  end
end
