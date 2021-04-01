defmodule FgHttpWeb.AccountLive.ShowTest do
  use FgHttpWeb.ConnCase, async: true

  alias FgHttp.Users.User
  alias FgHttpWeb.AccountLive.FormComponent

  describe "when unauthenticated" do
    test "mount redirects to session path", %{unauthed_conn: conn} do
      path = Routes.account_show_path(conn, :show)
      {:error, {:redirect, %{to: "/sign_in"}}} = live(conn, path)
    end
  end

  describe "when live_action is show" do
    test "shows account details", %{authed_conn: conn} do
      path = Routes.account_show_path(conn, :show)
      {:ok, _view, html} = live(conn, path)

      assert html =~ "<h3 class=\"title\">Your Account</h3>"
      assert html =~ "test@test"
    end
  end

  describe "when live_action is edit" do
    @valid_params %{"user" => %{"email" => "foobar@test"}}
    @invalid_params %{"user" => %{"email" => "foobar"}}

    test "loads the form" do
      assert render_component(FormComponent, id: :test, user: %User{}) =~
               "Change email or enter new password below"
    end

    test "saves email when submitted", %{authed_conn: conn} do
      path = Routes.account_show_path(conn, :edit)
      {:ok, view, _html} = live(conn, path)

      view
      |> element("#account-edit")
      |> render_submit(@valid_params)

      flash = assert_redirected(view, Routes.account_show_path(conn, :show))
      assert flash["info"] == "Account updated successfully."
    end

    test "renders validation errors", %{authed_conn: conn} do
      path = Routes.account_show_path(conn, :edit)
      {:ok, view, _html} = live(conn, path)

      test_view =
        view
        |> element("#account-edit")
        |> render_submit(@invalid_params)

      assert test_view =~ "has invalid format"
    end
  end
end
