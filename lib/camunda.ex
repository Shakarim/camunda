defmodule Camunda do
  @moduledoc ~S"""
  Documentation for Camunda.
  """

  @doc """
  Returns Basic Auth data from conn

  ## Returns

    {:ok, {username, password}}

    {:error, "Auth data not found"}

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
      {:ok, {username, password}}
    else
      _ -> {:error, "Auth data not found"}
    end
  end

  @doc """
  Returns auth data from app configurations

  ## Returns

    {username :: String.t(), password :: String.t()}
    {nil, nil}

  """
  def get_auth_data,
      do: prepare_auth_data({Application.get_env(:camunda, :username), Application.get_env(:camunda, :password)})

  defp prepare_auth_data({username, password}) when (username !== nil && password !== nil),
       do: {:ok, {username, password}}

  defp prepare_auth_data({username, password}),
       do: {:error, "Server doesn't have configured auth data for camunda. Contact administrator"}
end
