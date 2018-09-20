defmodule Discuss.Plugs.SetUser do
  # the goal here to to take the user id from the session and give the
  # conn object access to all the info on the user

  import Plug.Conn # helpers for the conn object
  import Phoenix.Controller

  alias Discuss.Repo
  alias Discuss.User
  alias Discuss.Router.Helpers

  def init(_params) do
    # we don't really need to do any set up
    # but must have this function to call anyways
  end

  def call(conn, _params) do
    # _params is the return value from the init function (not anything here)

    # get the user id which is in :user_id as set by the login function in auth controller
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end
  end
end
