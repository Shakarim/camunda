defmodule Camunda do
  @moduledoc ~S"""
  Documentation for Camunda.
  """

  @doc """
  Returns Basic Auth data from conn

  ## Returns

    [username, password]

    [nil, nil]

  ## Params

    %Plug.Conn{}

  """
  def get_basic_auth_data(conn) do
    with [token] <- Plug.Conn.get_req_header(conn, "authorization"),
         [username, password] <- token
                                 |> String.split(" ")
                                 |> List.last()
                                 |> Base.decode64!()
                                 |> String.split(":") do
      {username, password}
    else
      _ -> [nil, nil]
    end
  end
end
