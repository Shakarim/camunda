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

  ## Examples

    iex> Camunda.Task.load_variables(%{"id" => "ae4ec37c-8b85-11ea-bc55-d850e640ee9f"},"operator","operator",[params: %{deserializeValues: false}])

  """
  def list(task, username, password, options \\ [])

  def list(%{"id" => task_id} = _task, username, password, options) do
    with request_headers <- ApiInstance.get_basic_header(username, password),
         request_url <- String.replace(@list, "{id}", task_id),
         {:ok, %HTTPoison.Response{} = response} <- ApiInstance.get(request_url, request_headers, options),
         {:ok, result} <- ApiInstance.get_request_result(response)
      do
      result
      |> Enum.map(&variable_map/1)
      |> Enum.into(%{})
    else
      {status, result} -> {status, result}
      error -> {:error, error}
      _ -> {:error, "Unknown error of Camunda.Task.Variables.list/4"}
    end
  end

  defp variable_map({key, %{"type" => "Json", "value" => value} = data}) do
    with {:ok, decoded_value} <- Jason.decode(value) do
      {key, Map.put(data, "value", decoded_value)}
    else
      _ -> {key, data}
    end
  end

  defp variable_map({key, data}), do: {key, data}
end
