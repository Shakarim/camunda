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

  def list(%{"id" => task_id} = _task, username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@list, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(request_url, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      result
      |> Enum.map(
           fn {k, v} ->
             value = case Map.get(v, "type") do
               "Json" -> Jason.decode!(Map.get(v, "value"))
               _ -> Map.get(v, "value")
             end
             {k, Map.put(v, "value", value)}
           end
         )
      |> Enum.into(%{})
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.Variables.list/4"}
    end
  end

end
