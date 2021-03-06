defmodule FslcWeb.Router do
  use FslcWeb, :router

  import FslcWeb.UserAuth

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_user_token
    plug NavigationHistory.Tracker, excluded_paths: ["/login", ~r(/admin.*)]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FslcWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/uploads", UploadController, only: [:new, :create, :delete, :edit, :update]
    resources "/rices", RiceController, only: [:new, :create, :delete, :edit, :update]
  end

  scope "/", FslcWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/license", PageController, :license
    get "/disclaimer", PageController, :disclaimer
    get "/credits", PageController, :credits
    get "/guidelines", PageController, :guidelines

    get "/stream/authenticate", LivestreamController, :authenticate

    get "/users/pages", UserPageController, :index
    get "/users/pages/:username", UserPageController, :user

    resources "/rices", RiceController, only: [:index, :show] 
    resources "/uploads", UploadController, only: [:index, :show]
  end


  scope "/stream", FslcWeb do
    # Has its own scope because nginx does some stuff on this route
    pipe_through [:browser, :require_authenticated_user]

    get "/", LivestreamController, :index
  end

  scope "/admin", FslcWeb do
    pipe_through [:browser, :require_admin_user]

    get "/", AdminController, :index
    post "/stream/start", LivestreamController, :create
  	resources "/announcements", AnnouncementController

    get "/user-page-tokens/validate", UserPageController, :validate_user_page_form
    post "/user-page-tokens/validate", UserPageController, :validate_user_page_confirm
    get "/user-page-tokens/create", UserPageController, :create_user_token
    post "/user-page-tokens/submit", UserPageController, :submit_user_page_confirm

    get "/uploads", UploadController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", FslcWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FslcWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", FslcWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", FslcWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", FslcWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
