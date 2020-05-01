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
         request_url <- String.replace(@list),
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
end
