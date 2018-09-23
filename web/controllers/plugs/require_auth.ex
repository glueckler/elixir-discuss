defmodule Discuss.Plugs.RequireAuth do

  import Plug.Conn # gives us halt()
  import Phoenix.Controller # put_flash and redirect

  alias Discuss.Router.Helpers # for Helpers.topic_path

  def init(_params) do

  end

  def call(conn, _params) do
    # First
    # check if user is logged in
    # we don't typically use if else in elixir
    # here we don't really know what :user contains to cond with pattern matching is tough
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "Must be logged in, homie")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt() # tells phoenix to that we don't need to go any further with execution
    end

    # Second
    # Make sure the user is the topic creator


  end
end
