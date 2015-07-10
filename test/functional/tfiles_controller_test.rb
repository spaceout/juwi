require 'test_helper'

class TfilesControllerTest < ActionController::TestCase
  setup do
    @tfile = tfiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tfiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tfile" do
    assert_difference('Tfile.count') do
      post :create, tfile: { bytes_completed: @tfile.bytes_completed, length: @tfile.length, name: @tfile.name, rename_data: @tfile.rename_data, rename_status: @tfile.rename_status }
    end

    assert_redirected_to tfile_path(assigns(:tfile))
  end

  test "should show tfile" do
    get :show, id: @tfile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tfile
    assert_response :success
  end

  test "should update tfile" do
    put :update, id: @tfile, tfile: { bytes_completed: @tfile.bytes_completed, length: @tfile.length, name: @tfile.name, rename_data: @tfile.rename_data, rename_status: @tfile.rename_status }
    assert_redirected_to tfile_path(assigns(:tfile))
  end

  test "should destroy tfile" do
    assert_difference('Tfile.count', -1) do
      delete :destroy, id: @tfile
    end

    assert_redirected_to tfiles_path
  end
end
