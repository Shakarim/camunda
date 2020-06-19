defmodule Camunda.Group do
  @moduledoc ~S"""
  Module for working with groups
  """

  @list "/group"
  @get "/group/{id}"

  @doc ~S"""
  Returns list of groups
  """
  def list(username, password, options \\ [])
  def list(username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- @list,
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(request_url, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Group.list/3"}
    end
  end


  @doc ~S"""
  Returns group by identity

  ## Examples

    iex> Camunda.Group.get_by_id "abfsmExpertBySolidMining", "demo", "demo"
    {
      :ok,
      %{
        "id" => "abfsmExpertBySolidMining",
        "name" => "╨г╨Ю ╨┐╨╛ ╤В╨▓╨╡╤А╨┤╤Л╨╝ ╨┐╨╛╨╗╨╡╨╖╨╜╤Л╨╝ ╨╕╤Б╨║╨╛╨┐╨░╨╡╨╝╤Л╨╝. ╨н╨║╤Б╨┐╨╡╤А╤В ╨┐╨╛ ╨в╨Я╨Ш",
        "type" => "abfsm"
      }
    }

  """
  def get_by_id(id, username, password, options \\ [])
  def get_by_id(id, username, password, options) do
    with req_headers <- ApiInstance.get_basic_header(username, password),
         req_url <- String.replace(@get, "{id}", id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(req_url, req_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      {:ok, result}
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Group.get_by_id/3"}
    end
  end

  @doc ~S"""
  Returns list of group ids
  """
  def get_group_ids(username, password, options \\ [])
  def get_group_ids(username, password, options) do
    with {:ok, groups} <- list(username, password, options) do
      {
        :ok,
        groups
        |> Enum.map(&(Map.get(&1, "id")))
        |> Enum.filter(&(&1 !== nil))
      }
    else
      error -> error
    end
  end
end
