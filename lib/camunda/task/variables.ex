defmodule Camunda.Task.Variables do
  @moduledoc ~S"""
  Module for working with task variables
  """

  @list "/task/{id}/variables"

  @doc """
  Returns list of task variables by username and password

  ## Params

    task :: Map.t()
    username :: String.t()
    password :: String.t()
    options :: Map.t()

  ## Returns

    {:ok, Map.t()} | {:error, String.t()}

  """
  def list(task, username, password, options \\ [])

  def list(%{"id" => task_id} = task, username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@list, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(@list, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      result
      |> Map.keys()
      |> Enum.reduce(
           %{},
           fn key, result ->
             %{"type" => type, "value" => value} = item = result[key]
             value = case type do
               "Json" -> Jason.decode!(value)
               _ -> value
             end
             Map.put(result, key, Map.put(item, "value", value))
           end
         )
    end
  end

end
