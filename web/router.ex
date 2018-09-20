defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    # function plugs
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # # #

    # module plugs
    plug Discuss.Plugs.SetUser
    # # #
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    get "/", TopicController, :index
    # get "/topics/new", TopicController, :new
    # post "/topics", TopicController, :create
    # get "/topics/:id/edit", TopicController, :edit
    # put "/topics/:id", TopicController, :update
    # delete "/topics/:id", TopicController, :delete # << might wanna check this..

    # note on advantage of using the defined routees above is you get to define /:id
    # phoenix will default to :id anyways but.. you don't have control anymore
    resources "/topics", TopicController

  end

  # setup a new namespace for auth routes
  scope "/auth", Discuss do
    pipe_through :browser

    # could use "/github" but if we add other oauth in the future..
    # :provider will intelligently choose
    get "/signout", AuthController, :signout
    get ":provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Discuss do
  #   pipe_through :api
  # end
end
