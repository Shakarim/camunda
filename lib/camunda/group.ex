defmodule Camunda.Group do
  @moduledoc ~S"""
  Module for working with groups
  """

  @list "/group"

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
